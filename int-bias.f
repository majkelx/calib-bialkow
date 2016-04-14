      program iii
      implicit double precision (a-h,o-z)
      character *2 t
      character *8 s
      character *15 namd
      character *30 names,namet
      dimension bgrb(1000),names(1000),ti(1000),tb(1000)

      open (2, file = 'subdfi.csh')
     
      open (1, file = 'tmp.exp')
      read (1,*) expt
      close(1)

      open (1, file = 'dm.cat')
      read (1,'(a15)') namd
      close(1)


      open (1, file = 'image.dat')
      do i = 1,1000
         read (1,'(a8,f10.2,a30)',end = 1) s,bgri,names(i)
         write (t,'(a2)') s(1:2)
         read (t,'(i2)') nh
         write (t,'(a2)') s(4:5)
         read (t,'(i2)') nm
         write (t,'(a2)') s(7:8)
         read (t,'(i2)') ns
         ti(i) = dble(nh) + dble(nm)/60.d0 + dble(ns)/3600.d0 
     *            + expt/7200.d0
         if (ti(i).lt.12.d0) ti(i) = ti(i) + 24.d0
      end do
    1 nim = i - 1
      close(1)

      open (1, file = 'bias.dat')
      do i = 1,1000
         read (1,'(a8,f10.2,a30)',end = 2) s,bgrb(i),namet
         write (t,'(a2)') s(1:2)
         read (t,'(i2)') nh
         write (t,'(a2)') s(4:5)
         read (t,'(i2)') nm
         write (t,'(a2)') s(7:8)
         read (t,'(i2)') ns
         tb(i) = dble(nh) + dble(nm)/60.d0 + dble(ns)/3600.d0
         if (tb(i).lt.12.d0) tb(i) = tb(i) + 24.d0
      end do
    2 nib = i - 1
      close(1)

      write (*,'(" NM,NB: ",2i5)') nim,nib

      open (1, file = 'dm.dat')
      read (1,*) bgr
      close(1)
      
      do i = 1,nim
         do j = 1,nib-1
            if ((ti(i).gt.tb(j)).and.(ti(i).lt.tb(j+1))) then
               nb = j
               goto 3
            end if
         end do
         if (ti(i).lt.tb(1)) then
            nb = 1
            goto 3
         end if
         if (ti(i).gt.tb(nib)) then
            nb = nib - 1
         end if   
    3    continue
      
c interpolacja

         a = (bgrb(nb+1) - bgrb(nb))/(tb(nb+1) - tb(nb))
         bgact = a*(ti(i) - tb(nb)) + bgrb(nb)
         dif = bgr - bgact
         write (2,'("ftsproc subt ",a30,1x,a15,"num=",f7.2)') names(i),
     *     namd,dif
      end do
      stop
      end

      

