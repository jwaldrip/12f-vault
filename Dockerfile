FROM cgswong/vault
MAINTAINER Oded Lazar <oded@senexx.com>

# create a stub entrypoint

RUN mkdir /entrypoint && \
echo '#!/bin/bash'  >> /entrypoint/bootstrap.sh && \
echo 'exec "$@"' >> /entrypoint/bootstrap.sh && \
chmod 755 /entrypoint/bootstrap.sh

ENTRYPOINT [ "/entrypoint/bootstrap.sh" ]

# add default configuration

RUN mkdir /vault
ADD vault.hcl run.sh /vault/

CMD [ "/vault/run.sh" ]
