FROM docker.io/ubi8:latest
RUN echo $USER
# Make sure the package repository is up to date.
RUN yum update && \
# Install sudo
    yum install -qy sudo && \  
# Install git
    yum install -qy git && \
# install curl
    yum install -qy curl && \
# Install a basic SSH server
    yum install -qy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd && \
# Install JDK 11
    yum install -qy default-jdk && \
# Install podman
    apt update &&\
    yum install -qy podman && \  
# Install docker
    yum update &&\
    yum install -qy docker.io && \
   # sudo groupadd docker && \
   # sudo usermod -aG docker $USER && \
   # docker --version && \
# Install maven
    yum install -qy maven && \
# Cleanup old packages
    yum -qy autoremove && \
    
# Add user jenkins to the image
    #adduser --quiet jenkins && \
    useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 jenkins && \
# Set password for the jenkins user (you may want to alter this).
    echo "jenkins:MyPassword123" | chpasswd 
    #mkdir /home/jenkins/.m2

# Install grype 
  RUN curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
# install syft
  RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
# Copy authorized keys
COPY .ssh/authorized_keys /home/ubuntu/.ssh/authorized_keys

#RUN chown -R jenkins:jenkins /home/ubuntu/ && \
  #  chown -R jenkins:jenkins /home/ubuntu/.ssh/ 
    
# Standard SSH port
EXPOSE 22
RUN mkdir /.local
RUN mkdir /.docker && \
    mkdir /.config && \
    mkdir /.cache
    
RUN chmod 777 -R /.docker && \
    chmod 777 -R /.local && \
    chmod 777 -R /.config && \
    chmod 777 -R /.cache 
    
    
USER root     
RUN sudo chmod 777 -R /usr/bin/mount
#RUN sudo mount --make-rshared /
#RUN sudo chmod 666 /var/run/docker.sock

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
