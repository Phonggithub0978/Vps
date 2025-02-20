# Sử dụng Ubuntu làm nền tảng
FROM ubuntu:20.04

# Cập nhật hệ thống và cài đặt các công cụ cần thiết
RUN apt update && apt install -y \
    openjdk-11-jdk \
    wget \
    unzip \
    git \
    curl \
    sudo \
    lsof \
    lib32stdc++6 \
    lib32z1 \
    pulseaudio \
    socat \
    net-tools \
    x11vnc \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt Android SDK
ENV ANDROID_HOME /opt/android-sdk
RUN mkdir -p $ANDROID_HOME/cmdline-tools \
    && cd $ANDROID_HOME/cmdline-tools \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip \
    && unzip cmdline-tools.zip -d tools \
    && mv tools cmdline-tools \
    && rm cmdline-tools.zip

# Cập nhật biến môi trường
ENV PATH $ANDROID_HOME/cmdline-tools/cmdline-tools/bin:$ANDROID_HOME/platform-tools:$PATH

# Chấp nhận license và cài đặt SDK
RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools" "platforms;android-31" "system-images;android-31;google_apis;x86_64" "emulator"

# Tạo thiết bị ảo Android (AVD)
RUN echo "no" | avdmanager create avd -n my_avd -k "system-images;android-31;google_apis;x86_64"

# Cấu hình X11VNC để hiển thị emulator qua VNC
RUN mkdir -p ~/.vnc && \
    echo "password" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# Mở cổng VNC để kết nối
EXPOSE 5900

# Chạy emulator ở chế độ headless (không có GUI)
CMD ["sh", "-c", "Xvfb :0 -screen 0 1280x720x16 & x11vnc -display :0 -forever -passwd password & emulator -avd my_avd -no-audio -no-window -gpu swiftshader"]
