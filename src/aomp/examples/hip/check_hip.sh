#/bin/bash
#
# Checks all tests in hip directory using make make run. Programs return 0 for success or a number > 0 for failure.
#
echo ""
echo ""

script_dir=$(dirname "$0")
pushd $script_dir
path=$(pwd)

echo ""
echo "RUNNING ALL TESTS IN: $path "
echo ""

echo "" > check-hip.txt
echo "" >> check-hip.txt
echo "Hip Results:" >> check-hip.txt
echo "*******A non-zero exit code means a failure occured.*******" >> check-hip.txt
echo "***********************************************************" >> check-hip.txt

skiptests="device_lib"

#Loop over all directories and make run / make check depending on directory name
for directory in ./*/; do 
	(cd "$directory" && path=$(pwd) && base=$(basename $path) 
		skip=0
		for test in $skiptests ; do
			if [ $test == $base ] ; then
				skip=1
				break
			fi
		done
		if [ $skip -ne 0 ] ; then
			echo "Skip $base!"
		else
			make clean
			make
		  if [ $? -ne 0 ]; then
			  echo "$base: Make Failed" >> ../check-hip.txt
		  else
		    make run
			  echo " Return Code for $base: $?" >> ../check-hip.txt
		  fi
		  make clean
		fi
	)
	
done

#Print run.log for all tests that need visual inspection
for directory in ./*/; do
	(cd "$directory" && path=$(pwd) && base=$(basename $path)
	)
done
cat check-hip.txt
popd
