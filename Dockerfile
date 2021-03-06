FROM alpine:edge

WORKDIR /build

RUN apk add --no-cache gcc \
    libc-dev \
    make \
    pcre-dev \
    zlib-dev \
    curl \
    git \
    cmake \
    patch \
    rust \
    cargo \
    g++ \
    linux-headers \
    openssl

COPY *.conf nginx.*d ./
COPY build.sh .

RUN ./build.sh
