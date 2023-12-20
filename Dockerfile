FROM alpine:edge

WORKDIR /build

RUN --mount=type=cache,target=/var/cache/apk \
    --mount=type=cache,target=/var/lib/apk \
    apk add --no-cache gcc \
    libc-dev \
    make \
    pcre-dev \
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

COPY *.conf nginx.*d ./
COPY setup-user.sh .

RUN ./setup-user.sh

COPY build.sh .

RUN ./build.sh
