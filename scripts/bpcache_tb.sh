#!/bin/bash

pwd

pushd . > /dev/null

while [ $PWD != "/" ]
do
	cd .. || true
	if [ $(basename $PWD) = "RISC-V" ]
	then
		break
	fi
done
echo -e "Moving to $PWD"

mkdir -p out

# PUT YOUR FILES IN HERE
read -r -d '' FILES <<- EOM
bpcache.sv
bpcache_tb.sv
EOM
# ONLY MODIFY THE ABOVE STUFF

TMP=$0;
# The build command
find * -print | grep -v "\.swp" | grep -F "$FILES" | xargs iverilog -g2012 -o "out/${TMP%.*}.out"

# Now run it

exec "out/${TMP%.*}.out"

echo "Returning to current directory"
popd > /dev/null
