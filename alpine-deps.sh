#!/bin/sh

apk add gcc \
    libc-dev \
    make \
    pcre-dev \
    zlib-dev \
    curl \
    git \
    cmake \
    patch \
    mold \
    gcc \
    clang \
    llvm-dev \
    linux-headers \
    openssl \
    perl

ARCH=$(uname -m)

if [ "$ARCH" = "arm64" ]; then
    ARCH="arm64"
elif [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
else
    echo "Unknown architecture: $ARCH"
    exit 1
fi

curl -L "https://github.com/hatoo/oha/releases/latest/download/oha-linux-$ARCH" \
    -o /usr/local/bin/oha
