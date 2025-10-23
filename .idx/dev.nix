{ pkgs, ... }: {
  channel = "stable-24.11";

  packages = [
    pkgs.docker
    pkgs.cloudflared
    pkgs.socat
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.sudo
    pkgs.apt
    pkgs.systemd
    pkgs.unzip

    # ⚙️ Thêm hỗ trợ ảo hóa KVM/QEMU
    pkgs.qemu_kvm
    pkgs.libvirt
  ];

  services.docker.enable = true;

  idx.workspace.onStart = {
    novnc = ''
set -e

# 🧹 One-time cleanup (chỉ chạy lần đầu)
if [ ! -f /home/user/.cleanup_done ]; then
  rm -rf /home/user/.gradle/* /home/user/.emu/*
  find /home/user -mindepth 1 -maxdepth 1 ! -name 'idx-ubuntu22-gui' ! -name '.*' -exec rm -rf {} +
  touch /home/user/.cleanup_done
fi

# 📦 Tạo thư mục lưu dữ liệu vĩnh viễn
mkdir -p /home/user/ubuntu_data

# 🐳 Tạo container nếu chưa có, hoặc khởi động lại nếu đã tồn tại
if ! docker ps -a --format '{{.Names}}' | grep -qx 'ubuntu-novnc'; then
  docker run --name ubuntu-novnc \
    --shm-size 1g -d \
    --cap-add=SYS_ADMIN \
    --privileged \                          # cho phép KVM/nested virtualization
    --device /dev/kvm:/dev/kvm \            # gắn thiết bị /dev/kvm vào container
    -p 8080:10000 \
    -e VNC_PASSWD=12345678 \
    -e PORT=10000 \
    -e AUDIO_PORT=1699 \
    -e WEBSOCKIFY_PORT=6900 \
    -e VNC_PORT=5900 \
    -e SCREEN_WIDTH=1024 \
    -e SCREEN_HEIGHT=768 \
    -e SCREEN_DEPTH=24 \
    -v /home/user/ubuntu_data:/home/user \  # mount thư mục để lưu dữ liệu
    thuonghai2711/ubuntu-novnc-pulseaudio:22.04
else
  docker start ubuntu-novnc || true
fi

# 🌐 Cài Google Chrome trong container
docker exec -it ubuntu-novnc bash -lc "
  sudo apt update &&
  sudo apt remove -y firefox || true &&
  sudo apt install -y wget &&
  sudo wget -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&
  sudo apt install -y /tmp/chrome.deb &&
  sudo rm -f /tmp/chrome.deb
"

# ☁️ Khởi chạy Cloudflared tunnel
nohup cloudflared tunnel --no-autoupdate --url http://localhost:8080 \
  > /tmp/cloudflared.log 2>&1 &

# ⏱️ Chờ khởi động
sleep 10

# 🔗 In ra URL truy cập
if grep -q "trycloudflare.com" /tmp/cloudflared.log; then
  URL=$(grep -o "https://[a-z0-9.-]*trycloudflare.com" /tmp/cloudflared.log | head -n1)
  echo "========================================="
  echo " 🌍 Your Cloudflared tunnel is ready:"
  echo "     $URL"
  echo "========================================="
else
  echo "❌ Cloudflared tunnel failed, check /tmp/cloudflared.log"
fi

# ⏳ Giữ cho workspace không tắt
elapsed=0; while true; do echo "Time elapsed: $elapsed min"; ((elapsed++)); sleep 60; done
'';
  };

  idx.previews = {
    enable = true;
    previews = {
      novnc = {
        manager = "web";
        command = [
          "bash" "-lc"
          "socat TCP-LISTEN:$PORT,fork,reuseaddr TCP:127.0.0.1:8080"
        ];
      };
    };
  };
}
