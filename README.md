# redis-merlin-recsys

Recommender systems are hot... TBD

## Recommenders in the Wild
There largely two common patterns for serving recommendations to users: Batch recommendations generated "offline" & Realtime recommendations generated "online". While there are more nuances to this than meet the eye, we will keep focus on these two broad approaches

Something about rec sys scale....

Something about the role of Redis.. broad strokes...


## Resources
In this repo, we provide three demos that highlight each of the following designs for recommender systems:

1) [Offline Batch Recommendations](./offline-batch-recsys/)
2) [Online Multi-Stage Recommendations with NVIDIA Triton](./multi-stage/)
3) [Large Scale Recommendations with NVIDIA Merlin](./large-scale-recsys/)

Depending on the size and type of data, many users will never need to move beyond an online multi-stage recommender as highlighted in option 2. And for others, the simple architecture and drastically cheaper option 1 will work fine (given some tradeoffs discussed later).

> We highly recommend reading [Chip Huyen](https://www.linkedin.com/in/chiphuyen/)'s book, ["Designing Machine Learning Systems"](https://www.amazon.com/Designing-Machine-Learning-Systems-Production-Ready/dp/1098107969/ref=asc_df_1098107969/?tag=hyprod-20&linkCode=df0&hvadid=564675582183&hvpos=&hvnetw=g&hvrand=6460096250567075707&hvpone=&hvptwo=&hvqmt=&hvdev=c&hvdvcmdl=&hvlocint=&hvlocphy=1027270&hvtargid=pla-1688018801992&psc=1), to learn more.

