# Jenkins Docker container agent

## Introduction 

Here we will learn how to spin up a Docker container as a Jenkins build agent.

![](https://github.com/nokorinotsubasa/project-docker-agent/blob/050dc2e6a00b62220efd1295556cbdd45d68486a/images/Architecture.png)

We will use terraform for resource deployments.

Terraform will deploy all the resources required, including two Vms, one which will run Jenkins on a Docker container, and the other will run the Docker agent container.

Both Vms have script extensions to configure basic dependencies upon creation.

### Steps

- Deploy the resources using terraform.

- On the `agentVm`, edit the `docker.service` file to open `port 4243` allowing tcp connection:

`sudo vi usr/lib/systemd/system/docker.service`

modify the current line: 

![]()

>`ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock`

- Restart docker services:

`systemctl daemon-reload`

`systemctl restart docker`

you can test the connection using the other Vm:

`curl http://<agentvmip>:4243/version`

- Proceed with the basic jenkins installation on the `master Vm`. You will need to install the `Docker plugin`

![]()

>`masterVm`

- Head to `Manage Jenkins > Clouds`, add a new cloud of type docker;

- On the docker host url, insert the agent vm url as follows:

![]()

`tcp://<agentvmIp>:4243`

- Test the connection and enable it, also expose `DOCKER_HOST`;

- Set the container cap;

- Set the "Remote File system Root" as `/home/ubuntu`

- Add a docker template and enable it, on the docker image option set the image you want to use, in our case we will use a custom docker image:

`nokorinotsubasa/agent175:v5`

- Set a label as you please. In this example we will use 'docker-agent'

- On the connect method option choose connect with ssh;

- On credential, create an `"Username and password"` type of credentials

- Set username as `jenkins` and password as `jenkins`, this was defined on the custom docker image which will run the docker agent;

- On Host key Verification Strategy, choose `"Non verifying Verification Strategy"`, this is not recommended and will be done just for demonstration. 

![]()

>`final configuration`

- That's it, now on the pipeline configuration, set the `"Restrict where this build can run"` to the name of the label you defined on the docker template configuration.
In case of a script, set as:

`agent {label 'label'}`

- E.g.

![]()


Here, we defined docker to spin up a container which will be used as a `Jenkins agent`.