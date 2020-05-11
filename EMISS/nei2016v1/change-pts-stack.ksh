#!/bin/ksh -x

HOLDER=/data/aqf3/youhuat/emis-2016v1/pts-2019

INFOLDER=/data/aqf3/patrickc/emission/2016v1/IC2016V1_EMIS_PREMERGED_2016fh_PT/2016fh_16j/12us1/cmaq_cb6

cat>change-pts-stack.ini<<EOF
&control
ioff=4
joff=1
gridname='AQF_CONUS_5x' 
/
EOF

for sectors in ptegu ptnonipm pt_oilgas cmv_c1c2_12 cmv_c3_12 othpt ; do
export OUT=$HOLDER/stack_groups_${sectors}_12US_5x_2016fh_16j.ncf

export INPUT=$INFOLDER/$sectors/stack_groups_${sectors}_12us1_2016fh_16j.ncf

if [ ! -s $INPUT ]; then
 echo " can not find $INPUT "
 exit 1
fi
change-pts-stack.x
 
done   
