# denv (docker environment)

## How it works?
These images give you a nice wrapper to run arbitrary commands as well as all of the nodeintegration/denv-\* image commands inside a container as if it was a local binary
```
$ source /dev/stdin <<< "$(docker run nodeintegration/denv:latest boot)"
Binding to tag: latest
```
What this command does is give you a bunch of bash functions:
```
$ type _denv-runner
_denv-runner is a function
_denv-runner ()
{
    DENV_INTERACTIVE=${DENV_INTERACTIVE:-true};
    DENV_EXTRA_OPTS='';
    if [ "${DENV_INTERACTIVE}" == 'true' ]; then
        DENV_EXTRA_OPTS+=' -it';
    fi;
    local env_file='.env.denv';
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
    docker run --rm -u $(id -u):$(id -g) -v ${PWD}:/workspace ${DENV_EXTRA_OPTS} ${additional_envs_args} ${env_file_args} nodeintegration/${DENV_IMAGE}:${DENV_IMAGE_TAG} ${@}
}

$ type denv
denv is a function
denv ()
{
    DENV_IMAGE=denv;
    DENV_IMAGE_TAG=${DENV_IMAGE_TAG:-${DENV_TAG}};
    _denv-runner ${@}
}

$ type terraform
terraform is a function
terraform ()
{
    DENV_IMAGE=denv-terraform;
    TERRAFORM_VERSION=${TERRAFORM_VERSION:-latest};
    DENV_IMAGE_TAG=${TERRAFORM_VERSION};
    _denv-runner terraform ${@}
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
  * DENV_TAG - This environment variable if present in your shell will select what image tag to use for denv, if it is not specified it falls back to what ever you sourced the boot command from
  * DENV_INTERACTIVE - This environment variable by default is 'true' which will make the resulting docker run contain an interactive terminal (-it) in the resulting docker run command, setting this to anything other than true will result in it not being an interactive terminal (ie you may want this in a ci/cd environment)
  * .env.dev - If this file exists in your current working directory the function will load any environment variables you have in there (simple VAR=VALUE) if you want to make sure the value is loaded from your current shell you would just put: `VAR=`

## available tools for denv can be looked up via https://dockerhub.com/r/nodeintegration/ denv-\*
