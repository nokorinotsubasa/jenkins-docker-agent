# Jenkins Docker container agent

## Introduction 

Here we will learn how to spin up a Docker container as a Jenkins build agent.

![](https://github.com/nokorinotsubasa/project-docker-agent/blob/0b0d399f94731fb376a0ec5675af6ed972fc379f/images/Architecture.png)

We will use terraform for resource deployments.

Terraform will deploy all the resources required, including two Vms, one which will run Jenkins on a Docker container; the other will run the Docker agent container.

Both Vms have script extensions to configure basic dependencies upon creation.

The Docker agent container will use a custom Docker image; the dockerfile can be found in this repository.

### Steps

- Deploy the resources using terraform.

- On the `agentVm`, edit the `docker.service` file to open `port 4243` allowing tcp connection: `remember to be on the right directory`

`sudo vi usr/lib/systemd/system/docker.service`

modify the current line: 

>`ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock`

![](https://github.com/nokorinotsubasa/project-docker-agent/blob/1388f56c3cfcb3e2416d5c6383ab16a9b3cc3d6c/images/dockerserviceModification.png)


- Restart docker services:

`sudo systemctl daemon-reload`

`sudo systemctl restart docker`

you can test the connection using the other Vm:

`curl http://<agentvmip>:4243/version`

![](https://github.com/nokorinotsubasa/project-docker-agent/blob/1388f56c3cfcb3e2416d5c6383ab16a9b3cc3d6c/images/curlTest.png)

>`the ip was censored`

- Proceed with the basic jenkins installation on the `master Vm`. You will need to install the `Docker plugin`:

![](https://github.com/nokorinotsubasa/project-docker-agent/blob/1388f56c3cfcb3e2416d5c6383ab16a9b3cc3d6c/images/JenkinsInititalSetup.png)

>`masterVm running Jenkins master`

- Head to `Manage Jenkins > Clouds`, add a new cloud of type docker;

- On the docker host url, insert the agent vm url as follows:

>`tcp://<agentvmIp>:4243`

![](https://github.com/nokorinotsubasa/project-docker-agent/blob/1388f56c3cfcb3e2416d5c6383ab16a9b3cc3d6c/images/NewCloudConfiguration.png)

>`the ip was censored`

- Test the connection and enable it, also expose `DOCKER_HOST`;

- Set the container cap;

- Now on `docker template`, add a new template;

- Set the label and name;

- On the docker image option set the image you want to use, in our case we will use a custom docker image:
`nokorinotsubasa/agent175:v5`

- Set the `"Remote File system Root"` as `/home/ubuntu`:

![](https://github.com/nokorinotsubasa/project-docker-agent/blob/1388f56c3cfcb3e2416d5c6383ab16a9b3cc3d6c/images/DockerAgentTemplateConfiguration.png)

- On the connect method option choose connect with ssh;

- On `ssh key`, select `"Use configured SSH credentials"`;

- On credential, add an `"Username and password"` type of credentials;

- Set username as `jenkins` and password as `jenkins`, this was defined on the custom docker image which will run the docker agent;

- On Host key Verification Strategy, choose `"Non verifying Verification Strategy"`;

>`this is not recommended and will be done just for demonstration`

![](https://github.com/nokorinotsubasa/project-docker-agent/blob/1388f56c3cfcb3e2416d5c6383ab16a9b3cc3d6c/images/DockerAgentTemplateSSHConfiguration.png)

>`final configuration`

- That's it, now on the `freestyle pipeline` configuration, set the `"Restrict where this build can run"` with the name of the label you defined on the docker template configuration.
In case of a `pipeline script`, set as:
`"agent {label 'label'}"`

- E.g.

![](https://github.com/nokorinotsubasa/project-docker-agent/blob/1388f56c3cfcb3e2416d5c6383ab16a9b3cc3d6c/images/pipelineScript.png)

- As you can see, a new docker container was deployed, it was used to run the pipeline, and then was destroyed:

![](https://github.com/nokorinotsubasa/project-docker-agent/blob/1388f56c3cfcb3e2416d5c6383ab16a9b3cc3d6c/images/docker-agent-pipeline.png)

>`Running on docker-agent-00000kac0e5xb on docker-agent in /home/ubuntu/workspace/docker-agent-pipeline`

- If you head into `Cloud statistics`, you can check some information on the agents:

![](https://github.com/nokorinotsubasa/project-docker-agent/blob/1388f56c3cfcb3e2416d5c6383ab16a9b3cc3d6c/images/Jenkins%20Cloud%20Statistics.png)

Here, we defined docker to spin up a container which will be used as a `Jenkins agent`.