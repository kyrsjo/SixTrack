! =================================================================================================
!  STANDARD OUTPUT MODULE
!  Last modified: 22-03-2018
!  For CR version, this is the "buffer file" fort.92;
!  Otherwise write directly to "*" aka iso_fortran_env::output_unit (usually unit 6)
! =================================================================================================
module crcoall
  
  implicit none
  
  integer lout
  save lout
  
end module crcoall

! =================================================================================================
!  FILE UNITS MODULE
!  Written by: Veronica Berglyd Olsen, BE-ABP-HSS, March 2018
!  Last modified: 28-03-2018
! =================================================================================================
module file_units
  
  implicit none
  
  integer :: funit_minUnit, funit_maxUnit, funit_maxStrLen
  parameter(funit_minUnit=1000, funit_maxUnit=1999, funit_maxStrLen=100)
  
  integer,                        dimension(:), allocatable :: funit_usedUnits
  character(len=funit_maxStrLen), dimension(:), allocatable :: funit_usedByFile
  
  integer :: funit_nextUnit = funit_minUnit
  
  save funit_usedUnits, funit_usedByFile, funit_nextUnit

contains
  
  ! Request a new fileunit. The filename parameter is only for internal record keeping. It should
  ! be a string that describes what file, or set of files, the unit number is used for.
  subroutine funit_requestUnit(fileName, fileUnit)
    
    use crcoall
    
    implicit none
    
    character(len=*), intent(in)  :: fileName
    integer,          intent(out) :: fileUnit
    
    character(len=len(fileName)) cleanName
    
    integer ch
    logical isOpen
    
    ! Check if the subroutine is called for the first time, and initialise the arrays to zero size.
    if(funit_nextUnit == funit_minUnit) then
      allocate(funit_usedUnits(0))
      allocate(funit_usedByFile(0))
    end if
    
    ! Remove \0s from fileName
    cleanName = fileName
    do ch=1, len(cleanName)
      if(cleanName(ch:ch) == char(0)) then
        cleanName(ch:ch) = " "
      end if
    end do
    
10  continue
    
    fileUnit       = funit_nextUnit
    funit_nextUnit = funit_nextUnit + 1
    if(funit_nextUnit > funit_maxUnit) goto 30
    
    inquire(unit=fileUnit, opened=isOpen)
    if(isOpen) then 
      funit_usedUnits  = [funit_usedUnits,  fileUnit]
      funit_usedByFile = [funit_usedByFile, "Unknown"//repeat(" ",93)]
      goto 10
    else
      funit_usedUnits  = [funit_usedUnits,  fileUnit]
      funit_usedByFile = [funit_usedByFile, cleanName]
      goto 20
    end if

20  continue
    ! write(lout,"(a,i4,a,a)") "FUNIT> Unit ",fileUnit," assigned to file: ",trim(cleanName)
    return
    
30  continue
    write(lout,"(a)") "FUNIT> ERROR: Failed to find an available file unit for file ",trim(cleanName)
    stop -1
    
  end subroutine funit_requestUnit
  
  ! Lists all assigned file units to lout
  subroutine funit_listUnits
    
    use crcoall
    
    implicit none
    
    integer i
    
    write(lout,"(a)") "FUNIT> Dynamically assigned file units are:"
    do i=1, size(funit_usedUnits)
      write(lout,"(a,i4,a,a)") "FUNIT> Unit ",funit_usedUnits(i)," assigned to file: ",trim(funit_usedByFile(i))
    end do
    
  end subroutine funit_listUnits
  
  ! Writes all assigned file units to file_units.dat
  subroutine funit_dumpUnits
    
    use crcoall
    
    implicit none
    
    integer dumpUnit, i
    logical isOpen
    
    call funit_requestUnit("file_units.dat",dumpUnit)
    inquire(unit=dumpUnit, opened=isOpen)
    if(isOpen) then
      write(lout,*) "ERROR in FUNIT when opening file_units.dat"
      write(lout,*) "Unit ",dumpUnit," was already taken."
      stop -1
    end if

    open(dumpUnit,file="file_units.dat",form="formatted")
    write(dumpUnit,"(a)") "# unit  assigned_to"
    do i=1, size(funit_usedUnits)
      write(dumpUnit,"(i6,a,a)") funit_usedUnits(i),"  ",trim(funit_usedByFile(i))
    end do
    close(dumpUnit)
    
  end subroutine funit_dumpUnits
  
  ! Closes all units opened by the module
  subroutine funit_closeUnits
    
    implicit none
    
    integer chkUnit
    logical isOpen
    
    do chkUnit=funit_minUnit, funit_nextUnit-1
      inquire(unit=chkUnit, opened=isOpen)
      if(isOpen) close(chkUnit)
    end do
    
  end subroutine funit_closeUnits

end module file_units
! =================================================================================================
