FROM nodeintegration/denv:latest

ARG VERSION=0.11.11

ENV NAME=terraform
ENV URL=https://releases.hashicorp.com/${NAME}/${VERSION}/${NAME}_${VERSION}_linux_amd64.zip
RUN cd /usr/local/bin/ \
    && curl -L ${URL} -o ${NAME}.zip \
    && unzip ${NAME}.zip \
    && chmod u+x ${NAME} \
    && rm ${NAME}.zip \
