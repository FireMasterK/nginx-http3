#!/bin/sh
docker build . -t nginx-http3 --progress=plain 2>&1 | tee build.log
