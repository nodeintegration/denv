# denv (docker environment)

## How it works?
These images give you a nice wrapper to run arbitrary commands as well as all of the nodeintegration/denv-\* image commands inside a container as if it was a local binary
```
$ source /dev/stdin <<< "$(docker run nodeintegration/denv:latest boot)"
Binding to tag: latest
```
What this command does is give a denv function in bash:
```
$ type denv
denv is a function
denv ()
{
    local DENV_IMAGE=nodeintegration/denv;
    local DENV_IMAGE_TAG=${DENV_IMAGE_TAG:-${DENV_TAG}};
    local additional_envs_args='';
    if [ -f .denv.yml ]; then
        local global_envs=$(yq -r ".global.environment | keys[] // empty" .denv.yml);
        for e in ${global_envs};
        do
            if [ ! -z ${!e+x} ]; then
                additional_envs_args+=" -e ${e}";
            else
                local v=$(yq -r ".global.environment.${e} // empty" .denv.yml);
                if [ -n "${v+set}" ]; then
                    additional_envs_args+=" -e ${e}=\"${v}\"";
                fi;
            fi;
        done;
        local cmd_config=$(yq -r ".commands.${1} // empty" .denv.yml);
        if [ -n "${cmd_config}" ]; then
            local image=$(yq -r ".commands.${1}.image // empty" .denv.yml);
            DENV_IMAGE=${image:-$1};
            local tag=$(yq -r ".commands.${1}.tag // empty" .denv.yml);
            DENV_IMAGE_TAG=${tag:-latest};
        fi;
    fi;
    DENV_INTERACTIVE=${DENV_INTERACTIVE:-true};
    DENV_EXTRA_OPTS='';
    if [ "${DENV_INTERACTIVE}" == 'true' ]; then
        DENV_EXTRA_OPTS+=' -it';
    fi;
    docker run --rm -u $(id -u):$(id -g) -v ${PWD}:/workspace ${DENV_EXTRA_OPTS} ${additional_envs_args} ${env_file_args} ${DENV_IMAGE}:${DENV_IMAGE_TAG} ${@}
}

```
What this `denv` function does is create a wrapper to run the first argument to denv as a container.
By default the command will run inside the denv container with your current working directory mounted to /workspace. It is also run as your current uid/gid
```
$ cat /etc/issue
Ubuntu 18.04.2 LTS \n \l

$ denv cat /etc/issue
Welcome to Alpine Linux 3.9
Kernel \r on an \m (\l)
```

## .denv.yml

###Commands run as different docker images/tags
This is where it gets fun.
The function `denv` looks for a file .denv.yml in your current working directory
It then looks for a key: `commands:`
and then if there is a sub key called the first argument you supply to denv ie:
```
cat .denv.yml
commands:
  bash:
```
denv will then change the docker run image to be `bash` for the command `bash`
with the tag of `latest`

Then lets say i want to run an image that doesnt match the command:
```
commands:
  terraform:
    image: hashicorp/terraform
```

denv will then for the command terraform use the `hashicorp/terraform` image with the default tag of `latest`

...ok...ok but i want a specific tag not latest:
```
commands:
  terraform:
    image: hashicorp/terraform
    tag: 0.11.11
```

### I want environment variables passed to the commands run time
Easy peasy:
```
global:
  environment:
    FOO:
    BAR: baz
```
This will give you FOO and BAR as docker run environment variables
It WILL use your current shells environment variables over the .denv.yml value e.g. with the above .denv.yml:
```
$ denv env | grep -E '^(FOO|BAR)'
BAR="baz"
FOO=""

$ FOO="bar" denv env | grep -E '^(FOO|BAR)'
BAR="baz"
FOO=bar
```
