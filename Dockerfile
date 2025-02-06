# Builder
FROM   devops-registry.laiye.com:5000/build/golang:alpine  AS builder
RUN apk add git
WORKDIR /build

COPY go.mod ./

COPY go.sum ./

RUN go mod download

COPY . .
RUN cd ..&&git clone git@github.com:friddle/chatgpt-client.git

RUN CGO_ENABLED=0 \
  GOOS=linux \
  go build -o chatgpt-for-chatbot-feishu

# Server
FROM  devops-registry.laiye.com:5000/build/golang:alpine
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
