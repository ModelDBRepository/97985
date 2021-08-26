#!/bin/sh
# download and fix up the modeldb zip files so as to
# avoid run, graphics output, and creation of data directories

#download models
models="20212 20007 17664"
for i in $models ; do
	curl "https://senselab.med.yale.edu/ModelDB/eavBinDown.cshtml?o=$i&a=23&mime=application/zip"> modeldb/$i.zip
	(cd modeldb; unzip -o $i.zip)
done
tf=$$


#fix up the poirazi model so it will load but not run
# also fix some mod files so they can be used to calculate mcomplex.dat
mdir=modeldb/CA1_multi/mechanism
bpap=modeldb/CA1_multi/experiment/spike-train-attenuation/bpap.hoc
econ=modeldb/CA1_multi/template/ExperimentControl.hoc

sed '/\/\/ Create basic graphics/,$d
s/system(/\/\/system(/
' $bpap > $tf
mv $tf $bpap

sed '
/proc clear_variable_dump(/a\
return
/proc dump_variable(/a\
return
' $econ > $tf
mv $tf $econ

for i in gabaa.mod gabab.mod glutamate.mod nmda.mod ; do
	sed '/^PROCEDURE release()/i\
VERBATIM\
#define p_pre _p_pre\
ENDVERBATIM

		s/if (pre > Prethresh)/if (p_pre \&\& pre > Prethresh)/
	' $mdir/$i > $tf
	mv $tf $mdir/$i
done
#dll via nrnivmodl modeldb/CA1_multi/mechanism

#fix up the Lazarewicz model so it will load but not run
f=modeldb/ca3_2002/ca3_paper.hoc
sed '
/^xopen("ses1\.ses")/s/^/\/\//
/^PlotShape/s/^/\/\//
/^init()/s/^/\/\//
/^run()/s/.*/\/\/run()\n/
' $f > $tf
mv $tf $f
#dll via nrnivmodl modeldb/ca3_2002

f=modeldb/prknj
# nrnivmodl modeldb/prknj
