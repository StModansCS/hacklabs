FROM debian
RUN apt-get update && apt --assume-yes install openssh-server
RUN passwd -d root && usermod -L root
COPY entrypoint.sh /
