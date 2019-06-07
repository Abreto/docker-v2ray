FROM ubuntu:latest as installer

RUN apt-get update
RUN apt-get install -y curl apt-utils
RUN curl -L -o /tmp/go.sh https://install.direct/go.sh
RUN chmod +x /tmp/go.sh
RUN /tmp/go.sh

FROM alpine:latest

LABEL maintainer "Abreto Fu <m@abreto.net>"

COPY --from=installer /usr/bin/v2ray/v2ray /usr/bin/v2ray/
COPY --from=installer /usr/bin/v2ray/v2ctl /usr/bin/v2ray/
COPY --from=installer /usr/bin/v2ray/geoip.dat /usr/bin/v2ray/
COPY --from=installer /usr/bin/v2ray/geosite.dat /usr/bin/v2ray/
COPY config.json /etc/v2ray/

RUN set -ex && \
  apk update && \
    apk add --update ca-certificates tzdata && \
    rm -rf /var/cache/apk/* && \
    mkdir /var/log/v2ray/ && \
    chmod +x /usr/bin/v2ray/v2ctl && \
    chmod +x /usr/bin/v2ray/v2ray

ENV TZ=Asia/Shanghai
ENV PATH /usr/bin/v2ray:$PATH
ENV V2RAY_PORT 8008

EXPOSE ${V2RAY_PORT}

ENTRYPOINT ["v2ray", "-config=/etc/v2ray/config.json"]
