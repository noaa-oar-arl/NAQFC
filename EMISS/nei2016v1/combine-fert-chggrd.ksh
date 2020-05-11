#!/bin/ksh -x

START_PDY=20190801
END_PDY=20190903

str_yearmonth=`echo $START_PDY|cut -c1-6`

origyear=2011


HOLDER=/data/aqf3/youhuat/NH3-fertilizer-5x

INFOLDER=/data/aqf3/youhuat/NH3-fertilizer-EPA/

export OUT=$HOLDER/FERT_12km_5x_time$str_yearmonth.ncf

cd $HOLDER

while [ $START_PDY -le $END_PDY ]; do

cyear=`echo $START_PDY|cut -c1-4`
cmonth=`echo $START_PDY|cut -c5-6`
cdate=`echo $START_PDY|cut -c7-8`

export ajulian=`/bin/date --date=$cyear'/'$cmonth'/'$cdate +%j`
typeset -Z3 ajulian


cat>combine-fert-chggrd.ini<<EOF
&control
begdate=$cyear$ajulian
begtime=0
iduration=1
mystep=240000
mrg_diff_days=.true.
ioff=4
imax=442
joff=1
jmax=265
gridname='AQF_CONUS_5x' 
/
EOF

export INPUT=$INFOLDER/${origyear}_US1_time$origyear$cmonth$cdate.nc

/data/aqf/youhuat/aqf2/emis-2011v6/newftp.epa.gov/Air/emismod/2016/v1/merge-script/combine-fert-chggrd.x
    
START_PDY=`ndate +24 ${START_PDY}12 |cut -c1-8`
done
