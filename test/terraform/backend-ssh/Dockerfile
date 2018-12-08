# Based on https://docs.docker.com/engine/examples/running_ssh_service/#build-an-eg_sshd-image

FROM ubuntu:18.04

ENV NOTVISIBLE "in users profile"
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
COPY id_ed25519.pub /root/.ssh/authorized_keys
RUN echo 'root:password' | chpasswd
RUN echo "export VISIBLE=now" >> /etc/profile
RUN mkdir /var/run/sshd
RUN apt-get update
RUN apt-get install --yes openssh-server
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
