! merge emission files for selected variables with trimmed domain
! Youhua Tang 04/2020
      include 'PARMS3.EXT'      ! i/o API
      include 'FDESC3.EXT'      ! i/o API
      include 'IODECL3.EXT'     ! i/o API

      parameter(mfiletypes=50,maxvar=300)

!      character*200 prefix(mfiletypes),suffix(mfiletypes)
      character*4 lfname(mfiletypes)
      character atmpm1*8,atmp*8
      integer istime(mfiletypes),ietime(mfiletypes),fvtype(maxvar),
     1   locvar(maxvar,mfiletypes),    ! whether this var is in this file
     2   fsdates(mfiletypes),fstimes(mfiletypes)
      character fvname(maxvar)*16,fvunits(maxvar)*16,fvdesc(maxvar)*80,
     1 filelists(mfiletypes)*16,rdvarname*16,gridname*16
      logical MRG_DIFF_DAYS,  ! whether merge different days
     1  change_voc_inv_units,cb5convert,cb6orig(mfiletypes) 
      real,allocatable :: a(:,:,:),ain(:,:,:),acet(:,:,:),benz(:,:,:),
     1  ket(:,:,:),prpa(:,:,:),ethy(:,:,:)

      integer begdate,begtime,iduration, mystep ! date/time in YYYYDDD and HHMMSS
      namelist /control/begdate,begtime,iduration,mystep,
     1  filelists,fvname,mrg_diff_days,change_voc_inv_units,cb5convert,
     2  ioff,imax,joff,jmax,gridname

      filelists(:)=' '
      fvname(:)=' '
      fvunits(:)=' '
      fvdesc(:)=' '
      cb6orig(:)=.false.
      cb5convert=.false.
      open(7,file='my-mrggrid-trim.ini')
      read(7,control)
      close(7)

      do i=1,mfiletypes
       if(filelists(i).eq.' ') exit
      enddo
      nfiletypes=i-1
      
      do i=1,maxvar
       if(fvname(i).eq.' ' ) exit
      enddo
      nvar=i-1
      
      print*,'nfiletypes,nvar=',nfiletypes,nvar
      
      locvar(:,:)=0

      do n=1,nfiletypes

       if(.not.open3(filelists(n),FSREAD3,'Youhua')) stop
       if(.not.desc3(filelists(n))) stop

       if(n.eq.1) then
         iin=ncols3d
         jin=nrows3d
         kmax=nlays3d	 
       endif

        if(iin.ne.ncols3d.or.jin.ne.nrows3d.or.kmax.ne.nlays3d) then
          print*,'inconsistent dimension ', ncols3d,nrows3d,nlays3d,
     1     filelists(n)
          stop
        endif
        do j=1,nvars3d
	 if(vname3d(j).eq.'XYL') cb6orig(n)=.true.

         do i=1,nvar
	 if((vname3d(j).eq.'XYL'.and.fvname(i).eq.'XYLMN').or.
     1	  (vname3d(j).eq.'XYLMN'.and.fvname(i).eq.'XYL').or.   ! cb5 
     1	  (vname3d(j).eq.'NAPHTHALENE'.and.fvname(i).eq.'NAPH').or.
     2    (vname3d(j).eq.'BENZ'.and.fvname(i).eq.'BENZENE')) then  !cb5
          locvar(i,n)=2
	  if(fvunits(i).eq.' ') then
	   fvunits(i)=units3d(j)
	   fvdesc(i)=vdesc3d(j)
	   fvtype(i)=vtype3d(j)
	  endif 
	 else if(vname3d(j).eq.fvname(i)) then  ! check whether the variable exist in the files
          locvar(i,n)=1
	  if(fvunits(i).eq.' ') then
	   fvunits(i)=units3d(j)
	   fvdesc(i)=vdesc3d(j)
	   fvtype(i)=vtype3d(j)
	  endif 
          exit
         endif	 
        enddo
	
       enddo
       fstimes(n)=stime3d
       fsdates(n)=sdate3d
       
      enddo

      do n=1,nvar
       if(fvunits(n).eq.' ') then
         if(fvname(n).eq.'PMFINE') then
	  fvunits(n)='g/s'
	  fvdesc(n)='Model species PMFINE'
	  fvtype(n)=M3REAL
	 else if(fvname(n).eq.'UNK') then
	  fvunits(n)='mole/s'
	  fvdesc(n)='Model species UNK'
	  fvtype(n)=M3REAL
	 else
	  print*,'can not find ',fvname(n),n,fvunits(n)
	  print*,'fvname=',fvname
	  print*,'fvunits=',fvunits
	  stop
         endif    	 
       endif
       if(change_voc_inv_units) then
        if(fvname(n).eq.'VOC_INV'.and.fvunits(n).eq.'g/s') then
	 fvunits(n)='moles/s' ! the molecular weight used for VOC_INV is 1 in the emission process
	endif
       endif 	  
      enddo
!--open output file
       ncols3d=imax
       nrows3d=jmax
       gdnam3d=gridname
       XORIG3D=XORIG3D+ioff*xcell3d
       YORIG3D=YORIG3D+joff*ycell3d
       
       nvars3d=nvar
       tstep3d=mystep
       sdate3d=begdate
       stime3d=begtime
       vname3d(1:nvar)=fvname(1:nvar)
       units3d(1:nvar)=fvunits(1:nvar)
       vdesc3d(1:nvar)=fvdesc(1:nvar)
       vtype3d(1:nvar)=fvtype(1:nvar)
       if(.not.open3('OUT',FSUNKN3,'mrggrid')) stop

       allocate(a(imax,jmax,kmax),ain(iin,jin,kmax),
     1   ethy(imax,jmax,kmax))
       if(cb5convert) allocate(acet(imax,jmax,kmax),
     1  benz(imax,jmax,kmax),ket(imax,jmax,kmax),prpa(imax,jmax,kmax))


       inowtime=begdate*100+begtime/10000 ! time in YYYYDDDHH

       do i=1,iduration

        do n=1,nvar
         ifirst=1
         a=0.

	 if(cb5convert.and.(rdvarname.eq.'BENZENE')) rdvarname='BENZ'
	 
         do m=1,nfiletypes
          if(locvar(n,m).ge.1) then
	     
            if(MRG_DIFF_DAYS) then
	     ireaddate=fsdates(m)
	     ireadtime=fstimes(m)
	    else
	     ireaddate=begdate
	     ireadtime=begtime
	    endif
   	    
	    rdvarname=fvname(n)
	    if(locvar(n,m).eq.2) then
	     if(cb6orig(m).and.fvname(n).eq.'XYLMN') rdvarname='XYL'
	     if(cb6orig(m).and.fvname(n).eq.'NAPH') 
     1	       rdvarname='NAPHTHALENE'
             if(cb5convert.and.fvname(n).eq.'BENZENE') rdvarname='BENZ'
	     if(cb5convert.and.fvname(n).eq.'XYL'.and.(.not.cb6orig(m))) 
     1	       rdvarname='XYLMN'
            endif
	    
            if(ifirst.eq.1) then
             if(.not.read3(filelists(m),rdvarname,ALLAYS3,ireaddate,
     1        ireadtime,ain)) then
                print*,rdvarname,cb6orig(m),fvname(n)
		stop
             endif
	     a(1:imax,1:jmax,1:kmax)=ain(1+ioff:imax+ioff,
     1	        1+joff:jmax+joff,1:kmax) 
             ifirst=0
            else
              if(.not.read3(filelists(m),rdvarname,ALLAYS3,ireaddate,
     1        ireadtime,ain)) then
                 print*,rdvarname,cb6orig(m),fvname(n)
		 stop
	       endif	 
             a(1:imax,1:jmax,1:kmax)=a(1:imax,1:jmax,1:kmax)+
     1        ain(1+ioff:imax+ioff,1+joff:jmax+joff,1:kmax)
            endif
	    
    	    if(cb5convert.and.(fvname(n).eq.'PAR'.or.
     1	       fvname(n).eq.'UNR')) then
              if(.not.read3(filelists(m),'ACET',ALLAYS3,ireaddate,
     1        ireadtime,ain)) stop
	      acet(1:imax,1:jmax,1:kmax)=ain(1+ioff:imax+ioff,
     1	        1+joff:jmax+joff,1:kmax) 
     
              if(.not.read3(filelists(m),'BENZ',ALLAYS3,ireaddate,
     1        ireadtime,ain)) stop
              benz(1:imax,1:jmax,1:kmax)=ain(1+ioff:imax+ioff,
     1	        1+joff:jmax+joff,1:kmax)
     
              if(.not.read3(filelists(m),'KET',ALLAYS3,ireaddate,
     1        ireadtime,ain)) stop
              ket(1:imax,1:jmax,1:kmax)=ain(1+ioff:imax+ioff,
     1	        1+joff:jmax+joff,1:kmax)
     
              if(.not.read3(filelists(m),'PRPA',ALLAYS3,ireaddate,
     1        ireadtime,ain)) stop
              prpa(1:imax,1:jmax,1:kmax)=ain(1+ioff:imax+ioff,
     1	        1+joff:jmax+joff,1:kmax)
	      
              if(.not.read3(filelists(m),'ETHY',ALLAYS3,ireaddate,
     1        ireadtime,ain)) stop
              ethy(1:imax,1:jmax,1:kmax)=ain(1+ioff:imax+ioff,
     1	        1+joff:jmax+joff,1:kmax)
     
             if(fvname(n).eq.'PAR') then
	      a(1:imax,1:jmax,1:kmax)=a(1:imax,1:jmax,1:kmax)+
     1	       3*acet(1:imax,1:jmax,1:kmax)+benz(1:imax,1:jmax,1:kmax)+
     2         ket(1:imax,1:jmax,1:kmax)+1.5*prpa(1:imax,1:jmax,1:kmax)+
     3         ethy(1:imax,1:jmax,1:kmax)
             else if(fvname(n).eq.'UNR') then
	      a(1:imax,1:jmax,1:kmax)=a(1:imax,1:jmax,1:kmax)+
     1	       6*benz(1:imax,1:jmax,1:kmax)+
     2         1.5*prpa(1:imax,1:jmax,1:kmax)+ethy(1:imax,1:jmax,1:kmax)
	     endif
	    else if(cb5convert.and.rdvarname.eq.'XYLMN') then
             if(.not.read3(filelists(m),'NAPHTHALENE',ALLAYS3,ireaddate,
     1        ireadtime,ethy)) then
              print*,filelists(m),'has no NAPHTHALENE',cb6orig(m),
     1	        fvname(n),cb5convert
              if(.not.read3(filelists(m),'NAPH',ALLAYS3,
     1         ireaddate,ireadtime,ethy)) then
               ethy=0.
	      endif 
	     endif
	     a(1:imax,1:jmax,1:kmax)=a(1:imax,1:jmax,1:kmax)+0.966*  ! XYL=XYLMN+0.966*NAPH
     1	     ethy(1:imax,1:jmax,1:kmax)
	    else if((.not.cb5convert).and.cb6orig(m).and.(fvname(n).eq.'PAR'
     1	      .or.fvname(n).eq.'XYLMN')) then
             if(.not.read3(filelists(m),'NAPHTHALENE',ALLAYS3,ireaddate,
     1        ireadtime,ethy)) then
              print*,filelists(m),'has no NAPHTHALENE',cb6orig(m),
     1	        fvname(n),cb5convert
              if(.not.read3(filelists(m),'NAPH',ALLAYS3,
     1         ireaddate,ireadtime,ethy)) then
               ethy=0.
	      endif 
	     endif
             if(fvname(n).eq.'XYLMN') tmpfac=0.966
	     if(fvname(n).eq.'PAR') tmpfac=0.00001
	     a(1:imax,1:jmax,1:kmax)=amax1(0.,a(1:imax,1:jmax,1:kmax)-tmpfac*
     1	     ethy(1:imax,1:jmax,1:kmax))
            endif
          endif
         enddo  ! filetype loop
!        print*,'process ',fvname(n),begdate,begtime

         if(.not.write3('OUT',fvname(n),begdate,begtime,a)) stop

         enddo  ! var loop

         call nextime(begdate,begtime,mystep)
	 do m=1,nfiletypes
	  call nextime(fsdates(m),fstimes(m),mystep)
	 enddo 
         inowtime=begdate*100+begtime/10000 ! time in YYYYDDDHH

       enddo  ! time loop

       iflag=shut3()
       end
