FROM debian
RUN apt-get update && apt --assume-yes install openssh-server
RUN passwd -d root && usermod -L root
#RUN useradd -U -m -s /bin/bash kladmin && usermod -aG sudo kladmin && echo kladmin:kladmin | chpasswd && su -c "touch ~/.hushlogin" kladmin
COPY entrypoint.sh /
