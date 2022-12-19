FROM alpine:edge

WORKDIR /build

RUN --mount=type=cache,target=/var/cache/apk \
    --mount=type=cache,target=/var/lib/apk \
    apk add --no-cache gcc \
    libc-dev \
    make \
    pcre-dev \
    zlib-dev \
    zstd-dev \
    liburing-dev \
    libatomic_ops-dev \
    curl \
    git \
    cmake \
    patch \
    rust \
    cargo \
    g++ \
    linux-headers \
    openssl \
    bash

COPY *.conf nginx.*d ./
COPY build.sh .

RUN ./build.sh
