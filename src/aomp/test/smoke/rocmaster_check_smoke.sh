#!/bin/bash
#
# Checks all tests in smoke directory using make check. Programs return 0 for success or a number > 0 for failure.
# Tests that need to be visually inspected: devices, pfspecify, pfspecify_str, stream
#
#

export AOMP=/opt/rocm/aomp

cleanup(){
  rm -rf check-smoke.txt
  rm -rf passing-tests.txt
  rm -rf failing-tests.txt
  rm -rf make-fail.txt
}

#Clean all testing directories
make clean
cleanup

path=$(pwd)
echo ""
echo "RUNNING ALL TESTS IN: $path"
echo ""

echo "************************************************************************************" > check-smoke.txt
echo "                   A non-zero exit code means a failure occured." >> check-smoke.txt
echo "***********************************************************************************" >> check-smoke.txt

skiptests="devices pfspecifier pfspecifier_str target_teams_reduction hip_rocblas tasks reduction_array_section extern_init targ_static complex omp_wtime"

#Loop over all directories and make run / make check depending on directory name
for directory in ./*/; do
  (cd "$directory" && path=$(pwd) && base=$(basename $path)
     skip=0
     #if [[ $skiptests == " $base " ]] ; then
     for test in $skiptests ; do
       if [ $test == $base ] ; then 
         skip=1
         break
       fi
     done
    if [ $skip -ne 0 ] ; then
      echo "Skip $base!"
    
    #flags has multiple runs
    elif [ $base == 'flags' ] ; then
      make
      make run > /dev/null 2>&1
    else
      make
      if [ $? -ne 0 ]; then
        echo "$base: Make Failed" >> ../make-fail.txt
      fi
      make check > /dev/null 2>&1
      #liba_bundled has an additional Makefile, that may fail on the make check
      if [ $? -ne 0 ] && ( [ $base == 'liba_bundled' ] || [ $base == 'liba_bundled_cmdline' ] ) ; then
        echo "$base: Make Failed" >> ../make-fail.txt
      fi
    fi
    echo ""
    )
	
done

echo ""
if [ -e check-smoke.txt ]; then
  cat check-smoke.txt
fi
if [ -e make-fail.txt ]; then
  cat make-fail.txt
fi
echo ""

#Gather Test Data
if [ -e passing-tests.txt ]; then
  ((total_tests=$(wc -l <  passing-tests.txt)))
fi
if [ -e make-fail.txt ]; then
  ((total_tests+=$(wc -l <  make-fail.txt)))
fi
if [ -e failing-tests.txt ]; then
  ((total_tests+=$(wc -l <  failing-tests.txt)))
fi

#Print Results
echo -------------------- Results --------------------
echo "Number of tests: $total_tests"
echo ""
echo Passing tests: `wc -l <  passing-tests.txt`/$total_tests
echo ""

#Print failed tests
if [ -e failing-tests.txt ]; then
  echo "Runtime Fails"
  echo "--------------------"
  cat failing-tests.txt
  echo ""
fi

if [ -e make-fail.txt ]; then
  echo "Compile Fails"
  echo "--------------------"
  cat make-fail.txt
fi
