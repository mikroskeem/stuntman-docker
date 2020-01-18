FROM clearlinux:latest

RUN swupd bundle-add curl c-basic devpkg-boost devpkg-openssl

# Build and install stuntman
RUN    cd /tmp \
    && curl -o stunserver.tgz http://www.stunprotocol.org/stunserver-1.2.15.tgz \
    && echo "321f796a7cd4e4e56a0d344a53a6a96d9731df5966816e9b46f3aa6dcc26210f  stunserver.tgz" > stunserver.tgz.checksum \
    && sha256sum -c stunserver.tgz.checksum \
    && tar -xvf stunserver.tgz \
    && cd stunserver \
    && make

# Install
RUN    cd /tmp/stunserver \
    && install -D -m 755 -o root -g root -s server/stunserver /opt/stunserver/stunserver \
    && install -D -m 755 -o root -g root -s client/stunclient /opt/stunserver/stunclient

FROM clearlinux:base

RUN mkdir /opt
COPY --from=0 /opt/stunserver /opt/stunserver

RUN useradd -s /bin/false -d / stun

USER stun
CMD ["/opt/stunserver/stunserver"]
