      subroutine write_avs_node_mat(lu,ifdual,mout)
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
CD1 Output AVS scalar node information for FEHM mesh materials.
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
CD2 $Log:   /pvcs.config/fehm90/src/write_avs_node_mat.f_a  $
!D2 
!D2    Rev 2.5   06 Jan 2004 10:43:06   pvcs
!D2 FEHM Version 2.21, STN 10086-2.21-00, Qualified October 2003
!D2 
!D2    Rev 2.4   29 Jan 2003 09:24:42   pvcs
!D2 FEHM Version 2.20, STN 10086-2.20-00
!D2 
!D2    Rev 2.3   14 Nov 2001 13:29:16   pvcs
!D2 FEHM Version 2.12, STN 10086-2.12-00
!D2 
!D2    Rev 2.2   06 Jun 2001 13:28:44   pvcs
!D2 FEHM Version 2.11, STN 10086-2.11-00
!D2 
!D2    Rev 2.1   30 Nov 2000 12:13:30   pvcs
!D2 FEHM Version 2.10, STN 10086-2.10-00
!D2 
!D2    Rev 2.0   Fri May 07 14:48:18 1999   pvcs
!D2 FEHM Version 2.0, SC-194 (Fortran 90)
CD2 
CD2    Rev 1.3   Fri Feb 02 14:20:54 1996   hend
CD2 Updated Requirements Traceability
CD2 
CD2    Rev 1.2   01/20/95 13:30:58   tam
CD2 Changed format for strings from * to a56, kept length to 80 so left justified
CD2 
CD2    Rev 1.1   12/12/94 16:29:40   tam
CD2 coerced irlp and icap to floats during write to avs file
CD2 
CD2    Rev 1.0   08/23/94 15:34:16   llt
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

      use avsio, only : iocord, iogeo, iokd, geoname
      use comai
      use combi, only : corz
      use comdi
      use comchem, only : cpntnam
      use comrxni, only : rxn_flag
      use davidi

      implicit none

      integer i, j, lu, ifdual, maxtitle, mout, length, ic1, ic2
      integer il, open_file, nelm(ns_in)
      integer icord1, icord2, icord3
      parameter(maxtitle = 22)
      character*3 dls
      character*5 char_type, dual_char
      character*15 nform
      character*300 temp_string
      character*42 title(maxtitle), units(maxtitle), pstring
      character*42, allocatable :: title_kd(:)
      character*600 print_title, vstring
      real*8 perm_fac
      parameter (perm_fac=1.d-6)

c     If this structure changes, also change the binary version
c     To ensure label is left justified, an <= string length
c       adding avsx output option  --  can assign integer perms then plot
c       the material types in avsx with a discrete colorbar.  PHS 8/11/2000      
c------------------------------------------------------------------------------
      temp_string = ''
      print_title = ''
      pstring = ''
      dual_char = ''
      if (ifdual .ne. 0) dual_char = 'Dual '
      title(1) = trim(dual_char) // 'Permeability (m**2) in X'
      title(2) = trim(dual_char) // 'Permeability (m**2) in Y'
      title(3) = trim(dual_char) // 'Permeability (m**2) in Z'
      title(4) = trim(dual_char) // 'Thermal Conductivity (W/m*K) in X'
      title(5) = trim(dual_char) // 'Thermal Conductivity (W/m*K) in Y'
      title(6) = trim(dual_char) // 'Thermal Conductivity (W/m*K) in Z'
      title(7) = trim(dual_char) // 'Porosity'
      title(15)= trim(dual_char) // 'Rock bulk density (kg/m**3)'
      title(8) = trim(dual_char) // 'Rock specific heat (MJ/kg*K)'
      title(9) = trim(dual_char) // 'Capillary pressure (MPa)'
      title(10)= trim(dual_char) // 'Relative permeability model'
      title(11)= trim(dual_char) // 'Capillary pressure model'
      title(12) = 'X coordinate (m)'
      title(13) = 'Y coordinate (m)'
      title(14) = 'Z coordinate (m)'         
      
      units(1) = '(m**2)'
      units(2) = '(m**2)'
      units(3) = '(m**2)'
      units(4) = '(W/m*K)'
      units(5) = '(W/m*K)'
      units(6) = '(W/m*K)'
      units(7) = '(non dim)'
      units(15) = '(kg/m**3)'
      units(8) = '(MJ/kg*K)'
      units(9) = '(MPa)'
      units(10)= '(flag)'
      units(11)= '(flag)'
      ic1 = 1
      if(altc(1:3).eq.'avs' .and. altc(4:4) .ne. 'x') then
         write (temp_string, '(i2)') mout
         ic2 = len_trim(temp_string)
         pstring(ic1:ic2) = temp_string
         write (temp_string, '(a2)') ' 1'
         do i = 1, mout
            ic1 = ic2 + 1
            ic2 = ic2 + len_trim(temp_string)
            pstring(ic1:ic2) = temp_string          
         end do
         length = len_trim(pstring)
         write (lu, '(42a)') pstring(1:length)
         if (idoff .ne. -1) then
! Permeability will be written
            write (lu, 100) trim(title(1)), trim(units(1))
            write (lu, 100) trim(title(2)), trim(units(2))
            write (lu, 100) trim(title(3)), trim(units(3))
         end if     
         if (ico2 .gt. 0 .or. ice .ne. 0) then
! Conductivity will be written
            write (lu, 100) trim(title(4)), trim(units(4))
            write (lu, 100) trim(title(5)), trim(units(5))
            write (lu, 100) trim(title(6)), trim(units(6))
         end if
! Porosity, bulk density and specific heat will be written
         write (lu, 100) trim(title(7)), trim(units(7))
         write (lu, 100) trim(title(15)), trim(units(15))
         write (lu, 100) trim(title(8)), trim(units(8))
         if (irdof .ne. 13) then
! Capillary pressure will be written
            write(lu, 100) trim(title(9)), trim(units(9))
         end if
         if (rlp_flag .eq. 1) then
! rlp and cap model flags will be written if rlp_flag .eq. 1
            write (lu, 100) trim(title(10)), trim(units(10))
            write (lu, 100) trim(title(11)), trim(units(11))
         end if
         if (iccen .eq. 1 .and. iokd .eq. 1 .and. rxn_flag .eq. 0) then
! Kd will be output for each transport specie and model
            allocate (title_kd(nspeci))
            do i = 1, nspeci
               title_kd(i) = trim(cpntnam(i)) // ' (Kd l/kg) (l/kg)'
            end do
         end if
      else
         ic1 = 1
         ic2 = 0
         if (altc(1:4) .eq. 'avsx') then
            dls = ' : '
            write (nform, 200) dls
            temp_string = 'node'
         else if (altc(1:3) .eq. 'tec') then
!            nform = '(' // "'" // ' "' // "', a, '" // '"' // "')"
            write (nform, 300)
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
! Write X coordinate
               if (icnl .ne. 3 .and. icnl .ne. 6) then
                  write(temp_string,nform) trim(title(12))
                  ic2 = ic2 + len_trim(temp_string)
                  print_title(ic1:ic2) = temp_string
                  ic1 = ic2 + 1
               end if
! Write Y coordinate
               if (icnl .ne. 2 .and. icnl .ne. 5) then
                  write(temp_string,nform) trim(title(13))
                  ic2 = ic2 + len_trim(temp_string)
                  print_title(ic1:ic2) = temp_string
                  ic1 = ic2 + 1
               end if
! Write Z coordinate
               if (icnl .ne. 1 .and. icnl .ne. 4) then
                  write(temp_string,nform) trim(title(14))
                  ic2 = ic2 + len_trim(temp_string)
                  print_title(ic1:ic2) = temp_string
                  ic1 = ic2 + 1
               end if
               write (temp_string, fmt=nform) 'node'
            else
               write (temp_string, fmt=nform) 'node'
            end if
         else if (altc(1:3) .eq. 'sur') then
            dls = ', '
            write (nform, 200) dls
            temp_string = 'node'
         end if
         ic2 = ic2 + len_trim(temp_string)
         print_title(ic1:ic2) = temp_string
         ic1 = ic2 + 1
         if (idoff .ne. -1) then
! Permeability will be written
            write (temp_string, fmt=nform) trim(title(1))
            ic2 = ic2 + len_trim(temp_string)
            print_title(ic1:ic2) = temp_string
            ic1 = ic2 + 1
            write (temp_string, fmt=nform) trim(title(2))
            ic2 = ic2 + len_trim(temp_string)
            print_title(ic1:ic2) = temp_string
            ic1 = ic2 + 1
            write (temp_string, fmt=nform) trim(title(3))
            ic2 = ic2 + len_trim(temp_string)
            print_title(ic1:ic2) = temp_string
            ic1 = ic2 + 1
         end if     
         if (ico2 .gt. 0 .or. ice .ne. 0) then
! Conductivity will be written
            write (temp_string, fmt=nform) trim(title(4))
            ic2 = ic2 + len_trim(temp_string)
            print_title(ic1:ic2) = temp_string
            ic1 = ic2 + 1
            write (temp_string, fmt=nform) trim(title(5))
            ic2 = ic2 + len_trim(temp_string)
            print_title(ic1:ic2) = temp_string
            ic1 = ic2 + 1
            write (temp_string, fmt=nform) trim(title(6))
            ic2 = ic2 + len_trim(temp_string)
            print_title(ic1:ic2) = temp_string
            ic1 = ic2 + 1
         end if
! Porosity, bulk density, and specific heat will be written
         write (temp_string, fmt=nform) trim(title(7))
         ic2 = ic2 + len_trim(temp_string)
         print_title(ic1:ic2) = temp_string
         ic1 = ic2 + 1
         write (temp_string, fmt=nform) trim(title(15))
         ic2 = ic2 + len_trim(temp_string)
         print_title(ic1:ic2) = temp_string
         ic1 = ic2 + 1
         write (temp_string, fmt=nform) trim(title(8))
         ic2 = ic2 + len_trim(temp_string)
         print_title(ic1:ic2) = temp_string
         ic1 = ic2 + 1
         if (irdof .ne. 13) then
! Capillary pressure will be written
            write(temp_string, fmt=nform) trim(title(9))
            ic2 = ic2 + len_trim(temp_string)
            print_title(ic1:ic2) = temp_string
            ic1 = ic2 + 1
         end if
         if (rlp_flag .eq. 1) then
! rlp and cap model flags will be written if rlp_flag .eq. 1
            write (temp_string, fmt=nform) trim(title(10))
            ic2 = ic2 + len_trim(temp_string)
            print_title(ic1:ic2) = temp_string
            ic1 = ic2 + 1
            write (temp_string, fmt=nform) trim(title(11))
            ic2 = ic2 + len_trim(temp_string)
            print_title(ic1:ic2) = temp_string
            ic1 = ic2 + 1
         end if
! Kd will be written
         if (iccen .eq. 1 .and. iokd .eq. 1 .and. rxn_flag .eq.0) then
            allocate (title_kd(nspeci))
            do i = 1, nspeci
               title_kd(i) = trim(cpntnam(i)) // ' (Kd l/kg)'
               write (temp_string, fmt=nform) trim(title_kd(i))
               ic2 = ic2 + len_trim(temp_string)
               print_title(ic1:ic2) = temp_string
               ic1 = ic2 + 1
            end do
         end if
         length = len_trim(print_title)
         if (altc(1:3) .ne. 'tec') then
            write (lu, '(a)') print_title(1:length)
         else
            write (lu, '("VARIABLES = ", a)') print_title(1:length)
            if (iogeo .eq. 1) then
               select case (ns_in)
               case (5,6,8)
                  write (temp_string, 135) neq, nei_in, 'FEBRICK'
               case (4)
                  if (icnl .eq. 0) then
                     write (temp_string, 135) neq, nei_in, 
     &                    'FETETRAHEDRON'
                  else
                     write (temp_string, 135) neq, nei_in, 
     &                    'FEQUADRILATERAL'
                  end if
               case (3)
                  write (temp_string, 135) neq, nei_in, 'FETRIANGLE'
               case (2)
                  write (temp_string, 135) neq, nei_in, 'FELINESEG'
               case (0)
! fdm grid
                  write (temp_string, '(a)') ''
               end select
               write (lu, 130) trim(temp_string)
            end if
         endif
      end if
 130  format('ZONE T = "Material properties"', a)
 135  format(', N = ', i8, ', E = ', i8, ', DATAPACKING = POINT',
     &     ', ZONETYPE = ', a)

      temp_string = ''
      vstring = ''

      if (altc(1:4) .ne. 'avsx' .and. altc(1:3) .ne. 'sur') then
         if (ifdual .ne. 0) ifdual = 1
         do j = 1,neq
            ic1 = 1
            ic2 = 0

            if (altc(1:3) .eq. 'tec' .and. iocord .ne. 0) then
! Write coordinates
               do i = icord1, icord2, icord3
                  write(temp_string,'(g16.9)') corz(j,i)
                  ic2 = ic1 + 17
                  vstring(ic1:ic2) = temp_string
                  ic1 = ic2 + 1
               end do
            end if

            i = j + neq*ifdual
            write (temp_string, '(i10.10)') j
            ic2 = ic2 + len_trim(temp_string)
            vstring(ic1:ic2) = temp_string
            ic1 = ic2 + 1
            if (idoff .ne. -1) then
! Permeability will be written
               write (temp_string, '(3(x,1p,g14.6))') pnx(i)*perm_fac, 
     &              pny(i)*perm_fac, pnz(i)*perm_fac
               ic2 = ic2 + len_trim(temp_string)
               vstring(ic1:ic2) = temp_string
               ic1 = ic2 + 1
            end if     
            if (ico2 .gt. 0 .or. ice .ne. 0) then
! Conductivity will be written
               write (temp_string, '(3(x,1p,g14.6))') thx(i), thy(i), 
     &              thz(i)
               ic2 = ic2 + len_trim(temp_string)
               vstring(ic1:ic2) = temp_string
               ic1 = ic2 + 1
            end if
! Porosity and specific heat will be written
            write (temp_string,'(3(x,1p,g14.6))') ps(i), denr(i), cpr(i)
            ic2 = ic2 + len_trim(temp_string)
            vstring(ic1:ic2) = temp_string
            ic1 = ic2 + 1
            if (irdof .ne. 13) then
! Capillary pressure will be written
               write (temp_string, '(x,1p,g14.6)') pcp(i)
               ic2 = ic2 + len_trim(temp_string)
               vstring(ic1:ic2) = temp_string
               ic1 = ic2 + 1
            end if
            if (rlp_flag .eq. 1) then
! rlp and cap model flags will be written if rlp_flag .eq. 1
               write (temp_string, '(2(x,i4))') irlp(i), icap(i) 
               ic2 = ic2 + len_trim(temp_string)
               vstring(ic1:ic2) = temp_string
               ic1 = ic2 + 1
            end if
            if(iccen .eq. 1 .and. iokd .eq. 1 .and. rxn_flag .eq.0) then
               do i = 1, nspeci
                  write (temp_string, '(1x,g14.6)') a1adfl(i,itrc(j))
                  ic2 = ic2 + len_trim(temp_string)
                  vstring(ic1:ic2) = temp_string
                  ic1 = ic2 + 1
               end do
            end if
            length = len_trim(vstring)
            write (lu, '(a)') vstring(1:length)
         end do
         if (altc(1:3) .eq. 'tec' .and. iogeo .eq. 1) then
! Read the element connectivity and write to tec file
            il = open_file(geoname,'old')
            do i = 1, neq
               read(il,*)
            end do
            do i = 1, nei_in
               read (il,*) ic1,ic2,char_type,(nelm(j), j=1,ns_in)
               write(lu, '(8(i8))') (nelm(j), j=1,ns_in)
            end do
            close (il)
         end if

      else
         if (ifdual .ne. 0) ifdual = 1
         do j = 1,neq
            i = j + neq*ifdual
            ic1 = 1
            write (temp_string, '(i10.10)') j
            ic2 = len_trim(temp_string)
            vstring(ic1:ic2) = temp_string
            ic1 = ic2 + 1
            if (idoff .ne. -1) then
! Permeability will be written
               write (temp_string, '(3(a,1p,g14.6))')
     &              dls, pnx(i)*perm_fac, dls, pny(i)*perm_fac, dls,
     &              pnz(i)*perm_fac
               ic2 = ic2 + len_trim(temp_string)
               vstring(ic1:ic2) = temp_string
               ic1 = ic2 + 1
            end if     
            if (ico2 .gt. 0 .or. ice .ne. 0) then
! Conductivity will be written
               write (temp_string, '(3(a,1p,g14.6))') dls, thx(i),
     &              dls, thy(i), dls, thz(i)
               ic2 = ic2 + len_trim(temp_string)
               vstring(ic1:ic2) = temp_string
               ic1 = ic2 + 1
            end if
! Porosity, bulk density, and specific heat will be written
            write (temp_string, '(3(a,1p,g14.6))') dls, ps(i), 
     &           dls, denr(i)
            ic2 = ic2 + len_trim(temp_string)
            vstring(ic1:ic2) = temp_string
            ic1 = ic2 + 1
            if (irdof .ne. 13) then
! Capillary pressure will be written
               write (temp_string, '(a,1p,g14.6)') dls, pcp(i)
               ic2 = ic2 + len_trim(temp_string)
               vstring(ic1:ic2) = temp_string
               ic1 = ic2 + 1
            end if
            if (rlp_flag .eq. 1) then
! rlp and cap model flags will be written if rlp_flag .eq. 1
               write (temp_string, '(2(a,i4))') dls, irlp(i), 
     &              dls, icap(i) 
               ic2 = ic2 + len_trim(temp_string)
               vstring(ic1:ic2) = temp_string
               ic1 = ic2 + 1
            end if
! Kd will be written
            if(iccen .eq. 1 .and. iokd .eq. 1 .and. rxn_flag .eq.0) then
               do i = 1, nspeci
                  write (temp_string, '(a,g14.6)') dls, 
     &                 a1adfl(i,itrc(j))
                  ic2 = ic2 + len_trim(temp_string)
                  vstring(ic1:ic2) = temp_string
                  ic1 = ic2 + 1
               end do
            end if
            length = len_trim(vstring)
            write (lu, '(a)') vstring(1:length)
         end do

      end if

      
 100  format(a, ', ', a)
 200  format("( ' ", a, "', a)")
 300  format("('",' "', "', a, '",'"',"')")
      
      return
      end
