# Builder
FROM   devops-registry.laiye.com:5000/build/golang:alpine  AS builder
RUN apk add git
WORKDIR /
RUN git@git.laiye.com:liaoyuandong/chatgpt-for-chatbot-feishu.git
WORKDIR /build

COPY go.mod ./
COPY go.sum ./
ENV GOPROXY https://goproxy.cn

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 \
  GOOS=linux \
  go build -o chatgpt-for-chatbot-feishu

# Server
FROM docker.friddle.me/whatwewant/go:v1.20-1

# FROM whatwewant/zmicro:v1

LABEL MAINTAINER="Zero<tobewhatwewant@gmail.com>"

LABEL org.opencontainers.image.source="https://github.com/go-zoox/chatgpt-for-chatbot-feishu"

ARG VERSION=latest

ENV MODE=production

COPY --from=builder /build/chatgpt-for-chatbot-feishu /bin

ENV VERSION=${VERSION}

RUN zmicro package install ngrok

# RUN zmicro package install cpolar

COPY ./entrypoint.sh /

CMD /entrypoint.sh
