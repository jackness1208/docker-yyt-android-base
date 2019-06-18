FROM jackness1208/yyt-base:latest
WORKDIR /root

# 安装 Android SDK
ARG SDK_VERSION=sdk-tools-linux-3859397
ARG ANDROID_BUILD_TOOLS_VERSION=26.0.0
ARG ANDROID_PLATFORM_VERSION="android-25"

ENV SDK_VERSION=$SDK_VERSION \
  ANDROID_BUILD_TOOLS_VERSION=$ANDROID_BUILD_TOOLS_VERSION \
  ANDROID_HOME=/root

RUN wget -O tools.zip https://dl.google.com/android/repository/${SDK_VERSION}.zip && \
  unzip tools.zip && rm tools.zip && \
  chmod a+x -R $ANDROID_HOME && \
  chown -R root:root $ANDROID_HOME

ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin

# https://askubuntu.com/questions/885658/android-sdk-repositories-cfg-could-not-be-loaded
RUN mkdir -p ~/.android
RUN touch ~/.android/repositories.cfg
RUN echo y | sdkmanager "platform-tools"
RUN echo y | sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION"
RUN echo y | sdkmanager "platforms;$ANDROID_PLATFORM_VERSION"

ENV PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools

# 安装 appium
ARG APPIUM_VERSION=1.14.0-beta.1
ENV APPIUM_VERSION=$APPIUM_VERSION
RUN npm install -g appium@${APPIUM_VERSION} --unsafe-perm=true --allow-root

# 安装 appium-doctor
RUN npm i -g appium-doctor

# 设置 JAVA_HOME
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre" \
  PATH=$PATH:$JAVA_HOME/bin

# # 安装 cmake
RUN sudo wget https://cmake.org/files/v3.9/cmake-3.9.1-Linux-x86_64.tar.gz
RUN sudo tar zxvf cmake-3.9.1-Linux-x86_64.tar.gz
RUN sudo mv cmake-3.9.1-Linux-x86_64 /opt/cmake-3.9.1
RUN sudo ln -sf /opt/cmake-3.9.1/bin/*  /usr/bin/ 

RUN apt-get update
RUN apt-get install -y build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev

# # 安装 make
# RUN sudo apt-add-repository ppa:ubuntu-desktop/ubuntu-make
# RUN sudo apt-get update 
# RUN sudo apt-get install -y ubuntu-make 

# 安装 opencv4nodejs
RUN npm i -g opencv4nodejs

# 安装 ffmpeg
RUN apt-get install -y ffmpeg

# 安装 mjpeg-consumer
RUN npm i -g mjpeg-consumer

# 安装 bundletools
RUN wget -O bundletool.jar  https://github.com/google/bundletool/releases/download/0.9.0/bundletool-all-0.9.0.jar
RUN mv bundletool.jar ~/build-tools/${ANDROID_BUILD_TOOLS_VERSION}/
RUN chmod +x ~/build-tools/${ANDROID_BUILD_TOOLS_VERSION}/bundletool.jar
RUN echo 'PATH="$PATH:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION/"'>> ~/.bashrc

# 删除多余的文件
RUN rm -rf ~/cmake-3.9.1-Linux-x86_64.tar.gz
RUN rm -rf ~/google-chrome-stable_current_amd64.deb

# 开放端口
EXPOSE 4723

# copy tasks
COPY tasks/* /root/tasks/

RUN chmod -R 777 /root/tasks/

# 运行 entrypoint
CMD tasks/entry_point.sh


# TODO: vncd