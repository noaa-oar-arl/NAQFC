 
TARGET     =  aqm_fv3chem_dlbc.x

OBJECTS = aqm_fv3chem_dlbc.f

LIB_LOC    = /gpfs/hps3/emc/naqfc/noscrub/Youhua.Tang/nwdev/NAQFC-WCOSS/lib
IOAPI_LIB  = $(LIB_LOC)/libaqm_ioapi.a

NETCDF_LIB   = -L/opt/cray/netcdf/4.3.2/intel/140/lib -lnetcdff -lnetcdf
 
FC         = ifort 
 
F_FLAGS    = -O -FR -assume byterec

NEMSIO_LIB9  = /gpfs/hps/nco/ops/nwprod/lib/nemsio/v2.2.3/intel/libnemsio_v2.2.3.a
NENSIO_INC   = /gpfs/hps/nco/ops/nwprod/lib/nemsio/v2.2.3/intel/include/nemsio_v2.2.3

BACIO_LIB  = /gpfs/hps/nco/ops/nwprod/lib/bacio/v2.0.2/intel/libbacio_v2.0.2_4.a

W3_LIB     = /gpfs/hps/nco/ops/nwprod/lib/w3nco/v2.0.6/intel/libw3nco_v2.0.6_d.a /gpfs/hps/nco/ops/nwprod/lib/w3emc/v2.3.0/intel/libw3emc_v2.3.0_d.a
NEMSIOGFS_INC = /gpfs/hps/nco/ops/nwprod/lib/nemsiogfs/v2.0.1/intel/include/nemsiogfs_v2.0.1
NEMSIO_INC = /gpfs/hps/nco/ops/nwprod/lib/nemsio/v2.2.3/intel/include/nemsio_v2.2.3

LIBRARIES = $(IOAPI_LIB) $(NETCDF_LIB) $(NEMSIO_LIB9) $(NEMSIOGFS_LIB) $(BACIO_LIB) \
	   $(W3_LIB)
 
 
INCLUDES = -I$(LIB_LOC)/include -I$(NEMSIO_INC) -I$(NEMSIOGFS_INC) -I$(LIB_LOC)/sorc/aqm_ioapi_v31/ioapi

$(TARGET): $(OBJECTS)
	$(FC) $(F_FLAGS) -openmp -o $@ $(INCLUDES) $(OBJECTS) $(LIBRARIES)

clean:
	rm -f *.mod  
install: 	
	-cp -p $(TARGET)  ../../exec/.
clobber: clean
	rm -f $(TARGET) 
