FROM registry.fedoraproject.org/fedora:latest
USER root
WORKDIR /root
RUN --mount=type=bind,source=dist/fedora,target=/mnt/dist,Z bash /mnt/dist/install/root.bash
RUN --mount=type=bind,source=dist/fedora,target=/mnt/dist,Z bash /mnt/dist/install/homes.bash
USER box
WORKDIR /home/box
RUN --mount=type=bind,source=dist/fedora,target=/mnt/dist,Z bash /mnt/dist/install/box.bash
USER root
WORKDIR /root
CMD ["/sbin/init"]
