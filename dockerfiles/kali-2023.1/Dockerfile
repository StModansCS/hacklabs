FROM hunterg05s/kali-2023.1:base
RUN apt-get update && apt-get -y install openssh-server net-tools iputils-ping nano metasploit-framework
RUN passwd -d root && usermod -L root
RUN useradd -U -m -s /bin/bash kladmin && usermod -aG sudo kladmin && echo kladmin:kladmin | chpasswd && su -c "touch ~/.hushlogin" kladmin
COPY entrypoint.sh /
