     include 'PARMS3.EXT'      ! i/o API
     include 'FDESC3.EXT'      ! i/o API
     include 'IODECL3.EXT'     ! i/o API


     real, allocatable, dimension (:) :: sheight , swork, zheight, work,vglevs(:)
     real, allocatable, dimension (:,:,:) :: bnd1, bnd2, z1, z2
       
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
     len2=i2*2+j2*2+4
     isdate2=sdate3d
     istime2=stime3d
     if(i1.ne.i2.or.j1.ne.j2) then
       print*,'not the same horizontal domain ',len1,len2
       stop
     endif  
     
     allocate(zheight(k2))
     allocate(work(k2))
     allocate(z2(i2,j2,k2))
     allocate(vglevs(MXLAYS3+1))
     
     vglevs(1:MXLAYS3+1)=vglvs3d(1:MXLAYS3+1)
     vgtop=vgtop3d
     ivgtyp=vgtyp3d

     if(.not.OPEN3('BND_1',FSREAD3,'interp-bc')) stop  
     if(.not.DESC3('BND_1')) stop
     if(i1.ne.NCOLS3D.or.j1.ne.NROWS3D.or.k1.ne.NLAYS3D) then
      print*,'inconsistent coordinates in source grids ', i1,j1,k1,NCOLS3D, NROWS3D, NLAYS3D
      stop
     endif
     if(nthik3d.ne.1) then
       print*,'BND thickness has to be 1 ',nthik3d
       stop
     endif  
        
     noutbnd=nvars3d
     allocate(bnd1(len1,k1,nvars3d))

!----contruct output file     
     if(.not.open3('BND_2',FSRDWR3,'pathway')) then  ! if not exist, generate it

      nlays3d=k2     
      vglvs3d(1:MXLAYS3+1)=vglevs(1:MXLAYS3+1)
      vgtop3d=vgtop
      vgtyp3d=ivgtyp
      if(.not.OPEN3('BND_2',FSUNKN3,'pathway')) stop
      
     else         ! check the consistence
       if(.not.desc3('BND_2')) stop
       if(i2.ne.ncols3d.or.j2.ne.nrows3d.or.k2.ne.nlays3d.or. &
        nvars3d.ne.noutbnd) then
        print*,'dimension does not much, STOP'
        stop
       endif
     endif
     
     allocate(bnd2(len2,k2,nvars3d))
     
     i0n = i1 + j1 + 2
     j0e = i1 + 1
     j0w = 2*i1 + j1 + 3
      
     do mtime=1, MXREC3D
     
       if(tstep3d.eq.0.and.mxrec3d.eq.1) then
         if(.not.read3('METCRO3D_1','ZH',ALLAYS3,isdate2,istime2,z1)) then  ! if can not read met1 using met2's time, switch
	   if(.not.read3('METCRO3D_2','ZH',ALLAYS3,isdate1,istime1,z2)) stop
           if(.not.read3('METCRO3D_1','ZH',ALLAYS3,isdate1,istime1,z1)) stop
	 else
	  if(.not.read3('METCRO3D_2','ZH',ALLAYS3,isdate2,istime2,z2)) stop
	 endif
       else
         if(.not.read3('METCRO3D_1','ZH',ALLAYS3,sdate3d,stime3d,z1)) stop
 	 if(.not.read3('METCRO3D_2','ZH',ALLAYS3,sdate3d,stime3d,z2)) stop
       endif	 
      
       if(.not.read3('BND_1',ALLVAR3,ALLAYS3,sdate3d,stime3d,bnd1)) stop
     
       do i=1,len1  
        if(i.le.i1+1) then
         ix=i
         jy=1
         if(ix.gt.i1) ix=i1
        else if(i.gt.i1+1.and.i.le.i1+j1+2) then
         ix=i1
         jy=i-i1-1
         if(jy.gt.j1) jy=j1
        else if(i.gt.i1+j1+2.and.i.le.2*i1+j1+3) then
         ix=i-i1-j1-2
         jy=j1
         if(ix.gt.i1) ix=i1
        else
         ix=1
         jy=i-2*i1-j1-3
         if(jy.gt.j1) jy=j1
        endif
	
	sheight(1:k1)=z1(ix,jy,1:k1)
	zheight(1:k2)=z2(ix,jy,1:k2)
	
	do n=1,nvars3d
	 swork(1:k1)=bnd1(i,1:k1,n)
	 call ztint(k1,swork,sheight,k2,work,zheight)
	 bnd2(i,1:k2,n)=work(1:k2)
	enddo
       enddo	
       
       if(.not.write3('BND_2',ALLVAR3,sdate3d,stime3d,bnd2)) stop
	
	call nextime(sdate3d,stime3d,tstep3d)
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
