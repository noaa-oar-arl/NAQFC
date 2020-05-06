#!/bin/ksh

export METCRO3D_1=/gpfs/hps2/ptmp/Patrick.C.Campbell/fv3gfs_v16_test/output/aqm.t12z.metcro3d.ncf
export INIT_1=/gpfs/hps2/ptmp/Patrick.C.Campbell/com/aqm/prod/aqm.20190711/aqm.t12z.cgrid_35L.ncf

export METCRO3D_2=/gpfs/hps2/ptmp/Patrick.C.Campbell/fv3gfs_v16_test/output_57lev/aqm.t12z.metcro3d.ncf
export INIT_2=/gpfs/hps2/ptmp/Patrick.C.Campbell/com/aqm/prod/aqm.20190711/aqm.t12z.cgrid.ncf

rm -f $INTI_2
../src/interp-init.x 2019193 12
