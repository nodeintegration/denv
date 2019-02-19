# Just a handy docker image that contains the suite of hashicorp products

## How it works?
This image gives you a nice wrapper to run any hashicorp product inside a container as if it was a local binary
```
$ source /dev/stdin <<< "$(docker run nodeintegration/hashicorp-tools:latest boot)"
Binding to tag: latest
```
What this command does is give you a bunch of bash functions:
```
$ type terraform
terraform is a function
terraform ()
{
    hashicorp-helper terraform ${@}
}

$ type hashicorp-helper
hashicorp-helper is a function
hashicorp-helper ()
{
    export HASHICORP_HELPER_TAG=${HASHICORP_HELPER_TAG:-$HASHICORP_HELPER_LAUNCH_TAG};
    export HASHICORP_HELPER_INTERACTIVE=${HASHICORP_HELPER_INTERACTIVE:-true};
    local HASHICORP_HELPER_EXTRA_OPTS='';
    if [ "${HASHICORP_HELPER_INTERACTIVE}" == 'true' ]; then
        HASHICORP_HELPER_EXTRA_OPTS+=' -it';
    fi;
    local env_file='.env.hashicorp';
    local env_file_args='';
    local additional_envs_args='';
    if [ -f "${env_file}" ]; then
        for e in $(cut -d '=' -f 1 < ${env_file} | grep -v '^#');
        do
            if [ ! -z ${!e+x} ]; then
                additional_envs_args+=" -e ${e}";
            else
                v=$(grep "^${e}=" ${env_file} | cut -d '=' -f 2);
                if [ -n "${v}" ]; then
                    additional_envs_args+=" -e ${e}=\"${v}\"";
                fi;
            fi;
        done;
    fi;
    docker run --rm -u $(id -u):$(id -g) -v ${PWD}:/workspace ${HASHICORP_HELPER_EXTRA_OPTS} ${additional_envs_args} ${env_file_args} nodeintegration/hashicorp-tools:${HASHICORP_HELPER_TAG} ${@}
}
```
What this essentially does is create wrappers for each tool which then will perform a docker run command with the correct invocation for your needs
You can then use it like so (notice that the local version of terraform i have on my machine is a different version to what the wrapper provides within the container:
```
$ /usr/local/bin/terraform --version
Terraform v0.11.7

Your version of Terraform is out of date! The latest version
is 0.11.11. You can update by downloading from www.terraform.io/downloads.html
$ terraform --version
Terraform v0.11.11
```

One thing to note is that it mounts your current directory into /workspace which is the working dir of the container.


## Configuration
The boot script function takes a couple of things into account:
  * HASHICORP_HELPER_TAG - This environment variable if present in your shell will select what image tag to use for hashicorp-tools, if it is not specified it falls back to what ever you sourced the boot command from
  * HASHICORP_HELPER_INTERACTIVE - This environment variable if set to 'true' will make the resulting docker run contain an interactive terminal (-it) in the resulting docker run command
  * .env.hashicorp - If this file exists in your current working directory the function will load any environment variables you have in there (simple VAR=VALUE) if you want to make sure the value is loaded from your current shell you would just put: `VAR=`

## Tools supplied
### Packer 1.3.4
### Vagrant 2.2.3
### Terraform 0.11.11
### Consul 1.4.2
### Vault 1.0.3
### Nomad 0.8.7
