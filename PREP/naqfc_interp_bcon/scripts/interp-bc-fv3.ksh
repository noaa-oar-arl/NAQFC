#!/bin/ksh

export METCRO3D_1=/gpfs/hps2/ptmp/Patrick.C.Campbell/fv3gfs_v16_test/output/aqm.t12z.metcro3d.ncf
export BND_1=/gpfs/hps3/emc/naqfc/noscrub/Patrick.C.Campbell/cmaq/5.3/fv3-cmaq/fix/aqm_conus_12km_geos_200607_static_35L.ncf

export METCRO3D_2=/gpfs/hps2/ptmp/Patrick.C.Campbell/fv3gfs_v16_test/output_42levPBL/aqm.t12z.metcro3d.ncf
export BND_2=/gpfs/hps3/emc/naqfc/noscrub/Patrick.C.Campbell/cmaq/5.3/fv3-cmaq/fix/aqm_conus_12km_geos_200607_static_42L_PBL.ncf

rm -f $BND_2
../src/interp-bc.x
