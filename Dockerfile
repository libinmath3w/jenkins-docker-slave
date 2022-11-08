FROM ubuntu:22.04
RUN echo $USER
# Make sure the package repository is up to date.
RUN apt-get update && \
    apt-get install -qy git && \
# Install a basic SSH server
    apt-get install -qy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd && \
# Install JDK 11
    apt-get install -qy default-jdk && \
# Install podman
    apt update &&\
    apt-get install -qy podman && \  
# Install docker
    apt-get update &&\
    apt-get install -qy docker.io && \
   # sudo groupadd docker && \
   # sudo usermod -aG docker $USER && \
   # docker --version && \
# Install sudo
    apt-get install -qy sudo && \   
# Install maven
    apt-get install -qy maven && \
# Cleanup old packages
    apt-get -qy autoremove && \
# Add user jenkins to the image
    #adduser --quiet jenkins && \
    useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 jenkins && \
# Set password for the jenkins user (you may want to alter this).
    echo "jenkins:MyPassword123" | chpasswd 
    #mkdir /home/jenkins/.m2

# Copy authorized keys
COPY .ssh/authorized_keys /home/ubuntu/.ssh/authorized_keys

#RUN chown -R jenkins:jenkins /home/ubuntu/ && \
  #  chown -R jenkins:jenkins /home/ubuntu/.ssh/ 
    
# Standard SSH port
EXPOSE 22
RUN mkdir /.local
RUN mkdir /.docker
RUN chmod 777 -R /.docker && \
    chmod 777 -R /.local
RUN service ssh start
#RUN echo $USER
#RUN sudo usermod --add-subuids 200000-201000 --add-subgids 200000-201000 $USER
#RUN sudo usermod -a -G docker jenkins wheel
#RUN sudo usermod -a -G sudo jenkins wheel

    #sudo service docker start && \
    #sudo service docker enable && \
   # sudo service docker restart && \
   # sudo su && \
RUN echo  "jenkins   ALL=(ALL:ALL) ALL" >> /etc/sudoers 
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /home/ubuntu  


#CMD ["/usr/sbin/sshd", "-D"]
