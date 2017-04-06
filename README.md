# Docker Shims

This is an opinionated technique for making commands inside docker containers 'feel' like commands on the host system.

## Why?

Say you want to be able to use something like the vscode-ruby extension for Visual Studio Code, 
but for some reason you don't want to (or can't) install ruby on your system. Well, you could 
fork the extension and make it work with a command like `docker run ruby ...`, but that's a 
lot of work, especially if there are other tools you want to use in this way. What if instead, 
you could create an executable file on your system that _acts_ just like the real life `ruby` 
binary, but doesn't actually require you to install ruby directly on your machine?

That's what this technique is for.

## Usage

1. Fork this repo
2. For each command you want to shim, create a directory and a Dockerfile that can produce a container capable of running that command.
3. Add the command name to the `commands` file along with the name of the directory you just created.
4. Add any additional flags for `docker run` (e.g. a persistent volume, etc.)
5. Run `install.sh` in order to build the docker images, tag them based on their directory names, and generate executable shims in `$HOME/bin` which act just like the original.

## Notes

The generated shim runs `docker run` with a bunch of flags. Here is an explanation of why each piece exists:

`docker run --rm -v "$(pwd)":/workdir -w /workdir -i {imageName} {cmdName} "$@"`

| Flag                   | Description                                                                                                                                                                                                                                             |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `--rm`                 | By default, docker will leave the container's file system around. For one off commands, this leads to tons of wasted space, so we tell docker to delete the filesystem as soon as the process exits.                                                    |
| `-v "$(pwd)":/workdir` | Here we bind the current _host_ directory to the _container_ path `/workdir`                                                                                                                                                                            |
| `-w /workdir`          | Set the _container_ working directory to `/workdir`. Combined with the -v flag, this means the command will be able to act on any file in the current working directory directly, which gets us closer to the goal of making the command _feel_ native. |
| `-i`                   | `-i` causes stdin to remain open even if the container is not attached, which allows certain interactive programs to work correctly. This is only enabled if the shim is running interactively.                                                         |
| `-t`                   | `-t` tells docker to allocate a TTY for the process. This makes things like repls work correctly. This is only enabled if the shim is running interactively.                                                                                            |
| {imageName}            | The name of the docker image to execute with.                                                                                                                                                                                                           |
| {cmdName}              | The command to execute.                                                                                                                                                                                                                                 |
| "$@"                   | This passes any options from the command line down to the process in the container                                                                                                                                                                      |
