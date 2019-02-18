FROM alpine:3.8
MAINTAINER Brendan Beveridge <brendan@nodeintegration.com.au>
RUN mkdir /workspace
COPY boot /usr/local/bin/
COPY bootstrap /workspace/
# Some essential build tools
RUN apk add --no-cache curl
WORKDIR /workspace
