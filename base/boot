#!/usr/bin/env sh

cat << EOF
export DENV_TAG=\$(docker ps -a --filter 'id=${HOSTNAME}' --format {{.Image}} |cut -f 2 -d :)
echo Binding to tag: \${DENV_TAG}
EOF
cat bootstrap
