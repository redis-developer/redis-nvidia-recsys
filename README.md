# Recommendation Systems with NVIDIA Merlin and Redis

This repo holds the assets that supplement the article "Offline to Online: Feature Storage for Real-time Recommendation Systems with NVIDIA Merlin" written originally for the NVIDIA Developer Blog.

## Recommendation System Architectures

In this repository, we provide 2 examples of recommendation system architectures and provide a third that expands
on how to scale up when training on large datasets. Each of the examples rely on Redis and the NVIDIA Merlin framework which
provides a number of building blocks for creating recommendation systems.

> Note: we recommend executing all of the following on a cloud instance with an NVIDIA GPU (ideally the AWS Pytorch AMI)

In this repo, we provide three demos that highlight each of the following designs for recommender systems

### [1. Offline Batch Recommendations](./offline-batch-recsys/)

![](./assets/OfflineBatchRecsys.png)

"Offline" recommendation systems use batch computing to process large quantities of data and then store them for later retrieval. The diagram above shows an example of such a system that uses a Two-Tower approach to generate recommendations and then stores them inside a Redis database for later retrieval.

The [offline notebook](./offline-batch-recsys/Offline-Batch-Recommender-System.ipynb) provides methods to build up
this type of recommendation system as well as trains and exports the models necessary for running the online
recommendation system in the following section.

> NOTE: You can also just download pre-trained assets as follows

```
wget <put in url>
```

To execute the notebook, run the following

```bash
$ docker compose up # -d to daemonize
```

### [2. Online Recommendation Systems](./multi-stage/)

![](./assets/OnlineMultiStageRecsys.png)

An "online" recommendation system generates recommendations on-demand. As opposed to batch oriented systems, online systems are latency-constrained. When designing these systems, the amount of time to produce recommendations is likely the most important factor.   Commonly capped around 100-300ms, each portion of the system needs components that are not only efficient but scalable to millions of users and items. Creating an online recommendation system has significantly more constraints than batch systems, however, the result is often better recommendations as information (features) can be updated in real-time. The diagram above shows an example of this architecture.

To execute the notebook, run the following

```bash
$ docker compose up # -d to daemonize
```


### [3. Large-Scale Recommendation Systems with HugeCTR](./large-scale-recsys/)

![](./assets/OnlineMultiStageRecsys.png)

The last notebook that shows how to handle very large datasets when training models like DLRM for recommendation systems. Large enterprises often have millions of users and items. The entire embedding table of a model may not fit on a single GPU. For this, NVIDIA created the HugeCTR framework.

HugeCTR is a part of a NVIDIA Merlin framework and adds facilities for distributed training and serving of recommendation models. The notebook detailed here focuses on the deployment and serving of HugeCTR and provides a pre-trained version of DLRM that can be used for the example. More information on distributed training with HugeCTR can be found here.

To execute the local notebook, run the following

```bash
$ docker compose up # -d to daemonize
```

TODO: Put in instructions to run the cloud deployment one.


## Resources

### Pre-trained Models

The models in this tutorial can be retrieved by running

```
wget <put in link>
```

### Repositories

The following repostories link to code/assets used in articles and notebooks

- [Redis Ventures](https://github.com/RedisVentures)
- [Feast GitHub](https://github.com/feast-dev/feast)
- [NVTabular](https://github.com/NVIDIA-Merlin/NVTabular)
- [HugeCTR](https://github.com/NVIDIA-Merlin/HugeCTR)
- [Merlin Models](https://github.com/NVIDIA-Merlin/models)
- [Merlin Systems](https://github.com/NVIDIA-Merlin/systems)
- [Transformers4Rec](https://github.com/NVIDIA-Merlin/Transformers4Rec)

### Inspirational Notebooks

The notebooks here build on the work of many pre-existing notebooks such as

- [HugeCTR Backend examples](https://github.com/triton-inference-server/hugectr_backend/tree/main/samples)
- [HugeCTR examples](https://github.com/NVIDIA-Merlin/HugeCTR/tree/main/samples)
- [Merlin Examples](https://github.com/NVIDIA-Merlin/Merlin/tree/main/examples)
- [Deploying Multi-Stage Recsys](https://github.com/NVIDIA-Merlin/Merlin/tree/main/examples/Building-and-deploying-multi-stage-RecSys)


### Articles and other Recommended Reading

We highly recommend reading

- [Designing Machine Learning Systems](https://www.amazon.com/Designing-Machine-Learning-Systems-Production-Ready/dp/1098107969/ref=asc_df_1098107969/?tag=hyprod-20&linkCode=df0&hvadid=564675582183&hvpos=&hvnetw=g&hvrand=6460096250567075707&hvpone=&hvptwo=&hvqmt=&hvdev=c&hvdvcmdl=&hvlocint=&hvlocphy=1027270&hvtargid=pla-1688018801992&psc=1)
- [DLRM article](https://ai.facebook.com/blog/dlrm-an-advanced-open-source-deep-learning-recommendation-model/)
- [Merlin HPS](https://developer.nvidia.com/blog/scaling-recommendation-system-inference-with-merlin-hierarchical-parameter-server/)
- [Moving Beyond Recommender Models Talk](https://www.youtube.com/watch?v=5qjiY-kLwFY&list=PL65MqKWg6XcrdN4TJV0K1PdLhF_Uq-b43&index=9)
- [WDL Notes](https://calvinfeng.gitbook.io/machine-learning-notebook/supervised-learning/recommender/wide_and_deep_learning_for_recommender_systems)
- [How to build a DLRM](https://developer.nvidia.com/blog/how-to-build-a-winning-recommendation-system-part-2-deep-learning-for-recommender-systems/)
- [Monolith Paper](https://arxiv.org/abs/2209.07663)
