#!/bin/ksh -x

export SPECIES_DEF=combine/scripts/spec_def_files/SpecDef_cb6r3_ae7_naqfc_trimmed.txt

PDY="User add YYYYMMDD"  
COMIN="User add cmaq input directory"
COMOUT="User add post output directory"

if [ ! -s $COMOUT ]; then
 mkdir -p $COMOUT
fi
 
export INFILE1=$COMIN/aqm.t12z.conc.ncf
export INFILE2=$COMIN/aqm.t12z.metcro3d.ncf
export INFILE3=$COMIN/aqm.t12z.apmdiag.ncf
export INFILE4=$COMIN/aqm.t12z.metcro2d.ncf

export OUTFILE=$COMOUT/aqm.$PDY.t12z.aconc-pm25_new.ncf
rm -f $OUTFILE
./combine/scripts/BLD_combine_v531_intel/combine_v531.exe
