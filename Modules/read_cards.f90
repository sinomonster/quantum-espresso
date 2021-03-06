!
! Copyright (C) 2002-2009 Quantum ESPRESSO group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
!---------------------------------------------------------------------------
MODULE read_cards_module
   !---------------------------------------------------------------------------
   !
   ! ...  This module handles the reading of cards from standard input
   ! ...  Written by Carlo Cavazzoni and modified for "path" implementation
   ! ...  by Carlo Sbraccia
   !
   USE kinds,     ONLY : DP
   USE io_global, ONLY : stdout
   USE constants, ONLY : angstrom_au
   USE parser,    ONLY : field_count, read_line, get_field
   USE io_global, ONLY : ionode, ionode_id
   !
   USE input_parameters
   !
   IMPLICIT NONE
   !
   SAVE
   !
   PRIVATE
   !
   PUBLIC :: read_cards
   !
   ! ... end of module-scope declarations
   !
   !  ----------------------------------------------
   !
CONTAINS
   !
   ! ... Read CARDS ....
   !
   ! ... subroutines
   !
   !----------------------------------------------------------------------
   SUBROUTINE card_default_values( )
      !----------------------------------------------------------------------
      !
      USE autopilot, ONLY : init_autopilot
      !
      IMPLICIT NONE
      !
      !
      ! ... mask that control the printing of selected Kohn-Sham occupied
      ! ... orbitals, default allocation
      !
      CALL allocate_input_iprnks( 0, nspin )
      nprnks  = 0
      !
      ! ... Simulation cell from standard input
      !
      trd_ht = .false.
      rd_ht  = 0.0_DP
      !
      ! ... dipole
      !
      tdipole_card = .false.
      !
      ! ... Constraints
      !
      nconstr_inp    = 0
      constr_tol_inp = 1.E-6_DP
      !
      ! ... ionic mass initialization
      !
      atom_mass = 0.0_DP
      !
      ! ... dimension of the real space Ewald summation
      !
      iesr_inp = 1
      !
      ! ... k-points
      !
      k_points = 'gamma'
      tk_inp   = .false.
      nkstot   = 1
      nk1      = 0
      nk2      = 0
      nk3      = 0
      k1       = 0
      k2       = 0
      k3       = 0
      !
      ! ... Grids
      !
      t2dpegrid_inp = .false.
      !
      ! ... Electronic states
      !
      tf_inp = .false.
      !
      ! ... Hartree planar mean
      !
      tvhmean_inp = .false.
      vhnr_inp    = 0
      vhiunit_inp = 0
      vhrmin_inp  = 0.0_DP
      vhrmax_inp  = 0.0_DP
      vhasse_inp  = 'K'
      !
      ! ... ion_velocities
      !
      tavel = .false.
      !
      ! ... setnfi
      !
      newnfi_card  = -1
      tnewnfi_card = .false.
      !
      CALL init_autopilot()
      !
      RETURN
      !
   END SUBROUTINE card_default_values
   !
   !
   !----------------------------------------------------------------------
   SUBROUTINE read_cards ( prog )
      !----------------------------------------------------------------------
      !
      USE autopilot, ONLY : card_autopilot
      !
      IMPLICIT NONE
      !
      CHARACTER(len=2)           :: prog   ! calling program ( PW, CP, WA )
      CHARACTER(len=256)         :: input_line
      CHARACTER(len=80)          :: card
      CHARACTER(len=1), EXTERNAL :: capital
      LOGICAL                    :: tend
      INTEGER                    :: i
      !
      !
      CALL card_default_values( )
      !
100   CALL read_line( input_line, end_of_file=tend )
      !
      IF( tend ) GOTO 120
      IF( input_line == ' ' .or. input_line(1:1) == '#' ) GOTO 100
      !
      READ (input_line, *) card
      !
      DO i = 1, len_trim( input_line )
         input_line( i : i ) = capital( input_line( i : i ) )
      ENDDO
      !
      IF ( trim(card) == 'AUTOPILOT' ) THEN
         !
         CALL card_autopilot( input_line )
         !
      ELSEIF ( trim(card) == 'ATOMIC_SPECIES' ) THEN
         !
         CALL card_atomic_species( input_line, prog )
         !
      ELSEIF ( trim(card) == 'ATOMIC_POSITIONS' ) THEN
         !
         CALL card_atomic_positions( input_line, prog )
         !
      ELSEIF ( trim(card) == 'ATOMIC_FORCES' ) THEN
         !
         CALL card_atomic_forces( input_line, prog )
         !
      ELSEIF ( trim(card) == 'SETNFI' ) THEN
         !
         CALL card_setnfi( input_line )
         IF ( ( prog == 'PW' .or. prog == 'CP' ) .and. ionode ) &
            WRITE( stdout,'(A)') 'Warning: card '//trim(input_line)//' ignored'
         !
      ELSEIF ( trim(card) == 'CONSTRAINTS' ) THEN
         !
         CALL card_constraints( input_line )
         !
      ELSEIF ( trim(card) == 'COLLECTIVE_VARS' ) THEN
         !
         CALL card_collective_vars( input_line )
         !
      ELSEIF ( trim(card) == 'VHMEAN' ) THEN
         !
         CALL card_vhmean( input_line )
         IF ( ( prog == 'PW' .or. prog == 'CP' ) .and. ionode ) &
            WRITE( stdout,'(A)') 'Warning: card '//trim(input_line)//' ignored'
         !
      ELSEIF ( trim(card) == 'DIPOLE' ) THEN
         !
         CALL card_dipole( input_line )
         IF ( ( prog == 'PW' .or. prog == 'CP' ) .and. ionode ) &
            WRITE( stdout,'(A)') 'Warning: card '//trim(input_line)//' ignored'
         !
      ELSEIF ( trim(card) == 'ESR' ) THEN
         !
         CALL card_esr( input_line )
         IF ( ( prog == 'PW' .or. prog == 'CP' ) .and. ionode ) &
            WRITE( stdout,'(A)') 'Warning: card '//trim(input_line)//' ignored'
         !
      ELSEIF ( trim(card) == 'K_POINTS' ) THEN
         !
         IF ( ( prog == 'CP' ) ) THEN
            IF( ionode ) &
               WRITE( stdout,'(A)') 'Warning: card '//trim(input_line)//' ignored'
         ELSE
            CALL card_kpoints( input_line )
         ENDIF
         !
      ELSEIF ( trim(card) == 'OCCUPATIONS' ) THEN
         !
         CALL card_occupations( input_line )
         !
      ELSEIF ( trim(card) == 'CELL_PARAMETERS' ) THEN
         !
         CALL card_cell_parameters( input_line )
         !
      ELSEIF ( trim(card) == 'ATOMIC_VELOCITIES' ) THEN
         !
         CALL card_ion_velocities( input_line )
         IF ( prog == 'CP' .and. ionode ) &
            WRITE( stdout,'(A)') 'Warning: card '//trim(input_line)//' ignored'
         !
      ELSEIF ( trim(card) == 'KSOUT' ) THEN
         !
         CALL card_ksout( input_line )
         IF ( ( prog == 'PW' ) .and. ionode ) &
            WRITE( stdout,'(a)') 'Warning: card '//trim(input_line)//' ignored'
         !
      ELSEIF ( trim(card) == 'CLIMBING_IMAGES' ) THEN
         !
         CALL card_climbing_images( input_line )

      ELSEIF ( trim(card) == 'PLOT_WANNIER' ) THEN
         !
         CALL card_plot_wannier( input_line )

      ELSEIF ( trim(card) == 'WANNIER_AC' .and. ( prog == 'WA' )) THEN
         !
         CALL card_wannier_ac( input_line )

      ELSE
         !
         IF ( ionode ) &
            WRITE( stdout,'(A)') 'Warning: card '//trim(input_line)//' ignored'
         !
      ENDIF
      !
      ! ... END OF LOOP ... !
      !
      GOTO 100
      !
120      CONTINUE
      !
      RETURN
      !
   END SUBROUTINE read_cards

   !
   ! ... Description of the allowed input CARDS
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   ! ATOMIC_SPECIES
   !
   !   set the atomic species been read and their pseudopotential file
   !
   ! Syntax:
   !
   !    ATOMIC_SPECIE
   !      label(1)    mass(1)    psfile(1)
   !       ...        ...        ...
   !      label(n)    mass(n)    psfile(n)
   !
   ! Example:
   !
   ! ATOMIC_SPECIES
   !  O 16.0 O.BLYP.UPF
   !  H 1.00 H.fpmd.UPF
   !
   ! Where:
   !
   !      label(i)  ( character(len=4) )  label of the atomic species
   !      mass(i)   ( real )              atomic mass
   !                                      ( in u.m.a, carbon mass is 12.0 )
   !      psfile(i) ( character(len=80) ) file name of the pseudopotential
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   SUBROUTINE card_atomic_species( input_line, prog )
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      CHARACTER(len=2)   :: prog
      INTEGER            :: is, ip, ierr
      CHARACTER(len=4)   :: lb_pos
      CHARACTER(len=256) :: psfile
      LOGICAL, SAVE      :: tread = .false.
      !
      !
      IF ( tread ) THEN
         CALL errore( ' card_atomic_species  ', ' two occurrences', 2 )
      ENDIF
      IF ( ntyp > nsx ) THEN
         CALL errore( ' card_atomic_species ', ' nsp out of range ', ntyp )
      ENDIF
      !
      DO is = 1, ntyp
         !
         CALL read_line( input_line )
         READ( input_line, *, iostat=ierr ) lb_pos, atom_mass(is), psfile
            CALL errore( ' card_atomic_species ', 'cannot read atomic specie from: '//trim(input_line), abs(ierr))
         atom_pfile(is) = trim( psfile )
         lb_pos         = adjustl( lb_pos )
         atom_label(is) = trim( lb_pos )
         !
!             IF ( atom_mass(is) <= 0.0_DP ) THEN
!                CALL errore( ' card_atomic_species ',' invalid  atom_mass ', is )
!             END IF
         DO ip = 1, is - 1
            IF ( atom_label(ip) == atom_label(is) ) THEN
               CALL errore( ' card_atomic_species ', &
                           & ' two occurrences of the same atomic label ', is )
            ENDIF
         ENDDO
         !
      ENDDO
      taspc = .true.
      tread = .true.
      !
      RETURN
      !
   END SUBROUTINE card_atomic_species
   !
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   ! ATOMIC_POSITIONS
   !
   !   set the atomic positions in the cell
   !
   ! Syntax:
   !
   !   ATOMIC_POSITIONS (units_option)
   !     label(1) tau(1,1) tau(2,1) tau(3,1) mbl(1,1) mbl(2,1) mbl(3,1)
   !     label(2) tau(1,2) tau(2,2) tau(3,2) mbl(1,2) mbl(2,2) mbl(3,2)
   !      ...              ...               ...               ... ...
   !     label(n) tau(1,n) tau(2,n) tau(3,n) mbl(1,3) mbl(2,3) mbl(3,3)
   !
   ! Example:
   !
   ! ATOMIC_POSITIONS (bohr)
   !    O     0.0099    0.0099    0.0000  0 0 0
   !    H     1.8325   -0.2243   -0.0001  1 1 1
   !    H    -0.2243    1.8325    0.0002  1 1 1
   !
   ! Where:
   !
   !   units_option == crystal   position are given in scaled units
   !   units_option == bohr      position are given in Bohr
   !   units_option == angstrom  position are given in Angstrom
   !   units_option == alat      position are given in units of alat
   !
   !   label(k) ( character(len=4) )  atomic type
   !   tau(:,k) ( real )              coordinates  of the k-th atom
   !   mbl(:,k) ( integer )           mbl(i,k) > 0 the i-th coord. of the
   !                                  k-th atom is allowed to be moved
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   ! ... routine modified for NEB           ( C.S. 21/10/2003 )
   ! ... routine modified for SMD           ( Y.K. 15/04/2004 )
   !
   SUBROUTINE card_atomic_positions( input_line, prog )
      !
      USE wrappers, ONLY: feval_infix
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      CHARACTER(len=2)   :: prog
      CHARACTER(len=4)   :: lb_pos
      INTEGER            :: ia, k, is, nfield, idx, rep_i
      LOGICAL, EXTERNAL  :: matches
      LOGICAL            :: tend
      LOGICAL, SAVE      :: tread = .false.
      !
      INTEGER            :: ifield, ierr
      REAL(DP)           :: field_value
      CHARACTER(len=256) :: field_str, error_msg
      !
      !
      IF ( tread ) THEN
         CALL errore( 'card_atomic_positions', 'two occurrences', 2 )
      ENDIF
      IF ( .not. taspc ) THEN
         CALL errore( 'card_atomic_positions', &
                     & 'ATOMIC_SPECIES must be present before', 2 )
      ENDIF
      IF ( ntyp > nsx ) THEN
         CALL errore( 'card_atomic_positions', 'nsp out of range', ntyp )
      ENDIF
      IF ( nat < 1 ) THEN
         CALL errore( 'card_atomic_positions', 'nat out of range', nat )
      ENDIF
      !
      if_pos = 1
      !
      sp_pos = 0
      rd_pos = 0.0_DP
      na_inp = 0
      !
      IF ( matches( "CRYSTAL", input_line ) ) THEN
         atomic_positions = 'crystal'
      ELSEIF ( matches( "BOHR", input_line ) ) THEN
         atomic_positions = 'bohr'
      ELSEIF ( matches( "ANGSTROM", input_line ) ) THEN
         atomic_positions = 'angstrom'
      ELSEIF ( matches( "ALAT", input_line ) ) THEN
         atomic_positions = 'alat'
      ELSE
         IF ( trim( adjustl( input_line ) ) /= 'ATOMIC_POSITIONS' ) THEN
            CALL errore( 'read_cards ', &
                        & 'unknown option for ATOMIC_POSITION: '&
                        & // input_line, 1 )
         ENDIF
         IF ( prog == 'FP' ) atomic_positions = 'bohr'
         IF ( prog == 'CP' ) atomic_positions = 'bohr'
         IF ( prog == 'PW' ) atomic_positions = 'alat'
      ENDIF
      !

      IF ( full_phs_path_flag ) THEN
         !
         IF ( allocated( pos ) ) DEALLOCATE( pos )
         ALLOCATE( pos( 3*nat, num_of_images ) )
         pos(:,:) = 0.0_DP
         !
         IF ( calculation == 'smd' .and. prog == 'CP' ) THEN
            !
            CALL errore( 'read_cards', &
                        'smd no longer implemented in CP', 1 )
            !
         ELSE
            !
            CALL read_line( input_line, end_of_file = tend )
            IF ( tend ) &
               CALL errore( 'read_cards', &
                           'end of file reading atomic positions (path)', 1 )
            !
            IF ( matches( "first_image", input_line ) ) THEN
               !
               input_images = 1
               CALL path_read_images( input_images )
               !
            ELSE
               !
               CALL errore( 'read_cards', &
                           'first_image missing in ATOMIC_POSITION', 1 )
               !
            ENDIF
            !
            read_conf_loop: DO
               !
               CALL read_line( input_line, end_of_file = tend )
               !
               IF ( tend ) &
                  CALL errore( 'read_cards', 'end of file reading ' // &
                              & 'atomic positions (path)', input_images + 1 )
               !
               input_images = input_images + 1
               IF ( input_images > num_of_images ) &
                  CALL errore( 'read_cards', &
                              & 'too many images in ATOMIC_POSITION', 1 )
               !
               IF ( matches( "intermediate_image", input_line )  ) THEN
                  !
                  CALL path_read_images( input_images )
                  !
               ELSE
                  !
                  exit read_conf_loop
                  !
               ENDIF
               !
            ENDDO read_conf_loop
            !
            IF ( matches( "last_image", input_line ) ) THEN
               !
               CALL path_read_images( input_images )
               !
            ELSE
               !
               CALL errore( 'read_cards ', &
                           'last_image missing in ATOMIC_POSITION', 1 )
               !
            ENDIF
            !
         ENDIF
         !
      ELSE
         !

         reader_loop : DO ia = 1,nat,1
            !
            CALL read_line( input_line, end_of_file = tend )
            IF ( tend ) &
               CALL errore( 'read_cards', &
                           'end of file reading atomic positions', ia )
            !
            CALL field_count( nfield, input_line )

            !
            IF ( sic /= 'none' .and. nfield /= 8 ) &
               CALL errore( 'read_cards', &
                           'ATOMIC_POSITIONS with sic, 8 columns required', 1 )
            !
            IF ( nfield /= 4 .and. nfield /= 7 .and. nfield /= 8) &
               CALL errore( 'read_cards', 'wrong number of columns ' // &
                           & 'in ATOMIC_POSITIONS', ia )

            ! read atom symbol (column 1) and coordinate
            CALL get_field(1, lb_pos, input_line)
            lb_pos = trim(lb_pos)
            !
            error_msg = 'Error while parsing atomic position card.'
            ! read field 2 (atom X coordinate)
            CALL get_field(2, field_str, input_line)
               rd_pos(1,ia) = feval_infix(ierr, field_str )
               CALL errore('card_atomic_positions', error_msg, ierr)
            ! read field 2 (atom Y coordinate)
            CALL get_field(3, field_str, input_line)
               rd_pos(2,ia) = feval_infix(ierr, field_str )
               CALL errore('card_atomic_positions', error_msg, ierr)
            ! read field 2 (atom Z coordinate)
            CALL get_field(4, field_str, input_line)
               rd_pos(3,ia) = feval_infix(ierr, field_str )
               CALL errore('card_atomic_positions', error_msg, ierr)
               !
            IF ( nfield >= 7 ) THEN
               ! read constrains (fields 5-7, if present)
               CALL get_field(5, field_str, input_line)
               READ(field_str, *) if_pos(1,ia)
               CALL get_field(6, field_str, input_line)
               READ(field_str, *) if_pos(2,ia)
               CALL get_field(7, field_str, input_line)
               READ(field_str, *) if_pos(3,ia)
            ENDIF
               !
            IF ( nfield == 8 ) THEN
               CALL get_field(5, field_str, input_line)
               READ(field_str, *) id_loc(ia)
            ENDIF
            !
            match_label: DO is = 1, ntyp
               !
               IF ( trim(lb_pos) == trim( atom_label(is) ) ) THEN
                  !
                  sp_pos(ia) = is
                  exit match_label
                  !
               ENDIF
               !
            ENDDO match_label
            !


            IF( ( sp_pos(ia) < 1 ) .or. ( sp_pos(ia) > ntyp ) ) THEN
               !
               CALL errore( 'read_cards', 'species '//trim(lb_pos)// &
                           & ' in ATOMIC_POSITIONS is nonexistent', ia )
               !
            ENDIF
            !
            is = sp_pos(ia)
            !
            na_inp(is) = na_inp(is) + 1
            !

         ENDDO reader_loop
         !
      ENDIF
      !
!       DO is = 1, ntyp
!          IF( na_inp( is ) < 1 ) THEN
!             CALL errore( 'read_cards', &
!                'no atom found in ATOMIC_POSITIONS for species '//TRIM(atom_label(is)), is )
!          END IF
!       END DO
      !
      tapos = .true.
      tread = .true.
      !

      RETURN
      !
      CONTAINS
         !
         !-------------------------------------------------------------------
         SUBROUTINE path_read_images( image )
         !-------------------------------------------------------------------
         !
         IMPLICIT NONE
         !
         INTEGER, INTENT(in) :: image
         !
         !
         DO ia = 1, nat
            !
            idx = 3 * ( ia - 1 )
            !
            CALL read_line( input_line, end_of_file = tend )
            !
            IF ( tend ) &
               CALL errore( 'read_cards', &
                              'end of file reading atomic positions', ia )
            !
            CALL field_count( nfield, input_line )
            !
            IF ( nfield == 4 ) THEN
               !
               READ( input_line, * ) lb_pos, pos((idx+1),image), &
                                             pos((idx+2),image), &
                                             pos((idx+3),image)
               !
            ELSEIF ( nfield == 7 ) THEN
               !
               IF ( image /= 1 ) THEN
                  !
                  CALL errore( 'read_cards', &
                              & 'wrong number of columns in ' // &
                              & 'ATOMIC_POSITIONS', sp_pos(ia) )
                  !
               ENDIF
               !
               READ( input_line, * ) lb_pos, pos((idx+1),image), &
                                             pos((idx+2),image), &
                                             pos((idx+3),image), &
                                             if_pos(1,ia), &
                                             if_pos(2,ia), &
                                             if_pos(3,ia)
               !
            ELSE
               !
               CALL errore( 'read_cards', &
                           & 'wrong number of columns in ' // &
                           & 'ATOMIC_POSITIONS', sp_pos(ia) )
               !
            ENDIF
            !
            IF ( image == 1 ) THEN
               !
               lb_pos = adjustl( lb_pos )
               !
               match_label_path: DO is = 1, ntyp
                  !
                  IF ( trim( lb_pos ) == trim( atom_label(is) ) ) THEN
                     !
                     sp_pos(ia) = is
                     !
                     exit match_label_path
                     !
                  ENDIF
                  !
               ENDDO match_label_path
               !
               IF ( ( sp_pos(ia) < 1 ) .or. ( sp_pos(ia) > ntyp ) ) THEN
                  !
                  CALL errore( 'read_cards', &
                                 'wrong index in ATOMIC_POSITIONS', ia )
                  !
               ENDIF
               !
               is = sp_pos(ia)
               !
               na_inp( is ) = na_inp( is ) + 1
               !
            ENDIF
            !
         ENDDO
         !
         RETURN
         !
         END SUBROUTINE path_read_images
         !
   END SUBROUTINE card_atomic_positions
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   ! ATOMIC_FORCES
   !
   !   read external forces (in atomic units) from standard input
   !
   ! Syntax:
   !
   !   ATOMIC_FORCES
   !     label Fx(1) Fy(1) Fz(1)
   !     .....
   !     label Fx(n) Fy(n) Fz(n)
   !
   ! Example:
   !
   !   ???
   !
   ! Where:
   !
   !   label (character(len=4))       atomic label
   !   Fx(:), Fy(:) and Fz(:) (REAL)  x, y and z component of the external force
   !                                  acting on the ions whose coordinate are given
   !                                  in the same line in card ATOMIC_POSITION
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   SUBROUTINE card_atomic_forces( input_line, prog )
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      CHARACTER(len=2)   :: prog
      INTEGER            :: ia, k, nfield
      LOGICAL, SAVE      :: tread = .false.
      CHARACTER(len=4)   :: lb
      !
      !
      IF( tread ) THEN
         CALL errore( ' card_atomic_forces ', ' two occurrences ', 2 )
      ENDIF
      !
      IF( .not. taspc ) THEN
         CALL errore( ' card_atomic_forces ', &
                     & ' ATOMIC_SPECIES must be present before ', 2 )
      ENDIF
      !
      rd_for = 0.0_DP
      !
      DO ia = 1, nat
         !
         CALL read_line( input_line )
         CALL field_count( nfield, input_line )
         IF ( nfield == 4 ) THEN
            READ(input_line,*) lb, ( rd_for(k,ia), k = 1, 3 )
         ELSEIF( nfield == 3 ) THEN
            READ(input_line,*) ( rd_for(k,ia), k = 1, 3 )
         ELSE
            CALL errore( ' iosys ', ' wrong entries in ATOMIC_FORCES ', ia )
         ENDIF
         !
      ENDDO
      !
      tread = .true.
      !
      RETURN
      !
   END SUBROUTINE card_atomic_forces
   !
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   ! K_POINTS
   !
   !   use the specified set of k points
   !
   ! Syntax:
   !
   !   K_POINTS (mesh_option)
   !     n
   !     xk(1,1) xk(2,1) xk(3,1) wk(1)
   !     ...     ...     ...     ...
   !     xk(1,n) xk(2,n) xk(3,n) wk(n)
   !
   ! Example:
   !
   ! K_POINTS
   !   10
   !    0.1250000  0.1250000  0.1250000   1.00
   !    0.1250000  0.1250000  0.3750000   3.00
   !    0.1250000  0.1250000  0.6250000   3.00
   !    0.1250000  0.1250000  0.8750000   3.00
   !    0.1250000  0.3750000  0.3750000   3.00
   !    0.1250000  0.3750000  0.6250000   6.00
   !    0.1250000  0.3750000  0.8750000   6.00
   !    0.1250000  0.6250000  0.6250000   3.00
   !    0.3750000  0.3750000  0.3750000   1.00
   !    0.3750000  0.3750000  0.6250000   3.00
   !
   ! Where:
   !
   !   mesh_option == automatic  k points mesh is generated automatically
   !                             with Monkhorst-Pack algorithm
   !   mesh_option == crystal    k points mesh is given in stdin in scaled
   !                             units
   !   mesh_option == tpiba      k points mesh is given in stdin in units
   !                             of ( 2 PI / alat )
   !   mesh_option == gamma      only gamma point is used ( default in
   !                             CPMD simulation )
   !   mesh_option == tpiba_b    as tpiba but the weights gives the
   !                             number of points between this point
   !                             and the next
   !   mesh_option == crystal_b  as crystal but the weights gives the
   !                             number of points between this point and
   !                             the next
   !
   !   n       ( integer )  number of k points
   !   xk(:,i) ( real )     coordinates of i-th k point
   !   wk(i)   ( real )     weights of i-th k point
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   SUBROUTINE card_kpoints( input_line )
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      INTEGER            :: i, j
      INTEGER            :: nkaux
      INTEGER, ALLOCATABLE :: wkaux(:)
      REAL(DP), ALLOCATABLE :: xkaux(:,:)
      REAL(DP) :: delta
      LOGICAL, EXTERNAL  :: matches
      LOGICAL, SAVE      :: tread = .false.
      LOGICAL            :: tend,terr
      LOGICAL            :: kband = .false.
      !
      !
      IF ( tread ) THEN
         CALL errore( ' card_kpoints ', ' two occurrences', 2 )
      ENDIF
      !
      IF ( matches( "AUTOMATIC", input_line ) ) THEN
         !  automatic generation of k-points
         k_points = 'automatic'
      ELSEIF ( matches( "CRYSTAL", input_line ) ) THEN
         !  input k-points are in crystal (reciprocal lattice) axis
         k_points = 'crystal'
         IF ( matches( "_B", input_line ) ) kband=.true.
      ELSEIF ( matches( "TPIBA", input_line ) ) THEN
         !  input k-points are in 2pi/a units
         k_points = 'tpiba'
         IF ( matches( "_B", input_line ) ) kband=.true.
      ELSEIF ( matches( "GAMMA", input_line ) ) THEN
         !  Only Gamma (k=0) is used
         k_points = 'gamma'
      ELSE
         !  by default, input k-points are in 2pi/a units
         k_points = 'tpiba'
      ENDIF
      !
      IF ( k_points == 'automatic' ) THEN
         !
         ! ... automatic generation of k-points
         !
         nkstot = 0
         CALL read_line( input_line, end_of_file = tend, error = terr )
         IF (tend) GOTO 10
         IF (terr) GOTO 20
         READ(input_line, *, END=10, ERR=20) nk1, nk2, nk3, k1, k2 ,k3
         IF ( k1 < 0 .or. k1 > 1 .or. &
               k2 < 0 .or. k2 > 1 .or. &
               k3 < 0 .or. k3 > 1 ) CALL errore &
                  ('card_kpoints', 'invalid offsets: must be 0 or 1', 1)
         IF ( nk1 <= 0 .or. nk2 <= 0 .or. nk3 <= 0 ) CALL errore &
                  ('card_kpoints', 'invalid values for nk1, nk2, nk3', 1)

         !
      ELSEIF ( ( k_points == 'tpiba' ) .or. ( k_points == 'crystal' ) ) THEN
         !
         ! ... input k-points are in 2pi/a units
         !
         CALL read_line( input_line, end_of_file = tend, error = terr )
         IF (tend) GOTO 10
         IF (terr) GOTO 20
         READ(input_line, *, END=10, ERR=20) nkstot
         IF ( nkstot > size (xk,2)  ) CALL errore &
                  ('card_kpoints', 'too many k-points',nkstot)
         !
         DO i = 1, nkstot
            CALL read_line( input_line, end_of_file = tend, error = terr )
            IF (tend) GOTO 10
            IF (tend) GOTO 20
            READ(input_line,*, END=10, ERR=20) xk(1,i), xk(2,i), xk(3,i), wk(i)
         ENDDO
         IF (kband) THEN
            nkaux=nkstot
            ALLOCATE(xkaux(3,nkstot))
            ALLOCATE(wkaux(nkstot))
            xkaux(:,1:nkstot)=xk(:,1:nkstot)
            wkaux(1:nkstot)=nint(wk(1:nkstot))
            nkstot=0
            DO i=1,nkaux-1
               delta=1.0_DP/wkaux(i)
               DO j=0,wkaux(i)-1
                  nkstot=nkstot+1
                  IF ( nkstot > size (xk,2)  ) CALL errore &
                        ('card_kpoints', 'too many k-points',nkstot)
                  xk(:,nkstot)=xkaux(:,i)+delta*j*(xkaux(:,i+1)-xkaux(:,i))
                  wk(nkstot)=1.0_DP
               ENDDO
            ENDDO
            nkstot=nkstot+1
            xk(:,nkstot)=xkaux(:,nkaux)
            wk(nkstot)=1.0_DP
            DEALLOCATE(xkaux)
            DEALLOCATE(wkaux)
         ENDIF
         !
      ELSEIF ( k_points == 'gamma' ) THEN
         !
         nkstot = 1
         xk(:,1) = 0.0_DP
         wk(1) = 1.0_DP
         !
      ENDIF
      !
      tread  = .true.
      tk_inp = .true.
      !
      RETURN
10     CALL errore ('card_kpoints', ' end of file while reading ' &
            & // trim(k_points) // ' k points', 1)
20     CALL errore ('card_kpoints', ' error while reading ' &
            & // trim(k_points) // ' k points', 1)
      !
   END SUBROUTINE card_kpoints
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   ! SETNFI
   !
   !   Reset the step counter to the specified value
   !
   ! Syntax:
   !
   !  SETNFI
   !     nfi
   !
   ! Example:
   !
   !  SETNFI
   !     100
   !
   ! Where:
   !
   !    nfi (integer) new value for the step counter
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   SUBROUTINE card_setnfi( input_line )
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      LOGICAL, SAVE      :: tread = .false.
      !
      !
      IF ( tread ) THEN
         CALL errore( ' card_setnfi ', ' two occurrences', 2 )
      ENDIF
      CALL read_line( input_line )
      READ(input_line,*) newnfi_card
      tnewnfi_card = .true.
      tread = .true.
      !
      RETURN
      !
   END SUBROUTINE card_setnfi
   !
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   ! 2DPROCMESH
   !
   !   Distribute the Y and Z FFT dimensions across processors,
   !   instead of Z dimension only ( default distribution )
   !
   ! Syntax:
   !
   !    2DPROCMESH
   !
   ! Where:
   !
   !    no parameters
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   ! OCCUPATIONS
   !
   !   use the specified occupation numbers for electronic states.
   !   Note that you should specify 10 values per line maximum!
   !
   ! Syntax (nspin == 1):
   !
   !   OCCUPATIONS
   !      f(1)  ....   ....  f(10)
   !      f(11) .... f(nbnd)
   !
   ! Syntax (nspin == 2):
   !
   !   OCCUPATIONS
   !      u(1)  ....   ....  u(10)
   !      u(11) .... u(nbnd)
   !      d(1)  ....   ....  d(10)
   !      d(11) .... d(nbnd)
   !
   ! Example:
   !
   ! OCCUPATIONS
   !  2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0
   !  2.0 2.0 2.0 2.0 2.0 1.0 1.0
   !
   ! Where:
   !
   !      f(:) (real)  these are the occupation numbers
   !                   for LDA electronic states.
   !
   !      u(:) (real)  these are the occupation numbers
   !                   for LSD spin == 1 electronic states
   !      d(:) (real)  these are the occupation numbers
   !                   for LSD spin == 2 electronic states
   !
   !      Note, maximum 10 values per line!
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   SUBROUTINE card_occupations( input_line )
      !
      USE wrappers, ONLY: feval_infix
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line, field_str
      INTEGER            :: is, nx10, i, j, nspin0
      INTEGER            :: nfield, nbnd_read, nf, ierr
      LOGICAL, SAVE      :: tread = .false.
      LOGICAL :: tef
      !
      !
      IF ( tread ) THEN
         CALL errore( ' card_occupations ', ' two occurrences', 2 )
      ENDIF
      nspin0=nspin
      IF (nspin == 4) nspin0=1
      !
      ALLOCATE ( f_inp ( nbnd, nspin0 ) )
      DO is = 1, nspin0
         !
         nbnd_read = 0
         DO WHILE ( nbnd_read < nbnd)
            CALL read_line( input_line, end_of_file=tef )
            IF (tef) CALL errore('card_occupations',&
                        'Missing occupations, end of file reached',1)
            CALL field_count( nfield, input_line )
            !
            DO nf = 1,nfield
               nbnd_read = nbnd_read+1
               CALL get_field(nf, field_str, input_line)
               !
               f_inp(nbnd_read,is) = feval_infix(ierr, field_str )
               CALL errore('card_occupations',&
                           'Error parsing occupation: '//trim(field_str), nbnd_read*ierr)
            ENDDO
         ENDDO
         !
      ENDDO
      !
      tf_inp = .true.
      tread = .true.
      !
      RETURN
      !
   END SUBROUTINE card_occupations
   !
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   ! VHMEAN
   !
   !   Calculation of potential average along a given axis
   !
   ! Syntax:
   !
   !   VHMEAN
   !   unit nr rmin rmax asse
   !
   ! Example:
   !
   !   ????
   !
   ! Where:
   !
   !   ????
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   SUBROUTINE card_vhmean( input_line )
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      LOGICAL, SAVE :: tread = .false.
      !
      !
      IF ( tread ) THEN
         CALL errore( ' card_vhmean ', ' two occurrences', 2 )
      ENDIF
      !
      tvhmean_inp = .true.
      CALL read_line( input_line )
      READ(input_line,*) &
         vhiunit_inp, vhnr_inp, vhrmin_inp, vhrmax_inp, vhasse_inp
      tread = .true.
      !
      RETURN
      !
   END SUBROUTINE card_vhmean
   !
   !
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   ! DIPOLE
   !
   !   calculate polarizability
   !
   ! Syntax:
   !
   !   DIPOLE
   !
   ! Where:
   !
   !    no parameters
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   SUBROUTINE card_dipole( input_line )
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      LOGICAL, SAVE      :: tread = .false.
      !
      !
      IF ( tread ) THEN
         CALL errore( ' card_dipole ', ' two occurrences', 2 )
      ENDIF
      !
      tdipole_card = .true.
      tread = .true.
      !
      RETURN
      !
   END SUBROUTINE card_dipole
   !
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   ! IESR
   !
   !   use the specified number of neighbour cells for Ewald summations
   !
   ! Syntax:
   !
   !   ESR
   !    iesr
   !
   ! Example:
   !
   !   ESR
   !    3
   !
   ! Where:
   !
   !      iesr (integer)  determines the number of neighbour cells to be
   !                      considered:
   !                        iesr = 1 : nearest-neighbour cells (default)
   !                        iesr = 2 : next-to-nearest-neighbour cells
   !                        and so on
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   SUBROUTINE card_esr( input_line )
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      LOGICAL, SAVE      :: tread = .false.
      !
      IF ( tread ) THEN
         CALL errore( ' card_esr ', ' two occurrences', 2 )
      ENDIF
      CALL read_line( input_line )
      READ(input_line,*) iesr_inp
      !
      tread = .true.
      !
      RETURN
      !
   END SUBROUTINE card_esr
   !
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   ! CELL_PARAMETERS
   !
   !   use the specified cell dimensions
   !
   ! Syntax:
   !
   !    CELL_PARAMETERS
   !      HT(1,1) HT(1,2) HT(1,3)
   !      HT(2,1) HT(2,2) HT(2,3)
   !      HT(3,1) HT(3,2) HT(3,3)
   !
   ! Example:
   !
   ! CELL_PARAMETERS
   !    24.50644311    0.00004215   -0.14717844
   !    -0.00211522    8.12850030    1.70624903
   !     0.16447787    0.74511792   23.07395418
   !
   ! Where:
   !
   !      HT(i,j) (real)  cell dimensions ( in a.u. ),
   !                      note the relation with lattice vectors:
   !                      HT(1,:) = A1, HT(2,:) = A2, HT(3,:) = A3
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   SUBROUTINE card_cell_parameters( input_line )
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      INTEGER            :: i, j
      LOGICAL, EXTERNAL  :: matches
      LOGICAL, SAVE      :: tread = .false.
      !
      !
      IF ( tread ) THEN
         CALL errore( ' card_cell_parameters ', ' two occurrences', 2 )
      ENDIF
      !
      IF ( matches( 'HEXAGONAL', input_line ) ) THEN
         cell_symmetry = 'hexagonal'
      ELSE
         cell_symmetry = 'cubic'
      ENDIF
      !
      IF ( matches( "BOHR", input_line ) ) THEN
         cell_units = 'bohr'
      ELSEIF ( matches( "ANGSTROM", input_line ) ) THEN
         cell_units = 'angstrom'
      ELSE
         cell_units = 'alat'
      ENDIF
      !
      DO i = 1, 3
         CALL read_line( input_line )
         READ(input_line,*) ( rd_ht( i, j ), j = 1, 3 )
      ENDDO
      !
      trd_ht = .true.
      tread  = .true.
      !
      RETURN
      !
   END SUBROUTINE card_cell_parameters
   !
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   ! ATOMIC_VELOCITIES
   !
   !   read velocities (in atomic units) from standard input
   !
   ! Syntax:
   !
   !   ATOMIC_VELOCITIES
   !     label(1)  Vx(1) Vy(1) Vz(1)
   !     ....
   !     label(n)  Vx(n) Vy(n) Vz(n)
   !
   ! Example:
   !
   !   ???
   !
   ! Where:
   !
   !   label (character(len=4))       atomic label
   !   Vx(:), Vy(:) and Vz(:) (REAL)  x, y and z velocity components of
   !                                  the ions
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   SUBROUTINE card_ion_velocities( input_line )
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      INTEGER            :: ia, k, is, nfield
      LOGICAL, SAVE      :: tread = .false.
      CHARACTER(len=4)   :: lb_vel
      !
      !
      IF( tread ) THEN
         CALL errore( ' card_ion_velocities ', ' two occurrences', 2 )
      ENDIF
      !
      IF( .not. taspc ) THEN
         CALL errore( ' card_ion_velocities ', &
                     & ' ATOMIC_SPECIES must be present before ', 2 )
      ENDIF
      !
      rd_vel = 0.0_DP
      sp_vel = 0
      !
      IF ( ion_velocities == 'from_input' ) THEN
         !
         tavel = .true.
         !
         DO ia = 1, nat
            !
            CALL read_line( input_line )
            CALL field_count( nfield, input_line )
            IF ( nfield == 4 ) THEN
               READ(input_line,*) lb_vel, ( rd_vel(k,ia), k = 1, 3 )
            ELSE
               CALL errore( ' iosys ', &
                           & ' wrong entries in ION_VELOCITIES ', ia )
            ENDIF
            !
            match_label: DO is = 1, ntyp
               IF ( trim( lb_vel ) == atom_label(is) ) THEN
                  sp_vel(ia) = is
                  exit match_label
               ENDIF
            ENDDO match_label
            !
            IF ( sp_vel(ia) < 1 .or. sp_vel(ia) > ntyp ) THEN
               CALL errore( ' iosys ', ' wrong LABEL in ION_VELOCITIES ', ia )
            ENDIF
            !
         ENDDO
         !
      ENDIF
      !
      tread = .true.
      !
      RETURN
      !
   END SUBROUTINE
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   ! CONSTRAINTS
   !
   !   Ionic Constraints
   !
   ! Syntax:
   !
   !    CONSTRAINTS
   !      NCONSTR CONSTR_TOL
   !      CONSTR_TYPE(.) CONSTR(1,.) CONSTR(2,.) ... { CONSTR_TARGET(.) }
   !
   ! Where:
   !
   !      NCONSTR(INTEGER)    number of constraints
   !
   !      CONSTR_TOL          tolerance for keeping the constraints
   !                          satisfied
   !
   !      CONSTR_TYPE(.)      type of constrain:
   !                          1: for fixed distances ( two atom indexes must
   !                             be specified )
   !                          2: for fixed planar angles ( three atom indexes
   !                             must be specified )
   !
   !      CONSTR(1,.) CONSTR(2,.) ...
   !
   !                          indices object of the constraint, as
   !                          they appear in the 'POSITION' CARD
   !
   !      CONSTR_TARGET       target for the constrain ( in the case of
   !                          planar angles it is the COS of the angle ).
   !                          this variable is optional.
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   SUBROUTINE card_constraints( input_line )
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      INTEGER            :: i, nfield
      LOGICAL, SAVE      :: tread = .false.
      !
      !
      IF ( tread ) CALL errore( 'card_constraints', 'two occurrences', 2 )
      !
      CALL read_line( input_line )
      !
      CALL field_count( nfield, input_line )
      !
      IF ( nfield == 1 ) THEN
         !
         READ( input_line, * ) nconstr_inp
         !
      ELSEIF ( nfield == 2 ) THEN
         !
         READ( input_line, * ) nconstr_inp, constr_tol_inp
         !
      ELSE
         !
         CALL errore( 'card_constraints', 'too many fields', nfield )
         !
      ENDIF
      WRITE(stdout,'(5x,a,i4,a,f12.6)') &
         'Reading',nconstr_inp,' constraints; tolerance:', constr_tol_inp
      !
      CALL allocate_input_constr()
      !
      DO i = 1, nconstr_inp
         !
         CALL read_line( input_line )
         !
         READ( input_line, * ) constr_type_inp(i)
         !
         CALL field_count( nfield, input_line )
         !
         IF ( nfield > nc_fields + 2 ) &
            CALL errore( 'card_constraints', &
                        'too many fields for this constraint', i )
         !
         SELECT CASE( constr_type_inp(i) )
         CASE( 'type_coord', 'atom_coord' )
            !
            IF ( nfield == 5 ) THEN
               !
               READ( input_line, * ) constr_type_inp(i), &
                                    constr_inp(1,i), &
                                    constr_inp(2,i), &
                                    constr_inp(3,i), &
                                    constr_inp(4,i)
               !
               WRITE(stdout,'(7x,i3,a,i3,a,i2,a,2f12.6)') &
                  i,') '//constr_type_inp(i)(1:4),int(constr_inp(1,i)) ,' coordination wrt type:', int(constr_inp(2,i)), &
                  ' cutoff distance and smoothing:',  constr_inp(3:4,i)
            ELSEIF ( nfield == 6 ) THEN
               !
               READ( input_line, * ) constr_type_inp(i), &
                                    constr_inp(1,i), &
                                    constr_inp(2,i), &
                                    constr_inp(3,i), &
                                    constr_inp(4,i), &
                                    constr_target_inp(i)
               !
               constr_target_set(i) = .true.
               !
               WRITE(stdout,'(7x,i3,a,i3,a,i2,a,2f12.6,a,f12.6)') &
                  i,') '//constr_type_inp(i)(1:4),int(constr_inp(1,i)) ,' coordination wrt type:', int(constr_inp(2,i)), &
                  ' cutoff distance and smoothing:',  constr_inp(3:4,i), &
                  '; target:', constr_target_inp(i)
            ELSE
               !
               CALL errore( 'card_constraints', 'type_coord, ' // &
                           & 'atom_coord: wrong number of fields', nfield )
               !
            ENDIF
            !
         CASE( 'distance' )
            !
            IF ( nfield == 3 ) THEN
               !
               READ( input_line, * ) constr_type_inp(i), &
                                    constr_inp(1,i), &
                                    constr_inp(2,i)
               !
               WRITE(stdout,'(7x,i3,a,2i3)') &
                  i,') distance between atoms: ', int(constr_inp(1:2,i))
            ELSEIF ( nfield == 4 ) THEN
               !
               READ( input_line, * ) constr_type_inp(i), &
                                    constr_inp(1,i), &
                                    constr_inp(2,i), &
                                    constr_target_inp(i)
               !
               constr_target_set(i) = .true.
               !
               WRITE(stdout,'(7x,i3,a,2i3,a,f12.6)') &
                  i,') distance between atoms: ', int(constr_inp(1:2,i)), '; target:',  constr_target_inp(i)
            ELSE
               !
               CALL errore( 'card_constraints', &
                           & 'distance: wrong number of fields', nfield )
               !
            ENDIF
            !
         CASE( 'planar_angle' )
            !
            IF ( nfield == 4 ) THEN
               !
               READ( input_line, * ) constr_type_inp(i), &
                                    constr_inp(1,i), &
                                    constr_inp(2,i), &
                                    constr_inp(3,i)
               !
               WRITE(stdout, '(7x,i3,a,3i3)') &
                  i,') planar angle between atoms: ', int(constr_inp(1:3,i))
            ELSEIF ( nfield == 5 ) THEN
               !
               READ( input_line, * ) constr_type_inp(i), &
                                    constr_inp(1,i), &
                                    constr_inp(2,i), &
                                    constr_inp(3,i), &
                                    constr_target_inp(i)
               !
               constr_target_set(i) = .true.
               !
               WRITE(stdout, '(7x,i3,a,3i3,a,f12.6)') &
                  i,') planar angle between atoms: ', int(constr_inp(1:3,i)), '; target:', constr_target_inp(i)
            ELSE
               !
               CALL errore( 'card_constraints', &
                           & 'planar_angle: wrong number of fields', nfield )
               !
            ENDIF
            !
         CASE( 'torsional_angle' )
            !
            IF ( nfield == 5 ) THEN
               !
               READ( input_line, * ) constr_type_inp(i), &
                                    constr_inp(1,i), &
                                    constr_inp(2,i), &
                                    constr_inp(3,i), &
                                    constr_inp(4,i)
               !
               WRITE(stdout, '(7x,i3,a,4i3)') &
                  i,') torsional angle between atoms: ', int(constr_inp(1:4,i))
            ELSEIF ( nfield == 6 ) THEN
               !
               READ( input_line, * ) constr_type_inp(i), &
                                    constr_inp(1,i), &
                                    constr_inp(2,i), &
                                    constr_inp(3,i), &
                                    constr_inp(4,i), &
                                    constr_target_inp(i)
               !
               constr_target_set(i) = .true.
               !
               WRITE(stdout, '(7x,i3,a,4i3,a,f12.6)') &
                  i,') torsional angle between atoms: ', int(constr_inp(1:4,i)), '; target:', constr_target_inp(i)
            ELSE
               !
               CALL errore( 'card_constraints', &
                           & 'torsional_angle: wrong number of fields', nfield )
               !
            ENDIF
            !
         CASE( 'bennett_proj' )
            !
            IF ( nfield == 5 ) THEN
               !
               READ( input_line, * ) constr_type_inp(i), &
                                    constr_inp(1,i), &
                                    constr_inp(2,i), &
                                    constr_inp(3,i), &
                                    constr_inp(4,i)
               !
               WRITE(stdout, '(7x,i3,a,i3,a,3f12.6)') &
                  i,') bennet projection of atom ', int(constr_inp(1,i)), ' along vector:', constr_inp(2:4,i)
            ELSEIF ( nfield == 6 ) THEN
               !
               READ( input_line, * ) constr_type_inp(i), &
                                    constr_inp(1,i), &
                                    constr_inp(2,i), &
                                    constr_inp(3,i), &
                                    constr_inp(4,i), &
                                    constr_target_inp(i)
               !
               constr_target_set(i) = .true.
               !
               WRITE(stdout, '(7x,i3,a,i3,a,3f12.6,a,f12.6)') &
                  i,') bennet projection of atom ', int(constr_inp(1,i)), ' along vector:', constr_inp(2:4,i), &
                  '; target:', constr_target_inp(i)
            ELSE
               !
               CALL errore( 'card_constraints', &
                           & 'bennett_proj: wrong number of fields', nfield )
               !
            ENDIF
            !
         CASE DEFAULT
            !
            CALL errore( 'card_constraints', 'unknown constraint ' // &
                        & 'type: ' // trim( constr_type_inp(i) ), 1 )
            !
         END SELECT
         !
      ENDDO
      !
      tread = .true.
      !
      RETURN
      !
   END SUBROUTINE card_constraints
   !
   SUBROUTINE card_collective_vars( input_line )
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      INTEGER            :: i, nfield
      LOGICAL            :: ltest
      LOGICAL, SAVE      :: tread = .false.
      !
      !
      IF ( tread ) CALL errore( 'card_collective_vars', 'two occurrences', 2 )
      !
      CALL read_line( input_line )
      !
      CALL field_count( nfield, input_line )
      !
      IF ( nfield == 1 ) THEN
         !
         READ( input_line, * ) ncolvar_inp
         !
      ELSEIF ( nfield == 2 ) THEN
         !
         READ( input_line, * ) ncolvar_inp, colvar_tol_inp
         !
      ELSE
         !
         CALL errore( 'card_collective_vars', 'too many fields', nfield )
         !
      ENDIF
      !
      CALL allocate_input_colvar()
      !
      IF ( cg_phs_path_flag ) THEN
         !
         input_images = 2
         !
         IF( allocated( pos ) ) DEALLOCATE( pos )
         !
         ALLOCATE( pos( ncolvar_inp, input_images ) )
         !
         pos(:,:) = 0.0_DP
         !
      ENDIF
      !
      DO i = 1, ncolvar_inp
         !
         CALL read_line( input_line )
         !
         READ( input_line, * ) colvar_type_inp(i)
         !
         CALL field_count( nfield, input_line )
         !
         ltest = ( ( nfield <= nc_fields + 2 ) .or. &
                  ( cg_phs_path_flag .and. ( nfield <= nc_fields + 4 ) ) )
         !
         IF ( .not. ltest ) &
            CALL errore( 'card_collective_vars', 'too many fields for ' // &
                        & 'this constraint: ' // trim( constr_type_inp(i) ), i )
         !
         SELECT CASE( colvar_type_inp(i) )
         CASE( 'type_coord', 'atom_coord' )
            !
            IF ( cg_phs_path_flag ) THEN
               !
               READ( input_line, * ) colvar_type_inp(i), &
                                    colvar_inp(1,i),    &
                                    colvar_inp(2,i),    &
                                    colvar_inp(3,i),    &
                                    colvar_inp(4,i),    &
                                    pos(i,1),           &
                                    pos(i,2)
               !
            ELSEIF ( nfield == 5 ) THEN
               !
               READ( input_line, * ) colvar_type_inp(i), &
                                    colvar_inp(1,i), &
                                    colvar_inp(2,i), &
                                    colvar_inp(3,i), &
                                    colvar_inp(4,i)
               !
            ELSE
               !
               CALL errore( 'card_collective_vars', 'type_coord, ' // &
                           & 'atom_coord: wrong number of fields', nfield )
               !
            ENDIF
            !
         CASE( 'distance' )
            !
            IF ( cg_phs_path_flag ) THEN
               !
               READ( input_line, * ) colvar_type_inp(i), &
                                    colvar_inp(1,i),    &
                                    colvar_inp(2,i),    &
                                    pos(i,1),           &
                                    pos(i,2)
               !
            ELSEIF ( nfield == 3 ) THEN
               !
               READ( input_line, * ) colvar_type_inp(i), &
                                    colvar_inp(1,i), &
                                    colvar_inp(2,i)
               !
            ELSE
               !
               CALL errore( 'card_collective_vars', &
                           & 'distance: wrong number of fields', nfield )
               !
            ENDIF
            !
         CASE( 'planar_angle' )
            !
            IF ( cg_phs_path_flag ) THEN
               !
               READ( input_line, * ) colvar_type_inp(i), &
                                    colvar_inp(1,i),    &
                                    colvar_inp(2,i),    &
                                    colvar_inp(3,i),    &
                                    pos(i,1),           &
                                    pos(i,2)
               !
            ELSEIF ( nfield == 4 ) THEN
               !
               READ( input_line, * ) colvar_type_inp(i), &
                                    colvar_inp(1,i), &
                                    colvar_inp(2,i), &
                                    colvar_inp(3,i)
               !
            ELSE
               !
               CALL errore( 'card_collective_vars', &
                           & 'planar_angle: wrong number of fields', nfield )
               !
            ENDIF
            !
         CASE( 'torsional_angle' )
            !
            IF ( cg_phs_path_flag ) THEN
               !
               READ( input_line, * ) colvar_type_inp(i), &
                                    colvar_inp(1,i),    &
                                    colvar_inp(2,i),    &
                                    colvar_inp(3,i),    &
                                    colvar_inp(4,i),    &
                                    pos(i,1),           &
                                    pos(i,2)
               !
            ELSEIF ( nfield == 5 ) THEN
               !
               READ( input_line, * ) colvar_type_inp(i), &
                                    colvar_inp(1,i), &
                                    colvar_inp(2,i), &
                                    colvar_inp(3,i), &
                                    colvar_inp(4,i)
               !
            ELSE
               !
               CALL errore( 'card_collective_vars', &
                           & 'torsional_angle: wrong number of fields', nfield )
               !
            ENDIF
            !
         CASE( 'struct_fac' )
            !
            IF ( cg_phs_path_flag ) THEN
               !
               READ( input_line, * ) colvar_type_inp(i), &
                                    colvar_inp(1,i), &
                                    colvar_inp(2,i), &
                                    colvar_inp(3,i), &
                                    pos(i,1),        &
                                    pos(i,2)
               !
            ELSEIF ( nfield == 4 ) THEN
               !
               READ( input_line, * ) colvar_type_inp(i), &
                                    colvar_inp(1,i), &
                                    colvar_inp(2,i), &
                                    colvar_inp(3,i)
               !
            ELSE
               !
               CALL errore( 'card_collective_vars', &
                           & 'struct_fac: wrong number of fields', nfield )
               !
            ENDIF
            !
         CASE( 'sph_struct_fac' )
            !
            IF ( cg_phs_path_flag ) THEN
               !
               READ( input_line, * ) colvar_type_inp(i), &
                                    colvar_inp(1,i), &
                                    pos(i,1),        &
                                    pos(i,2)
               !
            ELSEIF ( nfield == 2 ) THEN
               !
               READ( input_line, * ) colvar_type_inp(i), &
                                    colvar_inp(1,i)
               !
            ELSE
               !
               CALL errore( 'card_collective_vars',  &
                           & 'sph_struct_fac: wrong number of fields', nfield )
               !
            ENDIF
            !
         CASE( 'bennett_proj' )
            !
            IF ( cg_phs_path_flag ) THEN
               !
               READ( input_line, * ) constr_type_inp(i), &
                                    constr_inp(1,i), &
                                    constr_inp(2,i), &
                                    constr_inp(3,i), &
                                    constr_inp(4,i), &
                                    pos(i,1),        &
                                    pos(i,2)
               !
            ELSEIF ( nfield == 5 ) THEN
               !
               READ( input_line, * ) constr_type_inp(i), &
                                    constr_inp(1,i), &
                                    constr_inp(2,i), &
                                    constr_inp(3,i), &
                                    constr_inp(4,i)
               !
            ELSE
               !
               CALL errore( 'card_collective_vars', &
                           & 'bennett_proj: wrong number of fields', nfield )
               !
            ENDIF
            !
         CASE DEFAULT
            !
            CALL errore( 'card_collective_vars', 'unknown collective ' // &
                        & 'variable: ' // trim( colvar_type_inp(i) ), 1 )
            !
         END SELECT
         !
      ENDDO
      !
      tread = .true.
      !
      RETURN
      !
   END SUBROUTINE card_collective_vars
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   ! KSOUT
   !
   !   Enable the printing of Kohn Sham states
   !
   ! Syntax ( nspin == 2 ):
   !
   !   KSOUT
   !     nu
   !     iu(1) iu(2) iu(3) .. iu(nu)
   !     nd
   !     id(1) id(2) id(3) .. id(nd)
   !
   ! Syntax ( nspin == 1 ):
   !
   !   KSOUT
   !     ns
   !     is(1) is(2) is(3) .. is(ns)
   !
   ! Example:
   !
   !   ???
   !
   ! Where:
   !
   !   nu (integer)     number of spin=1 states to be printed
   !   iu(:) (integer)  indexes of spin=1 states, the state iu(k)
   !                    is saved to file KS_UP.iu(k)
   !
   !   nd (integer)     number of spin=2 states to be printed
   !   id(:) (integer)  indexes of spin=2 states, the state id(k)
   !                    is saved to file KS_DW.id(k)
   !
   !   ns (integer)     number of LDA states to be printed
   !   is(:) (integer)  indexes of LDA states, the state is(k)
   !                    is saved to file KS.is(k)
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   SUBROUTINE card_ksout( input_line )
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      LOGICAL, SAVE      :: tread = .false.
      INTEGER            :: i, s, nksx
      TYPE occupancy_type
         INTEGER, POINTER :: occs(:)
      END TYPE occupancy_type
      TYPE(occupancy_type), ALLOCATABLE :: is(:)
      !
      IF ( tread ) THEN
         CALL errore( ' card_ksout ', ' two occurrences', 2 )
      ENDIF
      !
      nprnks = 0
      nksx   = 0
      !
      ALLOCATE ( is (nspin) )
      !
      DO s = 1, nspin
         !
         CALL read_line( input_line )
         READ(input_line, *) nprnks( s )
         !
         IF ( nprnks( s ) < 1 ) THEN
            CALL errore( ' card_ksout ', ' wrong number of states ', 2 )
         ENDIF
         !
         ALLOCATE( is(s)%occs( 1:nprnks(s) ) )
         !
         CALL read_line( input_line )
         READ(input_line, *) ( is(s)%occs(i), i = 1, nprnks( s ) )
         !
         nksx = max( nksx, nprnks( s ) )
         !
      ENDDO
      !
      CALL allocate_input_iprnks( nksx, nspin )
      !
      DO s = 1, nspin
         !
         DO i = 1, nprnks( s )
            !
            iprnks( i, s ) = is(s)%occs(i)
            !
         ENDDO
         !
         DEALLOCATE( is(s)%occs )
         !
      ENDDO
      !
      DEALLOCATE( is )
      !
      tread = .true.
      !
      RETURN
      !
   END SUBROUTINE
   !
   !
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   ! CLIMBING_IMAGES
   !
   !   Needed to explicitly specify which images have to climb
   !
   ! Syntax:
   !
   !   CLIMBING_IMAGES
   !     index1, ..., indexN
   !
   ! Where:
   !
   !   index1, ..., indexN are indices of the images that have to climb
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   SUBROUTINE card_climbing_images( input_line )
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      LOGICAL, SAVE      :: tread = .false.
      LOGICAL, EXTERNAL  :: matches
      !
      INTEGER          :: i
      CHARACTER(len=5) :: i_char
      !
      CHARACTER(len=6), EXTERNAL :: int_to_char
      !
      !
      IF ( tread ) &
         CALL errore( ' card_climbing_images ', ' two occurrences', 2 )
      !
      IF ( CI_scheme == 'manual' ) THEN
         !
         IF ( allocated( climbing ) ) DEALLOCATE( climbing )
         !
         ALLOCATE( climbing( num_of_images ) )
         !
         climbing(:) = .false.
         !
         CALL read_line( input_line )
         !
         DO i = 1, num_of_images
            !
            i_char = int_to_char( i )
            !
            IF ( matches( ' ' // trim( i_char ) // ',' , &
                           ' ' // trim( input_line ) // ',' ) ) &
               climbing(i) = .true.
            !
         ENDDO
         !
      ENDIF
      !
      tread = .true.
      !
      RETURN
      !
   END SUBROUTINE card_climbing_images
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   ! PLOT WANNIER
   !
   !   Needed to specify the indices of the wannier functions that
   !   have to be plotted
   !
   ! Syntax:
   !
   !   PLOT_WANNIER
   !     index1, ..., indexN
   !
   ! Where:
   !
   !   index1, ..., indexN are indices of the wannier functions
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   SUBROUTINE card_plot_wannier( input_line )
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      LOGICAL, SAVE      :: tread = .false.
      LOGICAL, EXTERNAL  :: matches
      !
      INTEGER                    :: i, ib
      CHARACTER(len=5)           :: i_char
      CHARACTER(len=6), EXTERNAL :: int_to_char
      !
      !
      IF ( tread ) &
         CALL errore( 'card_plot_wannier', 'two occurrences', 2 )
      !
      IF ( nwf > 0 ) THEN
         !
         IF ( nwf > nwf_max ) &
            CALL errore( 'card_plot_wannier', 'too many wannier functions', 1 )
         !
         CALL read_line( input_line )
         !
         ib = 0
         !
         DO i = 1, nwf_max
            !
            i_char = int_to_char( i )
            !
            IF ( matches( ' ' // trim( i_char ) // ',', &
                           ' ' // trim( input_line ) // ',' ) ) THEN
               !
               ib = ib + 1
               !
               IF ( ib > nwf ) &
                  CALL errore( 'card_plot_wannier', 'too many indices', 1 )
               !
               wannier_index(ib) = i
               !
            ENDIF
            !
         ENDDO
         !
      ENDIF
      !
      tread = .true.
      !
      RETURN
      !
   END SUBROUTINE card_plot_wannier
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !
   !
   ! TEMPLATE
   !
   !      This is a template card info section
   !
   ! Syntax:
   !
   !    TEMPLATE
   !     RVALUE IVALUE
   !
   ! Example:
   !
   !    ???
   !
   ! Where:
   !
   !      RVALUE (real)     This is a real value
   !      IVALUE (integer)  This is an integer value
   !
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   SUBROUTINE card_template( input_line )
      !
      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      LOGICAL, SAVE      :: tread = .false.
      !
      !
      IF ( tread ) THEN
         CALL errore( ' card_template ', ' two occurrences', 2 )
      ENDIF
      !
      ! ....  CODE HERE
      !
      tread = .true.
      !
      RETURN
      !
   END SUBROUTINE
   !
   !
   !------------------------------------------------------------------------
   !    BEGIN manual
   !----------------------------------------------------------------------
   !WANNIER_AC
   !Wannier# 1 10.5 15.7 2
   !atom 1
   !d 1 0.45
   !p 3 0.55
   !Wannier# 2 10.5 15.7 1
   !atom 3
   !p 1 0.8
   !Spin#2:
   !Wannier# 1 10.5 15.7 2
   !atom 1
   !d 1 0.45
   !p 3 0.55
   !Wannier# 2 10.5 15.7 1
   !atom 3
   !p 1 0.8
   !----------------------------------------------------------------------
   !    END manual
   !------------------------------------------------------------------------
   !
   SUBROUTINE card_wannier_ac( input_line )
      !
      USE wannier_new, ONLY: nwan

      IMPLICIT NONE
      !
      CHARACTER(len=256) :: input_line
      INTEGER :: i,j,k, nfield, iwan, ning, iatom,il,im,ispin
      LOGICAL :: tend
      REAL :: c, b_from, b_to
      CHARACTER(len=10) :: text, lo

      ispin = 1
      !
      DO i = 1, nwan
         !
         CALL read_line( input_line, end_of_file = tend )
         !
         IF ( tend ) &
            CALL errore( 'read_cards', &
                        'end of file reading trial wfc composition', i )
         !
         CALL field_count( nfield, input_line )
         !
         IF ( nfield == 4 ) THEN
            READ(input_line,*) text, iwan, b_from, b_to
            ning = 1
         ELSEIF ( nfield == 5 ) THEN
            READ(input_line,*) text, iwan, b_from, b_to, ning
         ELSE
            CALL errore( 'read_cards', &
                        'wrong format', nfield )
         ENDIF
         IF(iwan/=i) CALL errore( 'read_cards', 'wrong wannier order', iwan)

         ! Read atom number
         CALL read_line( input_line, end_of_file = tend )
         READ(input_line,*) text, iatom
         !
         wan_data(iwan,ispin)%iatom = iatom
         wan_data(iwan,ispin)%ning = ning
         wan_data(iwan,ispin)%bands_from = b_from
         wan_data(iwan,ispin)%bands_to = b_to
         !
         DO j=1, ning
            CALL read_line( input_line, end_of_file = tend )
            !
            IF ( tend ) &
               CALL errore( 'read_cards', &
                           'not enough wavefunctions', j )
            IF (ning==1) THEN
               READ(input_line,*) lo,im
               c = 1.d0
            ELSE
               READ(input_line,*) lo,im,c
            ENDIF

            SELECT CASE(trim(lo))
            CASE('s')
               il = 0
            CASE('p')
               il = 1
            CASE('d')
               il = 2
            CASE('f')
               il = 3
            CASE DEFAULT
               CALL errore( 'read_cards', &
                           'wrong l-label', 1 )
            END SELECT

            wan_data(iwan,ispin)%ing(j)%l = il
            wan_data(iwan,ispin)%ing(j)%m = im
            wan_data(iwan,ispin)%ing(j)%c = c
         ENDDO
      ENDDO

      !Is there spin 2 information?
      CALL read_line( input_line, end_of_file = tend )
      !
      IF ( .not. tend ) THEN
         READ(input_line,*) text
         IF ( trim(text) == 'Spin#2:') THEN ! ok, there is spin 2 data
            ispin = 2
            !
            DO i = 1, nwan
               !
               CALL read_line( input_line, end_of_file = tend )
               !
               IF ( tend ) &
                  CALL errore( 'read_cards', &
                              'end of file reading trial wfc composition', i )
               !
               CALL field_count( nfield, input_line )
               !
               IF ( nfield == 4 ) THEN
                  READ(input_line,*) text, iwan, b_from, b_to
                  ning = 1
               ELSEIF ( nfield == 4 ) THEN
                  READ(input_line,*) text, iwan, b_from, b_to, ning
               ELSE
                  CALL errore( 'read_cards', &
                              'wrong format', nfield )
               ENDIF
               IF(iwan/=i) CALL errore( 'read_cards', 'wrong wannier order', iwan)

               ! Read atom number
               CALL read_line( input_line, end_of_file = tend )
               READ(input_line,*) text, iatom
               !
               wan_data(iwan,ispin)%iatom = iatom
               wan_data(iwan,ispin)%ning = ning
               wan_data(iwan,ispin)%bands_from = b_from
               wan_data(iwan,ispin)%bands_to = b_to
               !
               DO j=1, ning
                  CALL read_line( input_line, end_of_file = tend )
                  !
                  IF ( tend ) &
                     CALL errore( 'read_cards', &
                                 'not enough wavefunctions', j )
                  IF (ning==1) THEN
                     READ(input_line,*) lo,im
                     c = 1.d0
                  ELSE
                     READ(input_line,*) lo,im,c
                  ENDIF

                  SELECT CASE(trim(lo))
                  CASE('s')
                     il = 0
                  CASE('p')
                     il = 1
                  CASE('d')
                     il = 2
                  CASE('f')
                     il = 3
                  CASE DEFAULT
                     CALL errore( 'read_cards', &
                                 'wrong l-label', 1 )
                  END SELECT

                  wan_data(iwan,ispin)%ing(j)%l = il
                  wan_data(iwan,ispin)%ing(j)%m = im
                  wan_data(iwan,ispin)%ing(j)%c = c
               ENDDO
            ENDDO
         ENDIF
      ENDIF
      !
      RETURN
      !
   END SUBROUTINE card_wannier_ac
END MODULE read_cards_module
