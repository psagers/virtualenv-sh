#!/bin/sh


for file in $*; do
	echo "${file##*/}()"
    echo "{"

    cat ${file} | grep -v '^#!' | sed -e 's/^/    /'

    echo "}"
    echo
    echo
done

echo "virtualenv_sh_init";
