import io
import json
import logging
import sys

import numpy as np
import triton_python_backend_utils as pb_utils

from merlin.dag import DictArray


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
        self.output_names = [output["name"] for output in self.model_config["output"]]
        self.input_names = [inp["name"] for inp in self.model_config["input"]]
        
        # Load feature store components
        self.item_id_col = "item_id"

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
            input_tensor = {
                name: pb_utils.get_input_tensor_by_name(request, name).as_numpy()
                for name in self.input_names
            }
            input_df = DictArray(input_tensor)
            num_items = input_df[self.item_id_col].shape[0]
            
            output_tensors = []
            
            for col_name, col_value in input_df.items():
                if col_name in self._unroll_col_names:
                    # Unroll user features to match dimensionality of item features
                    col_value = np.repeat(col_value, num_items, axis=0)
                
                out_tensor = pb_utils.Tensor(col_name, col_value)
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