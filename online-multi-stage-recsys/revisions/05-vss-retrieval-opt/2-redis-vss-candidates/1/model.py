import io
import os
import json
import logging
import sys
import redis

import numpy as np
import pandas as pd
import triton_python_backend_utils as pb_utils

from redis.commands.search.query import Query


class TritonPythonModel:
    """Your Python model must use the same class name. Every Python model
    that is created must have "TritonPythonModel" as the class name.
    """

    def initialize(self, args):
        """`initialize` is called only once when the model is being loaded.
        Implementing `initialize` function is optional. This function allows
        the model to intialize any state associated with this model.
        Parameters
        ----------
        args : dict
          Both keys and values are strings. The dictionary keys and values are:
          * model_config: A JSON string containing the model configuration
          * model_instance_kind: A string containing model instance kind
          * model_instance_device_id: A string containing model instance device ID
          * model_repository: Model repository path
          * model_version: Model version
          * model_name: Model name
        """

        # Parse model_config. JSON string is not parsed here
        logging.info("Parsing model config")
        self.model_config = model_config = json.loads(args['model_config'])
        self.params = self.model_config["parameters"]
        self.output_names = [output["name"] for output in self.model_config["output"]]
        self.input_names = [inp["name"] for inp in self.model_config["input"]]

        # Load feature store components
        logging.info("Loading RediSearch Client")
        #host, port = os.environ["FEATURE_STORE_ADDRESS"].split(":")
        host = "52.9.82.78"
        port = 18376
        self.redis_conn = redis.Redis(host=host, port=port, decode_responses=True)
        self.vector_db_config = json.loads(self.params["vector_db_config"]["string_value"])
        self.index_name = self.vector_db_config["index_name"]
        self.vector_field_name = self.vector_db_config["vector_field_name"]
        self.topk = int(self.vector_db_config["topk"])

        self.entity_column = "candidate_ids"

    def execute(self, requests):
        """`execute` MUST be implemented in every Python model. `execute`
        function receives a list of pb_utils.InferenceRequest as the only
        argument. This function is called when an inference request is made
        for this model. Depending on the batching configuration (e.g. Dynamic
        Batching) used, `requests` may contain multiple requests. Every
        Python model, must create one pb_utils.InferenceResponse for every
        pb_utils.InferenceRequest in `requests`. If there is an error, you can
        set the error argument when creating a pb_utils.InferenceResponse
        Parameters
        ----------
        requests : list
          A list of pb_utils.InferenceRequest
        Returns
        -------
        list
          A list of pb_utils.InferenceResponse. The length of this list must
          be the same as `requests`
        """
        responses = []

        # Every Python backend must iterate over everyone of the requests
        # and create a pb_utils.InferenceResponse for each of them.
        for request in requests:
            # Get Inputs
            input_name = self.input_names[0]
            query_embedding = pb_utils.get_input_tensor_by_name(request, input_name).as_numpy()

            # Query Redis for KNN
            query = Query(f"*=>[KNN {self.topk} @{self.vector_field_name} $vec_param AS vector_score]")\
                .sort_by("vector_score")\
                .paging(0, self.topk)\
                .return_fields(*self.output_names)\
                .dialect(2)

            res = self.redis_conn.ft(self.index_name).search(query, query_params={"vec_param": query_embedding.tobytes()})

            item_features = [doc.__dict__ for doc in res.docs]
            features = pd.DataFrame(item_features).drop(["payload", "id"], axis=1)
            features = features.fillna(1).astype(int)

            # Loop through features to create separate output tensors
            output_tensors = []
            for output_name in self.output_names:
                feature_value = features[output_name]
                feature_array = np.array(feature_value).T.astype(np.int32).reshape(-1, 1)
                out_tensor = pb_utils.Tensor(output_name, feature_array)
                output_tensors.append(out_tensor)

            # Create InferenceResponse and append to responses
            inference_response = pb_utils.InferenceResponse(output_tensors)
            responses.append(inference_response)

        # Return a list of pb_utils.InferenceResponse
        return responses

    def finalize(self):
        """`finalize` is called only once when the model is being unloaded.
        Implementing `finalize` function is OPTIONAL. This function allows
        the model to perform any necessary clean ups before exit.
        """
        logging.info('Cleaning up...')