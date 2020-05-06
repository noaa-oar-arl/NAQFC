#!/bin/ksh

export METCRO3D_1=/gpfs/hps/nco/ops/com/aqm/prod/aqm.20190601/aqm.t06z.metcro3d.ncf
export BND_1=/gpfs/hps/nco/ops/nwprod/cmaq.v5.0.3/fix/aqm_conus_12km_geos_200606_static_35L.ncf

export METCRO3D_2=/gpfs/hps2/ptmp/Youhua.Tang/com/aqm/para/aqm.20190528/aqm.t12z.metcro3d.ncf
export BND_2=$HOME/ptmp/bnd.conus-12km.static_geos_200606.fv3-35L.ncf

../src/interp-bc.x
