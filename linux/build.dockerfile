FROM ubuntu:latest

# To run, in parent dir: docker build -t wordsearch-build-linux -f linux/build.dockerfile .
# Output is built to /build/build/linux/release TODO: Actually use output! :-)

# Get flutter deps.
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Europe/London apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev libblkid-dev liblzma-dev git curl unzip

# Get flutter.
RUN git clone https://github.com/flutter/flutter.git
ENV PATH ${PATH}:${HOME}/flutter/bin
RUN flutter channel dev && flutter upgrade && flutter config --enable-linux-desktop
RUN flutter precache

# Get build deps.
WORKDIR build
ADD pubspec.yaml .
RUN flutter pub get

# Build linux.
ADD assets assets
ADD lib lib
ADD linux linux
RUN ls
RUN flutter build linux