#!/bin/sh
# do the performance runs for the three models

models="1 2 3"

m1=modeldb/CA1_multi/mechanism
m2=modeldb/ca3_2002
m3=modeldb/prknj

if test "$CPU" = "" ; then
	echo "need to set CPU"
	exit 1
fi

if test "$CPU" = "x86_64" ; then
	nps="1 2 4"
fi
if test "$CPU" = "ia64" ; then
	nps="1 2 4 8 16 24"
fi

prepare() {
	rm -r -f $CPU
	rm -f mcomplex.dat
	case $1 in
	1) nrnivmodl $m1 ;;
	2) nrnivmodl $m2 ;;
	3) nrnivmodl $m3 ;;
	esac
	$CPU/special -nogui -c "model=$1" -c "split=2" init.hoc
}

for i in $models ; do
	prepare $i
	for np in $nps ; do
  mpiexec -np $np `which nrniv` -mpi -NSTACK 2000 -c "model=$i" init.hoc
	done
done

# note NSTACK avoids problem for model 1 at np = 24,30
