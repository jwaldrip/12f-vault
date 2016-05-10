FROM cgswong/vault:latest
MAINTAINER Oded Lazar <oded@senexx.com>

# install curl
RUN apk-install --no-cache curl

# create a stub entrypoint
RUN mkdir /entrypoint && \
  echo '#!/bin/bash'  >> /entrypoint/bootstrap.sh && \
  echo 'exec "$@"' >> /entrypoint/bootstrap.sh && \
  chmod 755 /entrypoint/bootstrap.sh

ENTRYPOINT [ "/entrypoint/bootstrap.sh" ]

ENV VAULT_LOG_LEVEL info

RUN mkdir /vault
ADD vault.hcl run.sh /vault/

CMD [ "/vault/run.sh" ]
