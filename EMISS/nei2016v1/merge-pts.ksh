#!/bin/ksh -x

START_PDY=20190701
END_PDY=20190803

str_yearmonth=`echo $START_PDY|cut -c1-6`

origyear=2014

# HOLDER=/TEMP/youhuat/nei2014v2-pts-2019
HOLDER=/data/aqf3/youhuat/emis-2011v6/nei2014v2-pts-2019
#HOLDER=/data/aqf3/youhuat/emis-2011v6/nei2014v2-pts-2020
INFOLDER=/data/aqf2/youhuat/emis-2011v6/newftp.epa.gov/Air/emismod/2016/alpha/2014fd_cb6_14j/smoke_out/2014fd_cb6_14j/12US_5x/cmaq_cb6

#set -A holists 0101 0102 0330 0331 0528 0529 0704 0705 0902 0903 1122 1123 1124 1224 1225 1226 # 2018
set -A holists 0101 0102 0419 0420 0527 0528 0704 0705 0902 0903 1128 1129 1130 1224 1225 1226 # 2019
# set -A holists 0101 0102 0410 0411 0525 0526 0704 0705 0907 0908 1125 1126 1127 1224 1225 1226 # 2020

set -A oholists 0101 0102 0418 0419 0526 0527 0704 0705 0901 0902 1127 1128 1129 1224 1225 1226 # 2014

num_holists=${#holists[@]}

while [ $START_PDY -le $END_PDY ]; do


cyear=`echo $START_PDY|cut -c1-4`
cmonth=`echo $START_PDY|cut -c5-6`
cdate=`echo $START_PDY|cut -c7-8`

export ajulian=`/bin/date --date=$cyear'/'$cmonth'/'$cdate +%j`
typeset -Z3 ajulian

nowholiday=0
ntmp=0
while [ $ntmp -lt $num_holists ]; do
 if [ $cmonth$cdate -eq ${holists[$ntmp]} ]; then
  nowholiday=1
  KDATE=$origyear${oholists[$ntmp]}
  break
 fi
 let ntmp=$ntmp+1 
done

ntmp=0
exgrep=""
while [ $ntmp -lt $num_holists ]; do
 kmonth=`echo ${oholists[$ntmp]}|cut -c1-2`
 if [ $cmonth -eq $kmonth ]; then
 exgrep="$exgrep |grep -v ${oholists[$ntmp]} "
 fi
 let ntmp=$ntmp+1 
done

ind_week1=`date --date=$cyear/$cmonth/$cdate +%w`  # index of week, Sunday is 0, Monday is 1
if [ $nowholiday -eq 0 ]; then  # find matching weekdate

 testday=`ndate -48 $origyear$cmonth${cdate}00 |cut -c1-8`
 n2=0
 while [ $n2 -lt 7 ]; do
  tmpyear=`echo $testday|cut -c1-4`
  tmpmonth=`echo $testday|cut -c5-6`
  tmpdate=`echo $testday|cut -c7-8`
  ind_week2=`date --date=$tmpyear/$tmpmonth/$tmpdate +%w`
  
  if [ $ind_week2 -eq $ind_week1 ]; then
   KDATE=$tmpyear$tmpmonth$tmpdate
   break
  fi
  testday=`ndate +24 ${testday}00 |cut -c1-8`
  let n2=$n2+1
 done  
fi

if [ $ind_week1 -eq 0 ]; then
 ind_week1=7
fi
let ind_week=$ind_week1-1  # othon files start from Monday

if [ $ind_week -ge 5 ]; then
  ind_week_oildgas=$ind_week-3  # 0: Monday; 1: other weekday; 2 is Saturday and 3 is Sunday
elif [ $ind_week -le 1 ]; then 
  ind_week_oilgas=$ind_week
else
  ind_week_oilgas=1
fi

if [ $START_PDY -eq $END_PDY ]; then
 iduration=25
else
 iduration=24
fi

cat>my-combine-file.ini<<EOF
&control
begdate=$cyear$ajulian
begtime=0
iduration=$iduration
mystep=10000
mrg_diff_days=.true. 
/
EOF

for sectors in ptegu ptnonipm pt_oilgas cmv_c3 othpt ; do
export OUT=$HOLDER/inln_mole_${sectors}_${str_yearmonth}_12US_5x_cmaq_cb6_2014fd_cb6_14j.ncf

unset INPUT
if [ $sectors = ptegu ]; then
 export INPUT=$INFOLDER/$sectors/inln_mole_ptegu_${KDATE}_12US_5x_cmaq_cb6_2014fd_cb6_14j.ncf

elif [ $sectors = ptnonipm -o $sectors = pt_oilgas ]; then 
 if [ $nowholiday -eq 1 ]; then
  export INPUT=$INFOLDER/$sectors/inln_mole_${sectors}_${KDATE}_12US_5x_cmaq_cb6_2014fd_cb6_14j.ncf
 else
  set -A weekday_files `eval "ls $INFOLDER/$sectors/inln_mole_${sectors}_$origyear${cmonth}*.ncf $exgrep"`
  export INPUT=${weekday_files[$ind_week_oilgas]}
 fi
elif [ $sectors = cmv_c3 ]; then  
 export INPUT=`ls $INFOLDER/$sectors/inln_mole_${sectors}_$origyear${cmonth}*.ncf`  # one day for one month
 
elif [ $sectors = othpt ]; then
 set -A weekday_files `eval "ls $INFOLDER/$sectors/inln_mole_${sectors}_$origyear${cmonth}*.ncf"`
 export INPUT=${weekday_files[$ind_week_oilgas]}
else
 echo "wrong sector $sectors"
 exit 1
fi

if [ ! -s $INPUT ]; then
 echo " can not find $INPUT "
 exit 1
fi
my-combine-file.x
 
done   
START_PDY=`ndate +24 ${START_PDY}12 |cut -c1-8`
done
