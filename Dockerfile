FROM golang:latest AS builder
WORKDIR /app
ADD tailscale /app/tailscale
# build modified derper
RUN cd /app/tailscale/cmd/derper && \
    /usr/local/go/bin/go build -buildvcs=false -ldflags "-s -w" -o /app/derper && \
    cd /app && \
    rm -rf /app/tailscale


FROM dockerproxy.com/phusion/baseimage:18.04-1.0.0
ADD ./ssl /app/certs
COPY --from=builder /app/derper /app/derper
# ========= CONFIG =========
# - derper args
ENV DERP_CERTS=/app/certs/
ENV DERP_STUN true
ENV DERP_VERIFY_CLIENTS false
ENV DERP_CERT_MODE=manual
ENV DERP_ADDR=:12345
ENV DERP_DOMAIN=net.lyhepj.cn
WORKDIR /app
CMD sh -c "/app/derper \
    --hostname=$DERP_DOMAIN \
    --certmode=$DERP_CERT_MODE \
    --certdir=$DERP_CERTS \
    --stun=$DERP_STUN  \
    --a=$DERP_ADDR \
    --verify-clients=$DERP_VERIFY_CLIENTS"




