#!/bin/ksh -x

START_PDY=20190801
END_PDY=20190904
#END_PDY=20180501
yyyymm=`echo $START_PDY|cut -c1-6`

export OUT=emis-nei2016v1-cb6-$yyyymm.ncf
cd /data/aqf3/youhuat/emis-2016v1/2019

export HOLDER=/data/aqf3/patrickc/emission/2016v1/IC2016V1_EMIS_PREMERGED_2016fh_GRID
#export HOLDER1=/data/aqf3/patrickc/emission/2016v1/IC2016V1_EMIS_PREMERGED_2016fh_PT

# set -A othonfiles `ls $HOLDER/othon/emis_mole_othon_2017090*ncf`
# othonfiles=`ls $HOLDER/othon/emis_mole_othon_2017090*ncf`

# echo "${othonfiles[0]}" # \n $othonfiles[1]"
# exit

origyear=2016
origyear2=2016
# set -A holists 0101 0102 0330 0331 0528 0529 0704 0705 0902 0903 1128 1129 1130 1224 1225 1226  # 2018
set -A holists 0101 0102 0419 0420 0527 0528 0704 0705 0902 0903 1128 1129 1130 1224 1225 1226 # 2019

set -A oholists 0101 0102 0325 0326 0530 0531 0704 0705 0905 0906 1123 1124 1125 1224 1225 1226  # 2016
# set -A oholists2 0101 0102 0418 0419 0526 0527 0704 0705 0901 0902 1127 1128 1129 1224 1225 1226 # 2014
num_holists=${#holists[@]}

echo "num_holists=$num_holists"

while [ $START_PDY -le $END_PDY ]; do


cyear=`echo $START_PDY|cut -c1-4`
cmonth=`echo $START_PDY|cut -c5-6`
cdate=`echo $START_PDY|cut -c7-8`

nowholiday=0
ntmp=0
while [ $ntmp -lt $num_holists ]; do
 if [ $cmonth$cdate -eq ${holists[$ntmp]} ]; then
  nowholiday=1
  KDATE=$origyear${oholists[$ntmp]}
#  KDATE2=$origyear2${oholists2[$ntmp]}  # for PT surface files
  break
 fi
 let ntmp=$ntmp+1 
done

ntmp=0
exgrep=""
exgrep2=""
while [ $ntmp -lt $num_holists ]; do
 kmonth=`echo ${oholists[$ntmp]}|cut -c1-2`
# kmonth2=`echo ${oholists2[$ntmp]}|cut -c1-2`
 if [ $cmonth -eq $kmonth ]; then
 exgrep="$exgrep |grep -v ${oholists[$ntmp]} "
 fi
# if [ $cmonth -eq $kmonth2 ]; then
# exgrep2="$exgrep2 |grep -v ${oholists2[$ntmp]} "
# fi
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
 
export RWC=$HOLDER/rwc/emis_mole_rwc_${KDATE}_12us1_cmaq_cb6_2016fh_16j.ncf
export AG=$HOLDER/ag/emis_mole_ag_${KDATE}_12us1_cmaq_cb6_2016fh_16j.ncf
export AFDUST=$HOLDER/afdustadj/emis_mole_afdustadj_${KDATE}_12us1_cmaq_cb6_2016fh_16j.ncf
export OTHAFDUST=$HOLDER/othafdustadj/emis_mole_othafdustadj_${KDATE}_12us1_cmaq_cb6_2016fh_16j.ncf
export OTHPTDUST=$HOLDER/othptdustadj/emis_mole_othptdustadj_${KDATE}_12us1_cmaq_cb6_2016fh_16j.ncf

if [ $nowholiday -eq 0 ]; then #weekday/weekend

# set -A np_oilgas_files `ls $HOLDER/np_oilgas/emis_mole_np_oilgas_$cyear${cmonth}*.ncf $exgrep `
# cmd="ls $HOLDER/np_oilgas/emis_mole_np_oilgas_$cyear${cmonth}*.ncf $exgrep"
# eval filelist=$cmd
# set -A np_oilgas_files `eval $cmd`

# set -A np_oilgas_files `eval "ls $HOLDER/npoilgas/emis_mole_npoilgas_$origyear${cmonth}*12us1*.ncf $exgrep"`
# export NP_OILGAS=${np_oilgas_files[$ind_week]}
 
# set -A afdust_files `eval "ls $HOLDER/afdustadj/emis_mole_afdustadj_$origyear${cmonth}*12us1*.ncf $exgrep"`
# export AFDUST=${afdust_files[$ind_week]}
 
 set -A airports_files `eval "ls $HOLDER/airports/emis_mole_airports_$origyear${cmonth}*12us1*.ncf $exgrep"`
 export AIRPORTS=${airports_files[$ind_week]}
  
# nonroad file using "mwdss_Y": one representative Monday, representative weekday, representative
# Saturday and representative Sunday for each month. _Y stands for whether treat holidays as Sundays
 set -A nonroad_files `eval "ls $HOLDER/nonroad/emis_mole_nonroad_$origyear${cmonth}*12us1*.ncf $exgrep"`
 if [ $ind_week -ge 5 ]; then
  ind_week_nonroad=$ind_week-3  # 0: Monday; 1: other weekday; 2 is Saturday and 3 is Sunday
 elif [ $ind_week -le 1 ]; then 
  ind_week_nonroad=$ind_week
 else
  ind_week_nonroad=1
 fi  
 export NONROAD=${nonroad_files[$ind_week_nonroad]}

 set -A nonpt_files `eval "ls $HOLDER/nonpt/emis_mole_nonpt_$origyear${cmonth}*12us1*.ncf $exgrep"`
 export NONPT=${nonpt_files[$ind_week]}

 set -A pt_oilgas_files `eval "ls $HOLDER/ptoilgas/emis_mole_ptoilgas_$origyear${cmonth}*12us1*.ncf $exgrep2"`
 export PT_OILGAS=${pt_oilgas_files[$ind_week_nonroad]}
 
 set -A ptnonipm_files `eval "ls $HOLDER/ptnonipm/emis_mole_ptnonipm_$origyear${cmonth}*12us1*.ncf $exgrep2"`
 export PTNONIPM=${ptnonipm_files[$ind_week_nonroad]}
 
else
# export NP_OILGAS=$HOLDER/np_oilgas/emis_mole_npoilgas_${KDATE}_12us1_cmaq_cb6_2016fh_16j.ncf
# export AFDUST=$HOLDER/afdust/emis_mole_afdustadj_${KDATE}_12us1_cmaq_cb6_2016fh_16j.ncf
 export NONROAD=$HOLDER/nonroad/emis_mole_nonroad_${KDATE}_12us1_cmaq_cb6_2016fh_16j.ncf
 export NONPT=$HOLDER/nonpt/emis_mole_nonpt_${KDATE}_12us1_cmaq_cb6_2016fh_16j.ncf
 export PT_OILGAS=$HOLDER/ptoilgas/emis_mole_ptoilgas_${KDATE}_12us1_cmaq_cb6_2016fh_16j.ncf
 export PTNONIPM=$HOLDER/ptnonipm/emis_mole_ptnonipm_${KDATE}_12us1_cmaq_cb6_2016fh_16j.ncf
fi
# othafdust has the same temporal as afdust
# set -A othafdust_files `eval "ls $HOLDER/othafdust/emis_mole_othafdust_$origyear${cmonth}*12us1*.ncf $exgrep"`
# export OTHAFDUST=${othafdust_files[$ind_week]}

set -A othar_files `eval "ls $HOLDER/othar/emis_mole_othar_$origyear${cmonth}*12us1*.ncf $exgrep"`
export OTHAR=${othar_files[$ind_week]}

export RAIL=`ls $HOLDER/rail/emis_mole_rail_$origyear${cmonth}*12us1*.ncf`  # one day for one month

# in NEI2016v1 CMV becomes pt sources
#export CMV_C1C2=`ls $HOLDER/cmv_c1c2/emis_mole_cmv_c1c2_$origyear${cmonth}*12us1*.ncf`

export NP_OILGAS=`ls $HOLDER/npoilgas/emis_mole_npoilgas_$origyear${cmonth}*12us1*.ncf`

for checkfile in $AG $RWC $NP_OILGAS $AIRPORTS $AFDUST $NONROAD $NONPT \
 $OTHAFDUST $OTHPTDUST $OTHAR $RAIL $PT_OILGAS $PTNONIPM ; do
 if [ ! -s $checkfile ]; then
  echo " can not find $checkfile "
  exit
 fi
done  

## mobile emissions
export onroad=$HOLDER/onroad/emis_mole_onroad_${KDATE}_12us1_cmaq_cb6_2016fh_16j.ncf

export onroad_ca=$HOLDER/onroadcaadj/emis_mole_onroadcaadj_${KDATE}_12us1_cmaq_cb6_2016fh_16j.ncf


set -A othonfile1 `ls $HOLDER/onroadcan/emis_mole_onroadcan_$origyear${cmonth}*12us1*ncf`  
export onroad_can=${othonfile1[$ind_week]}  # Canada onroad files start from Monday

set -A othonfile2 `ls $HOLDER/onroadmex/emis_mole_onroadmex_$origyear${cmonth}*12us1*ncf`
export onroad_mex=${othonfile2[$ind_week]}  # Mexico onroad emission start from Monday

for checkfile in $onroad $onroad_ca $onroad_can $onroad_mex ; do
 if [ ! -s $checkfile ]; then
  echo " can not find $checkfile "
  exit
 fi
done  


export ajulian=`/bin/date --date=$cyear'/'$cmonth'/'$cdate +%j`
typeset -Z3 ajulian

cat>my-mrggrid-trim.ini<<EOF
&control
begdate=$cyear$ajulian
begtime=0
iduration=25
mystep=10000
filelists='AG','RWC','NP_OILGAS','AIRPORTS','AFDUST','NONROAD','NONPT',
  'OTHAFDUST','OTHPTDUST','OTHAR','RAIL','PT_OILGAS','PTNONIPM',
  'onroad','onroad_ca','onroad_can','onroad_mex'
fvname='ACET','ACROLEIN','ALD2','ALD2_PRIMARY','ALDX','BENZ','BUTADIENE13','CH4','CL2',
'CO','ETH','ETHA','ETHY','ETOH','FORM','FORM_PRIMARY','HCL','HONO','IOLE','ISOP','KET',
'MEOH','NAPH','NH3','NH3_FERT','NO','NO2','NVOL','OLE','PAL','PAR','PCA','PCL','PEC',
'PFE','PH2O','PK','PMC','PMG','PMN','PMOTHR','PNA','PNCOM','PNH4','PNO3','POC',
'PRPA','PSI','PSO4','PTI','SO2','SOAALK','SULF','TERP','TOL','UNK','UNR','VOC_INV','XYLMN',
mrg_diff_days=.true.
change_voc_inv_units=.true.
cb5convert=.false.
ioff=4
joff=1
imax=442
jmax=265
gridname='AQF_CONUS_5x'
/
EOF
     
/data/aqf2/youhuat/emis-2011v6/newftp.epa.gov/Air/emismod/2016/v1/merge-script/my-mrggrid-trim.x

START_PDY=`ndate +24 ${START_PDY}12 |cut -c1-8`
done
