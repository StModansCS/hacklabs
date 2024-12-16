FROM debian
RUN apt-get update && apt --assume-yes install openssh-server
RUN passwd -d root && usermod -L root
RUN sed -i "s/^X11Forwarding yes/#X11Forwarding yes/g" "/etc/ssh/sshd_config"
RUN echo AllowAgentForwarding no >> "/etc/ssh/sshd_config"
RUN echo AllowTcpForwarding no >> "/etc/ssh/sshd_config"
RUN echo AllowStreamLocalForwarding no >> "/etc/ssh/sshd_config"
RUN echo PermitTunnel no >> "/etc/ssh/sshd_config"
RUN echo PermitUserEnvironment no >> "/etc/ssh/sshd_config"
RUN echo X11Forwarding no >> "/etc/ssh/sshd_config"
COPY entrypoint.sh /
