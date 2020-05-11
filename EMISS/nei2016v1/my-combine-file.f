! combine files for longer time step

      include 'PARMS3.EXT'      ! i/o API
      include 'FDESC3.EXT'      ! i/o API
      include 'IODECL3.EXT'     ! i/o API

      parameter(mfiletypes=20,maxvar=300)

!      character*200 prefix(mfiletypes),suffix(mfiletypes)
      character*4 lfname(mfiletypes)
      character atmpm1*8,atmp*8
      integer istime(mfiletypes),ietime(mfiletypes),fvtype(maxvar),
     1   locvar(maxvar,mfiletypes),    ! whether this var is in this file
     2   fsdates,fstimes
      character fvname(maxvar)*16,fvunits(maxvar)*16,fvdesc(maxvar)*80,
     1 filelist
      logical MRG_DIFF_DAYS,  ! whether merge different days
     1  change_voc_inv_units
      real,allocatable :: a(:,:,:,:)

      integer begdate,begtime,iduration, mystep ! date/time in YYYYDDD and HHMMSS
      namelist /control/begdate,begtime,iduration,mystep,MRG_DIFF_DAYS

      fvname(:)=' '
      fvunits(:)=' '
      fvdesc(:)=' '
      open(7,file='my-combine-file.ini')
      read(7,control)
      close(7)

       if(.not.open3('INPUT',FSREAD3,'mymrggrid')) stop
       if(.not.desc3('INPUT')) stop

       imax=ncols3d
       jmax=nrows3d
       kmax=nlays3d

       fstimes=stime3d
       fsdates=sdate3d


!--open output file

!       nvars3d=nvar
       tstep3d=mystep
       sdate3d=begdate
       stime3d=begtime
       if(.not.open3('OUT',FSUNKN3,'mrggrid')) stop

       allocate(a(imax,jmax,kmax,nvars3d))

       do i=1,iduration
       
        if(MRG_DIFF_DAYS) then
	  ireaddate=fsdates
	  ireadtime=fstimes
	else
	  ireaddate=begdate
	  ireadtime=begtime
	endif

        if(.not.read3('INPUT',ALLVAR3,ALLAYS3,ireaddate,
     1        ireadtime,a)) stop
        if(.not.write3('OUT',ALLVAR3,begdate,begtime,a)) stop

         call nextime(begdate,begtime,mystep)
         call nextime(fsdates,fstimes,mystep)
       enddo  ! time loop

       iflag=shut3()
       end
