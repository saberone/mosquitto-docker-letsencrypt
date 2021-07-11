FROM python:3-alpine
LABEL maintainer synoniem https://github.com/synoniem

# Set environment variables.
ENV TERM=xterm-color
ENV SHELL=/bin/bash
# Use a shell script to select the right s6-overlay installer for the processor architecture
WORKDIR /
COPY ./build_internal.sh /build_internal.sh
RUN /build_internal.sh
# Choose needed packages.
RUN \
	mkdir /mosquitto && \
	mkdir /mosquitto/log && \
	mkdir /mosquitto/conf && \
	apk update && \
	apk upgrade && \
	apk add \
		bash \
		coreutils \
		nano \
        vim \
		curl \
        py3-crypto \
		ca-certificates \
        certbot \
		mosquitto \
		mosquitto-clients && \
	rm -f /var/cache/apk/* && \
    rm /build_internal.sh && \
	pip install --upgrade pip && \
	pip install pyRFC3339 configobj ConfigArgParse

COPY etc /etc
COPY certbot.sh /certbot.sh
COPY restart.sh /restart.sh
COPY croncert.sh /etc/periodic/weekly/croncert.sh
RUN \
	chmod +x /certbot.sh && \
	chmod +x /restart.sh && \
	chmod +x /etc/periodic/weekly/croncert.sh

ENTRYPOINT ["/init"]