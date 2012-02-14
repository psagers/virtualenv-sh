#!/bin/sh


function gen_function ()
{
    file=$1

	echo "function ${file##*/} ()"
    echo "{"

    cat ${file} | grep -v '^#!' | sed -e 's/^/    /'

    echo "}"
    echo
    echo
}


for file in "$@"; do
    gen_function ${file}
done

echo "virtualenv-sh-init";
