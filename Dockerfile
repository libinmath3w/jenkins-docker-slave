# stable/Containerfile
#
# Build a Podman container image from the latest
# stable version of Podman on the Fedoras Updates System.
# https://bodhi.fedoraproject.org/updates/?search=podman
# This image can be used to create a secured container
# that runs safely with privileges within the container.
#
FROM redhat/ubi8:latest

# Don't include container-selinux and remove
# directories used by dnf that are just taking
# up space.
# TODO: rpm --setcaps... needed due to Fedora (base) image builds
#       being (maybe still?) affected by
#       https://bugzilla.redhat.com/show_bug.cgi?id=1995337#c3
RUN dnf -y update && \
    rpm --setcaps shadow-utils 2>/dev/null && \
    dnf -y install podman fuse-overlayfs \
        --exclude container-selinux && \
    dnf clean all && \
    rm -rf /var/cache /var/log/dnf* /var/log/yum.*

RUN yum update -qy && \
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
    yum install -qy java-11-openjdk && \

# Install maven
    yum install -qy maven && \
# Cleanup old packages
    yum -qy autoremove 
    
    # Install grype 
RUN curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
# install syft
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

    
    
RUN useradd podman; \
echo -e "podman:1:999\npodman:1001:64535" > /etc/subuid; \
echo -e "podman:1:999\npodman:1001:64535" > /etc/subgid;

ARG _REPO_URL="https://raw.githubusercontent.com/containers/podman/main/contrib/podmanimage/stable"
ADD $_REPO_URL/containers.conf /etc/containers/containers.conf
ADD $_REPO_URL/podman-containers.conf /home/podman/.config/containers/containers.conf

RUN mkdir -p /home/podman/.local/share/containers && \
    chown podman:podman -R /home/podman && \
    chmod 644 /etc/containers/containers.conf && \
    touch /usr/share/containers/storage.conf 
    
RUN chmod 777 /usr/share/containers/storage.conf
    
RUN echo "[storage]" >> /usr/share/containers/storage.conf 
RUN echo '   driver = "fuse-overlayfs"' >> /usr/share/containers/storage.conf
RUN echo '   graphroot = "/home/podman/.local/share/containers"' >> /usr/share/containers/storage.conf   
    

# Copy & modify the defaults to provide reference if runtime changes needed.
# Changes here are required for running with fuse-overlay storage inside container.
RUN sed -i -e 's|^#mount_program|mount_program|g' \
           -e '/additionalimage.*/a "/var/lib/shared",' \
           -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' \
           /usr/share/containers/storage.conf \
           > /etc/containers/storage.conf

# Note VOLUME options must always happen after the chown call above
# RUN commands can not modify existing volumes
VOLUME /var/lib/containers
VOLUME /home/podman/.local/share/containers
#RUN echo "[storage.options]" >> /usr/share/containers/storage.conf 
#RUN echo 'mount_program = "/bin/fuse-overlayfs"' >> /usr/share/containers/storage.conf 

RUN mkdir -p /var/lib/shared/overlay-images \
             /var/lib/shared/overlay-layers \
             /var/lib/shared/vfs-images \
             /var/lib/shared/vfs-layers && \
    touch /var/lib/shared/overlay-images/images.lock && \
    touch /var/lib/shared/overlay-layers/layers.lock && \
    touch /var/lib/shared/vfs-images/images.lock && \
    touch /var/lib/shared/vfs-layers/layers.lock
    
RUN mkdir /.local && \
  # mkdir /.docker && \
    mkdir /.config && \
    mkdir /.cache \
    
RUN chmod 777 /.docker && \
    chmod 777 /.local && \
    chmod 777 /.config && \
    chmod 777 /.cache 
    

ENV _CONTAINERS_USERNS_CONFIGURED=""
