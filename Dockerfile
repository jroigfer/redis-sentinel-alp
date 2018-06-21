FROM redis:3.2.12-alpine

RUN apk update --no-cache
RUN apk add openssh \
	vim \
	net-tools \
	bash \
	nmap 
#	software-properties-common \
#	python-software-properties \
#	supervisor
RUN apk update
RUN apk add --no-cache libevent-dev
RUN apk add --no-cache build-base
RUN apk add --no-cache bsd-compat-headers
RUN apk add --no-cache jansson-dev

RUN mkdir /var/log/redis
ADD ./redis.conf /redis.conf
ADD ./sentinel.conf /sentinel.conf

ADD ./start-redis.sh /start-redis.sh
RUN chmod 755 /start-redis.sh

ENTRYPOINT ["/start-redis.sh"]
