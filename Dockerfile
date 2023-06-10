FROM alpine:latest as downloader
ENV VERSION=5.6.0
WORKDIR /workspace
RUN apk add curl
RUN curl -LJO https://github.com/v2fly/v2ray-core/archive/refs/tags/v${VERSION}.tar.gz && tar xvzf v2ray-core-${VERSION}.tar.gz && mv v2ray-core-${VERSION} v2ray-core

FROM golang:1.20 as builder
WORKDIR /workspace
COPY --from=downloader /workspace/v2ray-core .
RUN go mod download
RUN CGO_ENABLED=0 go build -o ./v2ray -trimpath -ldflags "-s -w -buildid=" ./main

FROM ubuntu:22.04
WORKDIR /
COPY --from=builder /workspace/v2ray .
ENTRYPOINT ["/v2ray"]
