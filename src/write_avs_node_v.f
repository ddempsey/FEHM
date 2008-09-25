      subroutine write_avs_node_v(icall,pnxv,pnyv,pnzv,
     1                      pnxl,pnyl,pnzl,
     2                      neq,nvector,lu,
     3                      ifdual)
!***********************************************************************
!  Copyright, 1993, 2004,  The  Regents of the University of California.
!  This program was prepared by the Regents of the University of 
!  California at Los Alamos National Laboratory (the University) under  
!  contract No. W-7405-ENG-36 with the U.S. Department of Energy (DOE). 
!  All rights in the program are reserved by the DOE and the University. 
!  Permission is granted to the public to copy and use this software 
!  without charge, provided that this Notice and any statement of 
!  authorship are reproduced on all copies. Neither the U.S. Government 
!  nor the University makes any warranty, express or implied, or 
!  assumes any liability or responsibility for the use of this software.
C***********************************************************************
CD1
CD1 PURPOSE
CD1
CD1 Output AVS vector node information for FEHM
CD1
C***********************************************************************
CD2
CD2 REVISION HISTORY
CD2
CD2 Revision                    ECD
CD2 Date         Programmer     Number  Comments
CD2
CD2 10-SEP-93    Carl Gable     22      Initial implementation.
CD2
CD2 $Log:   /pvcs.config/fehm90/src/write_avs_node_v.f_a  $
!D2 
!D2    Rev 2.5   06 Jan 2004 10:44:30   pvcs
!D2 FEHM Version 2.21, STN 10086-2.21-00, Qualified October 2003
!D2 
!D2    Rev 2.4   29 Jan 2003 09:24:46   pvcs
!D2 FEHM Version 2.20, STN 10086-2.20-00
!D2 
!D2    Rev 2.3   14 Nov 2001 13:29:18   pvcs
!D2 FEHM Version 2.12, STN 10086-2.12-00
!D2 
!D2    Rev 2.2   06 Jun 2001 13:28:46   pvcs
!D2 FEHM Version 2.11, STN 10086-2.11-00
!D2 
!D2    Rev 2.1   30 Nov 2000 12:13:34   pvcs
!D2 FEHM Version 2.10, STN 10086-2.10-00
!D2 
!D2    Rev 2.0   Fri May 07 14:48:22 1999   pvcs
!D2 FEHM Version 2.0, SC-194 (Fortran 90)
CD2 
CD2    Rev 1.2   Fri Feb 02 14:24:00 1996   hend
CD2 Updated Requirements Traceability
CD2 
CD2    Rev 1.1   01/20/95 13:32:26   tam
CD2 Changed format for strings from * to a56, kept length to 80 so left justified
CD2 
CD2    Rev 1.0   08/23/94 15:34:26   llt
CD2 Original version
CD2
C***********************************************************************
CD3
CD3 INTERFACES
CD3
CD3 Formal Calling Parameters
CD3
CD3   Identifier      Type     Use  Description
CD3
CD3 Interface Tables
CD3
CD3   None
CD3
CD3 Files
CD3
CD3   None
CD3
C***********************************************************************
CD4
CD4 GLOBAL OBJECTS
CD4
CD4 None
CD4
C***********************************************************************
CD5
CD5 LOCAL IDENTIFIERS
CD5
CD5 Local Constants
CD5
CD5   None
CD5
CD5 Local Types
CD5
CD5   None
CD5
CD5 Local variables
CD5
CD5   Identifier      Type     Description
CD5
CD5 Local Subprograms
CD5
CD5   None
CD5
C***********************************************************************
CD6
CD6 FUNCTIONAL DESCRIPTION
CD6
C***********************************************************************
CD7
CD7 ASSUMPTIONS AND LIMITATIONS
CD7
CD7 None
CD7
C***********************************************************************
CD8
CD8 SPECIAL COMMENTS
CD8
CD8  Requirements from SDN: 10086-RD-2.20-00
CD8    SOFTWARE REQUIREMENTS DOCUMENT (RD) for the
CD8    FEHM Application Version 2.20
CD8
C***********************************************************************
CD9
CD9 REQUIREMENTS TRACEABILITY
CD9
CD9 2.6 Provide Input/Output Data Files
CD9 3.0 INPUT AND OUTPUT REQUIREMENTS
CD9
C***********************************************************************
CDA
CDA REFERENCES
CDA
CDA None
CDA
C***********************************************************************
CPS
CPS PSEUDOCODE
CPS
CPS BEGIN 
CPS   
CPS END 
CPS 
C***********************************************************************

      use avsio
      use comai, only : altc, days, icnl, jdate, jtime, verno, wdd
      use combi, only : corz, izonef
      use comdi, only : nsurf, izone_surf, izone_surf_nodes
      implicit none
      
      integer maxvector
      parameter (maxvector = 3)
      character*3 dlstring
      character*5 cstring, dual_char
      character*6 share_string
      character*14 tailstring
      character*40 :: tec_string = ''
      character*45 title(3*maxvector), title2(2)
      character*50 fstring
      character*500 tstring
      integer icall, neq, nvector, lu, ifdual, length
      integer i, istep, nout, iz, idz, iendz, j, k, iocord_temp
      integer icord1, icord2, icord3
      real*8  write_array(9)
      real*8  pnxv(neq), pnyv(neq), pnzv(neq)
      real*8  pnxl(neq), pnyl(neq), pnzl(neq)
      
      save tec_string

      if(nvector .gt. maxvector)then
         write(lu,*)'--------------------------------------------'
         write(lu,*)'ERROR: WRITE_AVS_NODE_V'
         write(lu,*)'nvector   = ',nvector,' is greater than '
         write(lu,*)'maxvector = ',maxvector
         write(lu,*)'Subroutine only able to handle 2 vectors'
         write(lu,*)'--------------------------------------------'
         return
      endif
      
      if(ifdual .eq. 0)then
         dual_char = ''
         tailstring = '_vec_node'
      elseif(ifdual .eq. 1)then
         dual_char ='Dual '
         tailstring = '_vec_dual_node'
      else
c     error
      endif

      if (iozone .ne. 0 ) then
         iendz = nsurf
      else 
         iendz = 1
         idz = iozone
      end if
      
      iocord_temp = iocord
      if (altc(1:3) .eq. 'tec' .or. altc(1:3) .eq. 'sur') then
         if (iocord .eq. 0) then
! Coordinates need to be output
            if (icnl .eq. 0) then
               iocord = 3
            else
               iocord = 2
            end if
         end if
      end if
      if (iocord .ne. 0) then
         select case (icnl)
         case (1, 4)
            icord1 = 1
            icord2 = 2
            icord3 = 1
         case (2, 5)
            icord1 = 1
            icord2 = 3
            icord3 = 2
         case(3, 6)
            icord1 = 1
            icord2 = 3
            icord3 = 1
         case default
            icord1 = 1
            icord2 = 3
            icord3 = 1
         end select
      end if

      nout = nvector
      if (iocord .ne. 0) nout = nout + 1

      title = ''
      title2 = ''
      if (altc(1:3) .eq. 'avs' .and. altc(4:4) .ne. 'x') then
         j = 0
         if (iocord .ne. 0 ) then
            j = j + 1
            title(j) = trim(dual_char) // 'XYZ coordinates, (m)'
         end if
         if (iovapor .ne. 0 ) then
            j = j + 1
            title(j) =  trim(dual_char) // 
     &           'Vapor Volume Flux (m3/[m2 s]), (m3/[m2 s])'
         end if
         if (ioliquid .ne. 0) then
            j = j + 1
            title(j) =  trim(dual_char) // 
     &           'Liquid Volume Flux (m3/[m2 s]), (m3/[m2 s])'
         end if
         dlstring = '" "'
      else
         if (altc(1:4) .eq. 'avsx') then
            dlstring = ' : '
         else if (altc(1:3) .eq. 'tec') then
            dlstring = '" "'
         else if (altc(1:3) .eq. 'sur') then
            dlstring = ', '
         end if
         j = 0
         if (altc(1:3) .eq. 'tec' .or. altc(1:3) .eq. 'sur') then
            if (altc(1:3) .eq. 'tec') then
               title2(1) = dlstring // trim(dual_char) // 'Node'
            else
               title2(1) = trim(dual_char) // 'Node'
            end if    
            k = 1
            if (iozid .ne. 0) then
               title2(2) = dlstring // trim(dual_char) // 'Zone'
               k = 2
            end if
         end if
         if (iocord .ne. 0 ) then
            if (altc(1:3) .eq. 'tec') then
               title(1) =  trim(dual_char) // 'X Coordinate (m)'
            else
               title(1) = dlstring // trim(dual_char) // 
     &              'X Coordinate (m)'
            end if
            title(2) = dlstring // trim(dual_char) // 'Y Coordinate (m)'
            if (iocord .eq. 3) then
               title(3) = dlstring // trim(dual_char) // 
     &              'Z Coordinate (m)'
               j = 3
            else
               j = 2
            end if
            if (iozid .ne. 0) then
               write (share_string, '(i1, "-", i1, ", ", i1)') 1, j, j+2
            else
               write (share_string, '(i1, "-", i1)') 1, j
            end if
         end if
         if (iovapor .ne. 0) then
            title(j + 1) = dlstring // trim(dual_char) // 
     &           'Vapor X Volume Flux (m3/[m2 s])'
            title(j + 2) = dlstring // trim(dual_char) //  
     &           'Vapor Y Volume Flux (m3/[m2 s])'
            if (iocord .eq. 3 .or. altc(1:4) .eq. 'avsx') then
               title(j + 3) = dlstring // trim(dual_char) //  
     &              'Vapor Z Volume Flux (m3/[m2 s])'
               j = j + 3
            else
               j = j + 2
            end if
         end if
         if (ioliquid .ne. 0) then
            title(j + 1) = dlstring // trim(dual_char) //  
     &           'Liquid X Volume Flux (m3/[m2 s])'
            title(j + 2) = dlstring // trim(dual_char) //  
     &           'Liquid Y Volume Flux (m3/[m2 s])'
            if (iocord .eq. 3 .or. altc(1:4) .eq. 'avsx') then
               title(j + 3) = dlstring // trim(dual_char) //  
     &              'Liquid Z Volume Flux (m3/[m2 s])'
               j = j + 3
            else
               j = j + 2
            end if
         end if
      end if
      nout = j

      if (altc(1:3) .ne. 'sur') then
         call namefile2(icall,lu,ioformat,tailstring,0)
! file will be opened in zone loop for surfer
      end if

      if(altc(1:4).eq.'avsx') then
         write(lu,200) days, (trim(title(i)), i = 1, nout)           
      else if(altc(1:3).eq.'avs') then
         write(lu,90) nout, (3, i = 1, nout)
         write(lu, 100) (trim(title(i)), i = 1, nout)
      else if(altc(1:3).eq.'tec') then
         if (icall .eq. 1) then
            write(lu,301) verno, jdate, jtime, trim(wdd)
c            write(lu,300) (trim(title(i)), i = 1, iocord), 
c     &           (trim(title2(i)), i = 1, k), 
c     &           (trim(title(i)), i = iocord + 1, nout), '"'
            tstring = 'VARIABLES = "'
            do i = 1, iocord
               tstring = trim(tstring) // trim(title(i))
            end do
            do i = 1, k
               tstring = trim(tstring) // trim(title2(i))
            end do
            do i = iocord + 1, nout
               tstring = trim(tstring) // trim(title(i))
            end do
            tstring = trim(tstring) // '"'
            write(lu, '(a)') trim(tstring)
         end if
         if (iozone .ne. 0) write(lu,302) trim(timec_string)
      else if(altc(1:3).eq.'sur') then
c         write(tstring,400) (trim(title2(i)), i = 1, k),
c     &        (trim(title(i)), j = 1, nout)
         tstring = ''
         do i = 1, k
            tstring = trim(tstring) // trim(title2(i))
         end do
         do i = 1, nout
            tstring = trim(tstring) // trim(title(i))
         end do
      end if

      do iz = 1, iendz
! Zone loop
         if (iozone .ne. 0) then
            idz = izone_surf(iz)
         end if
         if (altc(1:3) .eq. 'tec') then
            if (iozone .ne. 0) then
               write (lu, 95) idz, trim(tec_string)
            else
               write (lu, 96) trim(timec_string), trim(tec_string)
            end if
            if (icall .eq. 1) then
               write (tec_string, 303) trim(share_string), iz
            end if
         else if (altc(1:3) .eq. 'sur') then
            call namefile2(icall,lu,ioformat,tailstring,idz)
            write(lu, '(a)') trim(tstring)
         end if
         do i = 1,neq
! Node loop
            if (iozone .eq. 1) then
               if (izone_surf_nodes(i).ne.idz) goto 199
            end if
            if (iocord .ne. 0) then
               if (iocord .eq. 2 .and. altc(1:3) .eq. 'avs') then
                  do j = 1, 3
                     write_array(j) = corz(i, j)
                  end do
               else
                  do j = icord1, icord2, icord3
                     write_array(j) = corz(i, j)
                  end do
                  j = iocord + 1
               end if
            else
               j = 1
            end if
            if (iovapor .eq. 1) then
               write_array(j) = pnxv(i)
               j = j + 1
               write_array(j) = pnyv(i)
               j = j + 1
               if (iocord .eq. 3 .or. altc(1:3) .eq. 'avs') then
                  write_array(j) = pnzv(i)
                  j = j + 1
               end if
            end if
            if (ioliquid .eq. 1) then
               write_array(j) = pnxl(i)
               j = j + 1
               write_array(j) = pnyl(i)
               j = j + 1
               if (iocord .eq. 3 .or. altc(1:3) .eq. 'avs') then
                  write_array(j) = pnzl(i)
                  j = j + 1
               end if
            end if
            j = j - 1
            if (altc(1:3) .eq. 'tec') then
               if (icall .eq. 1 .and. iozid .ne. 0) then
                  write (fstring, 130) iocord, j - iocord - 2
                  write(lu, fstring) (write_array(k), k = 1, iocord),
     &                 i, izonef(i), (write_array(k), k = iocord + 1, j)
               else if (icall .eq. 1 .and. iozid .eq. 0) then
                  write (fstring, 120) iocord, j - iocord - 1
                  write(lu, fstring) (write_array(k), k = 1, iocord),
     &                 i, (write_array(k), k = iocord + 1, j)
               else
                  write (fstring, 110) j - iocord
                  write(lu, fstring) i, (write_array(k), 
     &                 k = iocord + 1, j)
               end if
            else if (altc(1:3).eq.'sur') then
               if (iozid .ne. 0) then
                  write (fstring, 220) dlstring, j, dlstring
                  write(lu, fstring) i, izonef(i), 
     &                 (write_array(k), k = 1, j)
               else
                  write (fstring, 210) j, dlstring
                  write(lu, fstring) i, (write_array(k), k = 1, j)
               end if
            else if (altc(1:4).eq.'avsx') then
               write (fstring, 210) j, dlstring
               write(lu, fstring) i, (write_array(k), k = 1, j)
            else              
               write (fstring, 110) j
               write(lu, fstring) i, (write_array(k), k = 1, j)
            end if
 199     enddo 
      end do

      if (iocord .ne. iocord_temp) iocord = iocord_temp

 90   format(i1,2x,5(i5,2x))
 95   format('ZONE T = "',i4.4, '"', a)
c 96   format('ZONE T = "Simulation time ',1p,g16.9,' days"', a)
 96   format('ZONE T = ', a, a)   
 500  format(i10.10, 9(1x, g16.9))
 666  format(i10.10, 9(' : ', g16.9))
 667  format(i10.10, 9(', ', g16.9))
 100  format(a)
 110  format("(i10.10, ", i1, "(1x, g16.9))")
 120  format("(", i1, "(g16.9, 1x), i10.10, ", i1, "(1x, g16.9))" )
 130  format("(", i1, "(g16.9, 1x), i10.10, 1x, i4,", i1, 
     &     "(1x, g16.9))") 
 200  format('nodes at ', g16.9,' days', 9(a))
 210  format("(i10.10, ", i1, "('", a, "',g16.9))") 
 220  format("(i10.10, '", a, "', i4, ", i1, "('", a, "',g16.9))") 
 300  format('VARIABLES = "', 12(a))
 301  format ('TITLE = "', a30, 1x, a11, 1x, a8, 1x, a, '"')
c 302  format('TEXT T = "Simulation time ',1p,g16.9,' days"')
 302  format('TEXT T = ', a)
 303  format(', VARSHARELIST = ([', a,'] = ', i4, ')')
 400  format(11(a))
 
      return
      end
