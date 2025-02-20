# Đặt múi giờ mặc định (ví dụ: Asia/Ho_Chi_Minh)
ENV TZ=Asia/Ho_Chi_Minh
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Cài đặt các công cụ cần thiết
RUN apt install -y \
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
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt noVNC và Websockify
RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC && \
    cd /opt/noVNC && \
    git submodule update --init --recursive && \
    pip3 install websockify

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

# Chấp nhận license và cài đặt SDK cần thiết
RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools" "platforms;android-31" "system-images;android-31;google_apis;x86_64" "emulator"

# Tạo thiết bị ảo Android (AVD)
RUN echo "no" | avdmanager create avd -n my_avd -k "system-images;android-31;google_apis;x86_64"

# Cấu hình VNC (nếu cần)
RUN mkdir -p ~/.vnc && \
    echo "password" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# CMD: Chạy Xvfb, VNC và noVNC khi container khởi động
CMD Xvfb :0 -screen 0 1280x720x16 & \
    x11vnc -display :0 -forever -passwd password & \
    emulator -avd my_avd -no-audio -gpu swiftshader_indirect & \
    /opt/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 6080
