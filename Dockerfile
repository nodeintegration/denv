FROM python:3.7.2-alpine
MAINTAINER Brendan Beveridge <brendan@nodeintegration.com.au>
RUN mkdir /workspace
COPY boot /usr/local/bin/
COPY bootstrap /workspace/
# Some essential build tools
RUN apk add --no-cache curl jq \
    && pip install yq
WORKDIR /workspace
