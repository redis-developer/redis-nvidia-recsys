
# Benchmarking and Optimization

This directory details the benchmarking and optimization of the Recommendation System pipelines detailed in the [GTC Talk](https://www.nvidia.com/gtc/session-catalog/?search=&tab.catalogallsessionstab=16566177511100015Kus&search.industry=1573511018587001tqXx#/session/1666220140403001tMxB) given at GTC in March 2023.

The [Revisions](../online-multi-stage-recsys/revisions) directory contains the code for the different versions of the Recommendation System pipelines detailed in the talk. In total, there are 5 versions of the pipeline.

- [01-Baseline](../online-multi-stage-recsys/revisions/01-baseline) - The baseline version of the pipeline
- [02-stage-consolidation](../online-multi-stage-recsys/revisions/02-stage-consolidation) - VSS and item feature retrieval consolidated into a single stage.
- [03-remove-feast-sdk](../online-multi-stage-recsys/revisions/03-remove-feast-sdk) - The Feast SDK is removed from the pipeline and redis clients are used directly.
- [04-vss-retrieval](../online-multi-stage-recsys/revisions/04-vss-retrieval) - Vector search is used to retrieve the item features.
- [05-vss-retrieval-opt](../online-multi-stage-recsys/revisions/05-vss-retrieval-opt) - Same as the previous pipeline with the triton response cache turned on and slight model configuration improvements (# of model copies).

## Benchmarking

The benchmarking setup can largely be deployed with the terraform/ansible scripts in the [cloud-deployment](../cloud-deployment) directory. The only addition is that a client node needs to be added that will be used to run the triton ``perf_analyzer`` tool.

The setup is depicted below.

![](../assets/benchmarking-setup.png)

The benchmarking setup consists of the following components:
1. Redis Enterprise Software (RES) - The feature store and vector index
2. Triton Inference Server - The model serving component
3. Prometheus/Graphana - The monitoring component
4. Client Node - The node that will run the benchmarking tool

Follow the cloud deployment setup to get the first three components up and running. The client node setup is detailed below.

### Client Node Setup

The client node is used to run the ``perf_analyzer`` tool. The tool is used to benchmark the entire pipeline from end to end.

For the GTC talk, a ``t2.2xlarge`` instance with 8 vCPU was used to run ``perf_analyzer``. The instance was configured with 32GB of RAM and 100GB of disk space. When spinning this instance up on Amazon, make sure to select the same security groups, VPN, and DNS record set as the other instances launched by terraform.


To setup the benchmarking tool on the client node, follow the steps below.

1. Install Docker

```bash
$ sudo yum update -y
$ sudo amazon-linux-extras install docker -y
$ sudo service docker start
$ sudo usermod -a -G docker ec2-user
$ sudo systemctl enable docker
```

2. Pull and run the Triton SDK container

```bash
docker pull nvcr.io/nvidia/tritonserver:22.12-py3-sdk
# mount the timings directory for saving CSV output
docker run --net=host -v${PWD}:/workdir/timings -it nvcr.io/nvidia/tritonserver:22.12-py3-sdk
```

3. Run the Triton Perf Analzer

There are multiple ways to run ``perf_analzer`` which are detailed below.

```bash
# run perf_analyzer with a single concurrency level
perf_analyzer -m ensemble-model -u <triton ip addr>:8000 --input-data=../sample.json --shape=user_id_raw:1,1

# run perf_analyzer with multiple concurrency levels
perf_analyzer -m ensemble-model -u <triton ip addr>:8000 --input-data=../sample.json --shape=user_id_raw:1,1 --concurrency-range=2:20:2

# collect and save metrics to a CSV file
perf_analyzer -m ensemble-model -u <triton ip addr>:8000 --input-data=../sample.json --shape=user_id_raw:1,1 --collect-metrics --verbose-csv --metrics-url <triton ip addr>:8002 --concurrency-range=2:20:2 -f perf_output.csv

# run with a number of different inputs and save the results to a CSV file
perf_analyzer -m ensemble-model -u <triton ip addr>:8000 --input-data=../sample_32.json --shape=user_id_raw:1,1 --collect-metrics --verbose-csv --metrics-url <triton ip addr>:8002 --concurrency-range=2:20:2 -f perf_output.csv
```

### Setup for Optimzations

For the first two optimizations (consolidating the stages and removing the Feast SDK), no changes need to be made from the jupyter notebooks in the [online-multi-stage-recsys](../online-multi-stage-recsys) directory. The only change is that the ``perf_analyzer`` tool is used to benchmark the pipelines.

For [03-remove-feast-sdk](../online-multi-stage-recsys/revisions/03-remove-feast-sdk), the feature store is setup with the [03-feastless-feature-store-setup.ipynb](../online-multi-stage-recsys/03-feastless-feature-store-setup.ipynb) notebook. This notebook is the same as the [01-Building-Online-Multi-Stage-Recsys-Components.ipynb](../online-multi-stage-recsys/01-Building-Online-Multi-Stage-Recsys-Components.ipynb) notebook except that the Feast SDK is not used to create the feature store and the data is stored in native Redis data structures instead of Feast's protobuf format.

For the last two, [04-vss-retrieval](../online-multi-stage-recsys/revisions/04-vss-retrieval) and [05-vss-retrieval-opt](../online-multi-stage-recsys/revisions/05-vss-retrieval-opt), the feature store is setup with the [04-vss-feature-store-setup.ipynb](../online-multi-stage-recsys/04-vss-feature-store-setup.ipynb) notebook. This notebook is the same as the [01-Building-Online-Multi-Stage-Recsys-Components.ipynb](../online-multi-stage-recsys/01-Building-Online-Multi-Stage-Recsys-Components.ipynb) notebook except that the vector index is created using the same data as the feature store data meaning that the embedings are stored as values within each item's hash map.


### Perf Analyzer Output

The ``perf_analyzer`` output for each run will detail the latencies and throughput for each stage of the pipeline. It will look something like the following if all flags listed above are used.

```text
root@ip-10-0-0-213:/workdir/timings/04-vss-retrieval# perf_analyzer -m ensemble-model -u <triton_IP>:8000 --input-data=../sample.json --shape=user_id_raw:1,1 --collect-metrics --verbose-csv --metrics-url=<triton_IP>:8002/metrics --concurrency-range=2:20:2 -f ./perf_output.csv
 Successfully read data for 1 stream/streams with 1 step/steps.
*** Measurement Settings ***
  Batch size: 1
  Service Kind: Triton
  Using "time_windows" mode for stabilization
  Measurement window: 5000 msec
  Latency limit: 0 msec
  Concurrency limit: 20 concurrent requests
  Using synchronous calls for inference
  Stabilizing using average latency

Request concurrency: 2
  Client:
    Request count: 3672
    Throughput: 203.953 infer/sec
    Avg latency: 9799 usec (standard deviation 647 usec)
    p50 latency: 9673 usec
    p90 latency: 10477 usec
    p95 latency: 10966 usec
    p99 latency: 12166 usec
    Avg HTTP time: 9793 usec (send/recv 76 usec + response wait 9717 usec)
  Server:
    Inference count: 3672
    Execution count: 3672
    Successful request count: 3672
    Avg request latency: 9166 usec (overhead 30 usec + queue 306 usec + compute 8830 usec)

  Composing models:
  0-query-user-features, version:
      Inference count: 3672
      Execution count: 3672
      Successful request count: 3672
      Avg request latency: 940 usec (overhead 36 usec + queue 35 usec + compute input 22 usec + compute infer 768 usec + compute output 79 usec)

  1-user-embeddings, version:
      Inference count: 3672
      Execution count: 3672
      Successful request count: 3672
      Avg request latency: 982 usec (overhead 20 usec + queue 57 usec + compute input 35 usec + compute infer 863 usec + compute output 7 usec)

  2-redis-vss-candidates, version:
      Inference count: 3672
      Execution count: 3672
      Successful request count: 3672
      Avg request latency: 4590 usec (overhead 18 usec + queue 44 usec + compute input 17 usec + compute infer 4435 usec + compute output 75 usec)

  4-unroll-features, version:
      Inference count: 3672
      Execution count: 3672
      Successful request count: 3672
      Avg request latency: 907 usec (overhead 57 usec + queue 50 usec + compute input 48 usec + compute infer 644 usec + compute output 106 usec)

  5-ranking, version:
      Inference count: 3672
      Execution count: 3672
      Successful request count: 3672
      Avg request latency: 1530 usec (overhead 19 usec + queue 83 usec + compute input 53 usec + compute infer 1368 usec + compute output 7 usec)

  6-softmax-sampling, version:
      Inference count: 3672
      Execution count: 3672
      Successful request count: 3672
      Avg request latency: 345 usec (overhead 8 usec + queue 37 usec + compute input 14 usec + compute infer 233 usec + compute output 52 usec)

  Server Prometheus Metrics:
    Avg GPU Utilization:
      GPU-e9e12b39-c132-432c-6e25-b79856687237 : 4.33333%
    Avg GPU Power Usage:
      GPU-e9e12b39-c132-432c-6e25-b79856687237 : 34.54 watts
    Max GPU Memory Usage:
      GPU-e9e12b39-c132-432c-6e25-b79856687237 : 966787072 bytes
    Total GPU Memory:
      GPU-e9e12b39-c132-432c-6e25-b79856687237 : 16106127360 bytes
```

### Benchmarking Results

The following table shows the results of the benchmarking runs across revisions. The columns represent the revision name, avg latency, p95 latency, p99 latency and throughput (infer/sec) respectively. A concurrency level of 16 was chosen for the test runs based on the CPU utilization of the client node. Syncronous calls were used for inference.


| Revision | Avg Latency | P95 Latency | P99 Latency | Throughput |
| --- | --- | --- | --- | --- |
| 01-baseline | 483 ms | 535 ms | 560 ms | 33.1 infer/sec |
| 02-stage-consolidation | 260 ms | 328 ms | 397 ms | 61.4 infer/sec |
| 03-remove-feast | 130 ms | 137 ms | 140 ms | 122.4 infer/sec |
| 04-vss-retrieval | 50 ms | 58 ms | 63 ms | 320.3 infer/sec |
| 05-vss-retrieval-opt | 29 ms | 31 ms | 33 ms | 542.8 infer/sec |

> NOTE: The last stage results represent ONLY duplicate requests to show the importance of the inference cache. The throughput of the final revision is the same as the throughput of the previous revision for non-duplicate requests.



