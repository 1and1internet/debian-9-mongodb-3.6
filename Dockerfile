FROM golang as configurability
MAINTAINER brian.wilkinson@1and1.co.uk
WORKDIR /go/src/github.com/1and1internet/configurability
RUN git clone https://github.com/1and1internet/configurability.git . \
       && make main mongod \
       && echo "configurability successfully built"

FROM 1and1internet/debian-8
MAINTAINER brian.wilkinson@1and1.co.uk

COPY files/ /
COPY --from=configurability /go/src/github.com/1and1internet/configurability/bin/configurator /usr/bin/configurator
COPY --from=configurability /go/src/github.com/1and1internet/configurability/bin/plugins/* /opt/configurability/goplugins/

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
	&& apt-get update \
	&& apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5 \
	&& apt-get update \
	&& apt-get install -y mongodb-org \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /var/log/mongodb \
	&& chmod 777 /var/log/mongodb /var/lib/mongodb \
    && chmod 666 /etc/mongod.conf

ENV ADMINUSER=defaultadminuser \
	ADMINPASS=defaultadminpass
