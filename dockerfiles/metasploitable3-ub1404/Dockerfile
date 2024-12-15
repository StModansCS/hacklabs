FROM hunterg05s/metasploitable3-ub1404:base
RUN passwd -d root && usermod -L root
RUN usermod -d /home/msfadmin -m -l msfadmin vagrant && groupmod -n msfadmin vagrant && echo msfadmin:msfadmin | chpasswd
COPY --chown=msfadmin:msfadmin vulnerable /home/msfadmin/
COPY entrypoint.sh /
