#!/bin/bash

set -e

# Build all the Dockerfiles into images named after their directories.
for file in *; do
    if [[ -f $file/Dockerfile ]]; then
        echo "Building image: $file"
        docker build -t $file $file
    fi
done

mkdir -p $HOME/bin

# Write out shims for the commands specified in the commands file
while read cmd; do
    parts=($cmd);
    cmdName=${parts[0]}
    imageName=${parts[1]}
    additionalFlags=${parts[@]:2}
    shimName=$HOME/bin/$cmdName
    echo "Writing $imageName.$cmdName shim"

    cat > $shimName << EOF
#!/bin/bash -i

case "\$-" in
    *i*)
        docker run --rm $additionalFlags -v "\$(pwd)":/workdir -w /workdir -it $imageName $cmdName "\$@";;
    *)
        docker run --rm $additionalFlags -v "\$(pwd)":/workdir -w /workdir $imageName $cmdName "\$@";;
esac

EOF
    chmod +x $shimName
done < commands
