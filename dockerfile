#This is the used dockerfile for the docker agent
FROM ubuntu:latest

RUN apt update && apt install openssh-server sudo -y

RUN sudo apt install -y default-jdk

RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 jenkins

RUN echo 'jenkins:jenkins' | chpasswd

RUN service ssh start

EXPOSE 22

WORKDIR /home/ubuntu