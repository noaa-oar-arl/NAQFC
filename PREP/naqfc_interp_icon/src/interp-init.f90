! --interpolate initial condition from 22 layers to 42 layers

     include 'PARMS3.EXT'      ! i/o API
     include 'FDESC3.EXT'      ! i/o API
     include 'IODECL3.EXT'     ! i/o API

     character*200 aline
     real, allocatable, dimension (:) :: sheight , swork, zheight, work,vglevs(:)
     real, allocatable, dimension (:,:,:) :: init1, init2, z1, z2
       
     if(iargc().ne.2) then
       print*,' need only input filename and output ctl'
       stop
     endif
     call getarg(1,aline)
     read(aline,*)init_date
     call getarg(2,aline)
     read(aline,*)init_time
     init_time=init_time*10000

     if(.not.OPEN3('METCRO3D_1',FSREAD3,'interp-bc')) stop   ! source height
     if(.not.DESC3('METCRO3D_1')) stop
     i1=NCOLS3D
     j1=NROWS3D
     k1=NLAYS3D
     len1=i1*2+j1*2+4
     isdate1=sdate3d
     istime1=stime3d
     
     allocate(sheight(k1))
     allocate(swork(k1))
     allocate(z1(i1,j1,k1))

     if(.not.OPEN3('METCRO3D_2',FSREAD3,'interp-bc')) stop   ! target height
     if(.not.DESC3('METCRO3D_2')) stop
     i2=NCOLS3D
     j2=NROWS3D
     k2=NLAYS3D

     isdate2=sdate3d
     istime2=stime3d
     if(i1.ne.i2.or.j1.ne.j2) then
       print*,'not the same horizontal domain ',i1,j1,i2,j2
       stop
     endif  
     
     allocate(zheight(k2))
     allocate(work(k2))
     allocate(z2(i2,j2,k2))
     allocate(vglevs(MXLAYS3+1))
     
     vglevs(1:MXLAYS3+1)=vglvs3d(1:MXLAYS3+1)
     vgtop=vgtop3d
     ivgtyp=vgtyp3d

     if(.not.OPEN3('INIT_1',FSREAD3,'interp-bc')) stop  
     if(.not.DESC3('INIT_1')) stop
     if(i1.ne.NCOLS3D.or.j1.ne.NROWS3D.or.k1.ne.NLAYS3D) then
      print*,'inconsistent coordinates in source grids ', i1,j1,k1,NCOLS3D, NROWS3D, NLAYS3D
      stop
     endif
        
     nout=nvars3d
     allocate(init1(i1,j1,k1))

!----contruct output file     
     if(.not.open3('INIT_2',FSRDWR3,'pathway')) then  ! if not exist, generate it
      sdate3d=init_date
      stime3d=init_time
      nlays3d=k2     
      vglvs3d(1:MXLAYS3+1)=vglevs(1:MXLAYS3+1)
      vgtop3d=vgtop
      vgtyp3d=ivgtyp
      if(.not.OPEN3('INIT_2',FSUNKN3,'pathway')) stop
      
     else         ! check the consistence
       if(.not.desc3('INIT_2')) stop
       if(i2.ne.ncols3d.or.j2.ne.nrows3d.or.k2.ne.nlays3d.or. &
        nvars3d.ne.nout.or.sdate3d.ne.init_date.or.stime3d.ne.init_time) then
        print*,'dimension does not much, STOP'
        stop
       endif
     endif
     
     allocate(init2(i2,j2,k2))


     if(.not.read3('METCRO3D_1','ZH',ALLAYS3,init_date,init_time,z1)) stop
     if(.not.read3('METCRO3D_2','ZH',ALLAYS3,init_date,init_time,z2)) stop
     
      
     do n=1,nvars3d
      print*,'process ',vname3d(n),init_date,init_time
      if(.not.read3('INIT_1',vname3d(n),ALLAYS3,init_date,init_time,init1)) stop
      do i=1,i1
        do j=1,j1
 	 sheight(1:k1)=z1(i,j,1:k1)
	 zheight(1:k2)=z2(i,j,1:k2)
	
         swork(1:k1)=init1(i,j,1:k1)
	 call ztint(k1,swork,sheight,k2,work,zheight)
	 init2(i,j,1:k2)=work(1:k2)
	enddo
       enddo	
       
       if(.not.write3('INIT_2',vname3d(n),init_date,init_time,init2)) stop
	
     enddo
     iflag=shut3()
     end
     	     
     subroutine ztint(nzz1,vctra,eleva,nzz2,vctrb,elevb)
!-----------------------------------------------------------------------
! subroutine interpolate vctra in eleva(nzz1) to vctrb  in elevb(nzz2)
!-----------------------------------------------------------------------
      integer, intent (in) :: nzz1,nzz2 
      real, intent (in) :: vctra(nzz1),eleva(nzz1),elevb(nzz2)
      real, intent (out) :: vctrb(nzz2)
      real wt

      do k=1,nzz2
 
        if(elevb(k).lt.eleva(1))then
         wt=(elevb(k)-eleva(1))/(eleva(2)-eleva(1))
         vctrb(k)=vctra(1)  !   +(vctra(2)-vctra(1))*wt   ! no extrapolation

        elseif(elevb(k).gt.eleva(nzz1))then
         wt=(elevb(k)-eleva(nzz1))/(eleva(nzz1-1)-eleva(nzz1))
         vctrb(k)=vctra(nzz1) !   +(vctra(nzz1-1)-vctra(nzz1))*wt

        else
          do l=1,nzz1-1
            if(elevb(k).ge.eleva(l).and.elevb(k).le.eleva(l+1))then
              wt=(elevb(k)-eleva(l))/(eleva(l+1)-eleva(l))
              vctrb(k)=vctra(l)+(vctra(l+1)-vctra(l))*wt
            endif
          enddo
        endif
      enddo

      return
      end
