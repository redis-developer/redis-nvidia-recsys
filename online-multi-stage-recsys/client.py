import os, sys
import numpy as np
import json
import tritonclient.grpc as triton_grpc
import argparse
import time


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--model_name",
                        type=str,
                        required=False,
                        default="ensemble-model",
                        help="Model name")
    parser.add_argument("--url",
                        type=str,
                        required=False,
                        default="localhost:8001",
                        help="Inference server URL. Default is localhost:8001.")
    parser.add_argument("--user",
                        type=int,
                        required=False,
                        default=7,
                        help="User ID to find Recommendations")
    parser.add_argument('-v',
                        "--verbose",
                        action="store_true",
                        required=False,
                        default=False,
                        help='Enable verbose output')
    args = parser.parse_args()

    try:
        triton_client = triton_grpc.InferenceServerClient(url=args.url, verbose=args.verbose)
    except Exception as e:
        print("channel creation failed: " + str(e))
        sys.exit(1)


    inputs = []
    outputs = []
    input_name = "user_id_raw"
    output_name = "ordered_ids"
    inp = np.array([int(args.user)], dtype=np.int32).reshape(-1, 1)
    print("Finding recommendations for User", inp[0][0], flush=True)
    
    t = time.time()

    inputs.append(triton_grpc.InferInput(input_name, inp.shape, "INT32"))
    outputs.append(triton_grpc.InferRequestedOutput(output_name))
    inputs[0].set_data_from_numpy(inp)
    results = triton_client.infer(model_name=args.model_name,
                                  inputs=inputs,
                                  outputs=outputs)

    output0_data = results.as_numpy(output_name)
    print("Recommended Product Ids in", time.time()-t, "seconds", flush=True)
    print(output0_data, flush=True)