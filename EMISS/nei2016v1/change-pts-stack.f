! combine PTS Stack file and trim them for new grid

      include 'PARMS3.EXT'      ! i/o API
      include 'FDESC3.EXT'      ! i/o API
      include 'IODECL3.EXT'     ! i/o API

      character gridname*16
      real,allocatable :: a(:,:)
      integer, allocatable :: m(:,:)

      namelist /control/ioff,joff,gridname

      open(7,file='change-pts-stack.ini')
      read(7,control)
      close(7)

      if(.not.open3('INPUT',FSREAD3,'mymrggrid')) stop
      if(.not.desc3('INPUT')) stop
      if(nlays3d.ne.1) then
       print*,'nlays3d wrong ',nlays3d
       stop
      endif
        
      imax=ncols3d
      jmax=nrows3d
      
      allocate(a(imax,jmax),m(imax,jmax))


!--open output file

!       nvars3d=nvar
       gdnam3d=gridname
       XORIG3D=XORIG3D+ioff*xcell3d
       YORIG3D=YORIG3D+joff*ycell3d

       if(.not.open3('OUT',FSUNKN3,'mrggrid')) stop

       do n=1,nvars3d
        if(vtype3d(n).eq.M3REAL) then 
         if(.not.read3('INPUT',vname3d(n),ALLAYS3,sdate3d,
     1        stime3d,a)) stop
         if(.not.write3('OUT',vname3d(n),sdate3d,stime3d,a)) stop
        endif
        if(vtype3d(n).eq.M3INT) then 
         if(.not.read3('INPUT',vname3d(n),ALLAYS3,sdate3d,
     1        stime3d,m)) stop
         if(vname3d(n).eq.'COL') m=m-ioff
	 if(vname3d(n).eq.'ROW') m=m-joff
         if(.not.write3('OUT',vname3d(n),sdate3d,stime3d,m)) stop
        endif
	
       enddo  ! time loop

       iflag=shut3()
       end
