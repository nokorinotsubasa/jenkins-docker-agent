# docker-agent
Docker Agent on Jenkins

Introduction

Here we will learn how to spin up a Docker container as a Jenkins build agent.
We will use terraform for resource deployments.
Terraform will deploy all the resources required, including two Vms, one will run Jenkins on a Docker container, and the other will run the Docker agent container.
Both Vms have script extensions that will run upon Vm creation.
The docker agent container will use a custom docker image, this image will have some dependencies installed, such as Java.

Steps

After deploying the resources, proceed with the basic jenkins installation on the master Vm. You will need to install the Docker plugin
On the agent Vm follow these steps:
1. 
Edit the docker.service file to open port 4243 allowing tcp connection:

sudo vi usr/lib/systemd/system/docker.service

add/edit the current line:

ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock

2. 
Restart docker services:
systemctl daemon-reload
systemctl restart docker

You can test the connection on the agent machine:
curl http://<agentvmip>:4243/version

3.
Procede with the configuration on jenkins:
Manage Jenkins > Clouds, add a new cloud of type docker;
On the docker host url, insert the agent vm url as follows: 
tcp://<agentvmIp>:4243
Test the connection and enable it, also expose DOCKER_HOST;
Set the container cap;
Set the "Remote File system Root" as "/home/ubuntu"
Add a docker template and enable it, on the docker image option set the image you want to use, in our case we will use my custom image:
nokorinotsubasa/agent175:v5
