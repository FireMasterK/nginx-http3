FROM alpine:edge

WORKDIR /build

RUN --mount=type=cache,target=/var/cache/apk \
    --mount=type=cache,target=/var/lib/apk \
    apk add --no-cache gcc \
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
COPY setup-user.sh .

RUN ./setup-user.sh
RUN ./build.sh
