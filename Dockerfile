FROM ubuntu:latest as installer

RUN apt-get update
RUN apt-get install -y curl
RUN curl -L -o /tmp/go.sh https://install.direct/go.sh
RUN chmod +x /tmp/go.sh
RUN /tmp/go.sh

FROM alpine:latest

LABEL maintainer "Abreto Fu <m@abreto.net>"

COPY --from=installer /usr/bin/v2ray/v2ray /usr/bin/v2ray/
COPY --from=installer /usr/bin/v2ray/v2ctl /usr/bin/v2ray/
COPY --from=installer /usr/bin/v2ray/geoip.dat /usr/bin/v2ray/
COPY --from=installer /usr/bin/v2ray/geosite.dat /usr/bin/v2ray/
COPY --from=installer /etc/v2ray/config.json /etc/v2ray/

RUN set -ex && \
    apk --no-cache add ca-certificates && \
    mkdir /var/log/v2ray/ &&\
    chmod +x /usr/bin/v2ray/v2ctl && \
    chmod +x /usr/bin/v2ray/v2ray

ENV PATH /usr/bin/v2ray:$PATH

ENTRYPOINT ["v2ray", "-config=/etc/v2ray/config.json"]
