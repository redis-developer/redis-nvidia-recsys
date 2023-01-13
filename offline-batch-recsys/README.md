# Offline Batch Recsys
When there aren't enough computational resources to host a "live model", the next best option is to perform the inference step "offline". This means that after training a model, recommendations can be manually generated for the entire population of Users (in the background).

![img](./img/OfflineBatchRecsys.png)

*This could be...*
- A cron-like job that runs every few hours or days.
- A reactive job that triggers based on some event.
- A manual job that runs when you tell it to.

After the offline job runs, recommendations are stored in a low-latency key-value store (Redis) per User.

For example -- Spotify could generate music playlist recommendations for all Users every night at 11:59pm CET.

## Training Models
In this example, you will spin up a Merlin Tensorflow container to train a Two-Tower **Candidate Retrieval Model** with negative sampling (*fine-tuned to predict the interaction between a User and an Item in the product catalog*) and use the created embedding towers to retrieve the **topK** candidates per user. These candidates (items) will get get passed through a trained **DLRM** model to rank the candidates and write to Redis.

### Start the Container
With Docker Compose, run the following in your terminal. It may take a few minutes to pull and build the required docker containers and install Python requirements.

```bash
$ docker compose up
```
*add `-d` to this command to daemonize the docker compose stack if desired...*

>Due to the GPU requirements of this tutorial, it's recommended to spin up an AWS EC2 instance with NVIDIA GPU attached and Driver installed. One possibility is the []() from the AWS marketplace.
