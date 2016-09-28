FROM golang:latest
MAINTAINER Jason Waldrip <jason@waldrip.net>

# Install vault
RUN go get -v github.com/hashicorp/vault

# Install/Configure confd
RUN go get -v github.com/kelseyhightower/confd
ADD confd /etc/confd

# Entrypoint
ADD entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]

# Expose Ports
EXPOSE 8200

# Default Config
VOLUME /vault
ENV VAULT_BACKEND file
ENV VAULT_HA true
ENV VAULT_BACKEND_FILE_PATH /vault

# Command
CMD [ "server" ]
