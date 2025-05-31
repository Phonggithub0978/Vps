# Dockerfile: Ubuntu base with systemd & KVM support

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Cài đặt systemd và các gói cần thiết
RUN apt-get update && \
    apt-get install -y \
      systemd \
      systemd-sysv \
      dbus \
      kmod \
      sudo \
      iproute2 \
      iputils-ping \
      net-tools \
      openssh-server \
      qemu-kvm \
      virt-manager \
      libvirt-daemon-system \
      libvirt-clients \
      bridge-utils && \
    apt-get clean

# Tạo user "dev" có quyền sudo (tùy chọn)
RUN useradd -m dev && echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Chạy systemd làm PID 1
CMD ["/sbin/init"]
