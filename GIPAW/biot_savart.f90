! Copyright (C) 2001-2005 Quantum ESPRESSO group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
!-----------------------------------------------------------------------
SUBROUTINE biot_savart(jpol)
  !-----------------------------------------------------------------------
  !
  ! ... Compute the induced magentic field via the Biot-Savart law
  ! ... B_ind(r) = (1/c) \int d^3r' j(r') (r-r')/|r-r'|
  ! ... which in reciprocal space reads:
  ! ... B_ind(G) = (4\pi/c) (i G \times j(G))/G^2
  ! ... the G=0 is not computed here and is given by chi_bare
  USE kinds,                ONLY : DP
  USE constants,            ONLY : fpi
  USE klist,                ONLY : xk
  USE wvfct,                ONLY : nbnd, npwx, npw, igk
  USE gvect,                ONLY : ngm, gstart, nl, nlm, g, gg
  USE fft_base,             ONLY : dffts
  USE fft_interfaces,       ONLY : fwfft, invfft
  USE pwcom
  USE gipaw_module,         ONLY : b_ind, b_ind_r, j_bare, alpha

  !-- parameters ---------------------------------------------------------
  IMPLICIT none
  INTEGER, INTENT(IN) :: jpol

  !-- local variables ----------------------------------------------------
  COMPLEX(DP), allocatable :: aux(:), j_of_g(:,:)
  complex(dp) :: fact
  INTEGER :: ig, ipol, ispin

  call start_clock('biot_savart')

  ! allocate memory
  allocate(aux(dffts%nnr), j_of_g(1:ngm,3))

  ! transform current to reciprocal space
  j_of_g(:,:) = 0.0_dp
  do ispin = 1, nspin
    do ipol = 1, 3
      aux(1:dffts%nnr) = j_bare(1:dffts%nnr,ipol,jpol,ispin)
      CALL fwfft ('Smooth', aux, dffts)
      j_of_g(1:ngm,ipol) = j_of_g(1:ngm,ipol) + aux(nl(1:ngm))
    enddo
  enddo

  ! compute induced field in reciprocal space
  do ig = gstart, ngm
    fact = (0.0_dp,1.0_dp) * (alpha*fpi) / (gg(ig) * tpiba)
    b_ind(ig,1,jpol) = fact * (g(2,ig)*j_of_g(ig,3) - g(3,ig)*j_of_g(ig,2))
    b_ind(ig,2,jpol) = fact * (g(3,ig)*j_of_g(ig,1) - g(1,ig)*j_of_g(ig,3))
    b_ind(ig,3,jpol) = fact * (g(1,ig)*j_of_g(ig,2) - g(2,ig)*j_of_g(ig,1))
  enddo

  ! transform induced field in real space
  do ipol = 1, 3
    aux = (0.0_dp,0.0_dp)
    aux(nl(1:ngm)) = b_ind(1:ngm,ipol,jpol)
    CALL invfft ('Smooth', aux, dffts)
    b_ind_r(1:dffts%nnr,ipol,jpol) = real(aux(1:dffts%nnr))
  enddo

  deallocate(aux, j_of_g)
  call stop_clock('biot_savart')

END SUBROUTINE biot_savart



SUBROUTINE field_to_reciprocal_space
  USE kinds,                ONLY : DP
  USE fft_base,             ONLY : dffts
  USE fft_interfaces,       ONLY : fwfft
  USE gvect,                ONLY : ngm, gstart, nl, nlm, g, gg
  USE gipaw_module

  IMPLICIT NONE
  complex(dp), allocatable :: aux(:)
  integer :: ipol, jpol

  allocate(aux(dffts%nnr))
  b_ind(:,:,:) = 0.0_dp
  do ipol = 1, 3
    do jpol = 1, 3
      aux(1:dffts%nnr) = b_ind_r(1:dffts%nnr,ipol,jpol)
      CALL fwfft ('Smooth', aux, dffts)
      b_ind(1:ngm,ipol,jpol) = aux(nl(1:ngm))
    enddo
  enddo
  deallocate(aux)

END SUBROUTINE field_to_reciprocal_space
