FROM golang:latest
MAINTAINER Jason Waldrip <jason@waldrip.net>

# Install vault
RUN git clone https://github.com/hashicorp/vault --branch v0.6.1 $GOPATH/src/github.com/hashicorp/vault
RUN cd $GOPATH/src/github.com/hashicorp/vault && make bootstrap && make

# Install/Configure confd
RUN git clone https://github.com/kelseyhightower/confd --branch v0.12.0-alpha3 $GOPATH/src/github.com/kelseyhightower/confd
RUN cd $GOPATH/src/github.com/kelseyhightower/confd && go install
ADD confd /etc/confd

# Uninstall go
RUN rm $(which go)
RUN rm $(which gox)
RUN rm -rf /go/src
RUN rm -rf /go/pkg

# Workdir
RUN mkdir /workspace
WORKDIR /workspace

# Entrypoint
ADD entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]

# Expose Ports
EXPOSE 8200
EXPOSE 8201

# Default Config
VOLUME /vault
ENV VAULT_BACKEND file
ENV VAULT_HA true
ENV VAULT_BACKEND_FILE_PATH /vault

# Command
CMD [ "server" ]
