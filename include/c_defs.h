/*
  Copyright (C) 2002-2004 PWSCF,FPMD,CPV groups
  This file is distributed under the terms of the
  GNU General Public License. See the file `License'
  in the root directory of the present distribution,
  or http://www.gnu.org/copyleft/gpl.txt .
*/


#if defined __T3E || defined __ABSOFT

#  define FFTW_INPLACE_DRV_1D FFTW_INPLACE_DRV_1D
#  define FFTW_INPLACE_DRV_2D FFTW_INPLACE_DRV_2D
#  define FFTW_INPLACE_DRV_3D FFTW_INPLACE_DRV_3D
#  define CREATE_PLAN_1D CREATE_PLAN_1D
#  define CREATE_PLAN_2D CREATE_PLAN_2D
#  define CREATE_PLAN_3D CREATE_PLAN_3D
#  define DESTROY_PLAN_1D DESTROY_PLAN_1D
#  define DESTROY_PLAN_2D DESTROY_PLAN_2D
#  define DESTROY_PLAN_3D DESTROY_PLAN_3D
#  define FFT_X_STICK FFT_X_STICK
#  define FFT_Y_STICK FFT_Y_STICK
#  define FFT_Z_STICK FFT_Z_STICK
#  define CPFLUSH CPFLUSH
#  define ELAPSED_SECONDS ELAPSED_SECONDS
#  define CCLOCK CCLOCK
#  define LN_ALLOC LN_ALLOC 
#  define LN_DEALLOC LN_DEALLOC
#  define LN_SET LN_SET
#  define LN_ACTIVATE LN_ACTIVATE
#  define LN_IND LN_IND
#  define MEMSTAT MEMSTAT
#  define C_MKDIR C_MKDIR

#endif

#if defined __SGI || defined __FUJITSU || defined __SX4 || defined __INTEL || defined __LAHEY || defined __SX6 || defined SUN || defined __ALTIX

#  define FFTW_INPLACE_DRV_1D fftw_inplace_drv_1d_
#  define FFTW_INPLACE_DRV_2D fftw_inplace_drv_2d_
#  define FFTW_INPLACE_DRV_3D fftw_inplace_drv_3d_
#  define CREATE_PLAN_1D create_plan_1d_
#  define CREATE_PLAN_2D create_plan_2d_
#  define CREATE_PLAN_3D create_plan_3d_
#  define DESTROY_PLAN_1D destroy_plan_1d_
#  define DESTROY_PLAN_2D destroy_plan_2d_
#  define DESTROY_PLAN_3D destroy_plan_3d_
#  define FFT_X_STICK fft_x_stick_
#  define FFT_Y_STICK fft_y_stick_
#  define FFT_Z_STICK fft_z_stick_
#  define CPFLUSH cpflush_
#  define ELAPSED_SECONDS elapsed_seconds_
#  define CCLOCK cclock_
#  define LN_ALLOC ln_alloc_ 
#  define LN_DEALLOC ln_dealloc_
#  define LN_SET ln_set_
#  define LN_ACTIVATE ln_activate_
#  define LN_IND ln_ind_
#  define MEMSTAT memstat_
#  define C_MKDIR c_mkdir_

#endif

#if defined __PGI

#  if defined __GNU_LINK

#  define FFTW_INPLACE_DRV_1D fftw_inplace_drv_1d__
#  define FFTW_INPLACE_DRV_2D fftw_inplace_drv_2d__
#  define FFTW_INPLACE_DRV_3D fftw_inplace_drv_3d__
#  define CREATE_PLAN_1D create_plan_1d__
#  define CREATE_PLAN_2D create_plan_2d__
#  define CREATE_PLAN_3D create_plan_3d__
#  define DESTROY_PLAN_1D destroy_plan_1d__
#  define DESTROY_PLAN_2D destroy_plan_2d__
#  define DESTROY_PLAN_3D destroy_plan_3d__
#  define FFT_X_STICK fft_x_stick__
#  define FFT_Y_STICK fft_y_stick__
#  define FFT_Z_STICK fft_z_stick__
#  define CPFLUSH cpflush_
#  define ELAPSED_SECONDS elapsed_seconds_
#  define CCLOCK cclock_
#  define LN_ALLOC ln_alloc__
#  define LN_DEALLOC ln_dealloc__
#  define LN_SET ln_set__
#  define LN_ACTIVATE ln_activate__
#  define LN_IND ln_ind__
#  define MEMSTAT memstat_
#  define C_MKDIR c_mkdir_

#  else

#  define FFTW_INPLACE_DRV_1D fftw_inplace_drv_1d_
#  define FFTW_INPLACE_DRV_2D fftw_inplace_drv_2d_
#  define FFTW_INPLACE_DRV_3D fftw_inplace_drv_3d_
#  define CREATE_PLAN_1D create_plan_1d_
#  define CREATE_PLAN_2D create_plan_2d_
#  define CREATE_PLAN_3D create_plan_3d_
#  define DESTROY_PLAN_1D destroy_plan_1d_
#  define DESTROY_PLAN_2D destroy_plan_2d_
#  define DESTROY_PLAN_3D destroy_plan_3d_
#  define FFT_X_STICK fft_x_stick_
#  define FFT_Y_STICK fft_y_stick_
#  define FFT_Z_STICK fft_z_stick_
#  define CPFLUSH cpflush_
#  define ELAPSED_SECONDS elapsed_seconds_
#  define CCLOCK cclock_
#  define LN_ALLOC ln_alloc_
#  define LN_DEALLOC ln_dealloc_
#  define LN_SET ln_set_
#  define LN_ACTIVATE ln_activate_
#  define LN_IND ln_ind_
#  define MEMSTAT memstat_
#  define C_MKDIR c_mkdir_

#  endif

#endif

#if defined __G95

#  define FFTW_INPLACE_DRV_1D fftw_inplace_drv_1d__
#  define FFTW_INPLACE_DRV_2D fftw_inplace_drv_2d__
#  define FFTW_INPLACE_DRV_3D fftw_inplace_drv_3d__
#  define CREATE_PLAN_1D create_plan_1d__
#  define CREATE_PLAN_2D create_plan_2d__
#  define CREATE_PLAN_3D create_plan_3d__
#  define DESTROY_PLAN_1D destroy_plan_1d__
#  define DESTROY_PLAN_2D destroy_plan_2d__
#  define DESTROY_PLAN_3D destroy_plan_3d__
#  define FFT_X_STICK fft_x_stick__
#  define FFT_XY_STICK fft_xy_stick__
#  define FFT_XY fft_xy__
#  define FFT_Y_STICK fft_y_stick__
#  define FFT_Y_STICK2 fft_y_stick2__
#  define FFT_Z_STICK fft_z_stick__
#  define FFT_Z fft_z__
#  define FFT_STICK fft_stick__
#  define CP_GETENV cp_getenv__
#  define CP_DATE cp_date__
#  define CPFLUSH cpflush_
#  define CPTIMER cptimer__
#  define ELAPSED_SECONDS elapsed_seconds__
#  define CCLOCK cclock_
#  define FACTOR235 factor235__
#  define FACTOR2 factor2__
#  define LN_ALLOC ln_alloc__
#  define LN_DEALLOC ln_dealloc__
#  define LN_SET ln_set__
#  define LN_ACTIVATE ln_activate__
#  define LN_IND ln_ind__
#  define MEMSTAT memstat_
#  define READOCC readocc_
#  define ROUND2 round2_
#  define MYUNITNAME myunitname_
#  define CP_ITOA cp_itoa_
#  define C_MKDIR c_mkdir__

#endif

#if defined __AIX || defined __HP || defined __MAC

#  define FFTW_INPLACE_DRV_1D fftw_inplace_drv_1d
#  define FFTW_INPLACE_DRV_2D fftw_inplace_drv_2d
#  define FFTW_INPLACE_DRV_3D fftw_inplace_drv_3d
#  define CREATE_PLAN_2D create_plan_2d
#  define CREATE_PLAN_3D create_plan_3d
#  define CREATE_PLAN_1D create_plan_1d
#  define DESTROY_PLAN_1D destroy_plan_1d
#  define DESTROY_PLAN_2D destroy_plan_2d
#  define DESTROY_PLAN_3D destroy_plan_3d
#  define FFT_X_STICK fft_x_stick
#  define FFT_Y_STICK fft_y_stick
#  define FFT_Z_STICK fft_z_stick
#  define CPFLUSH cpflush
#  define ELAPSED_SECONDS elapsed_seconds
#  define CCLOCK cclock
#  define LN_ALLOC ln_alloc 
#  define LN_DEALLOC ln_dealloc
#  define LN_SET ln_set
#  define LN_ACTIVATE ln_activate
#  define LN_IND ln_ind
#  define MEMSTAT memstat
#  define C_MKDIR c_mkdir

#endif


#if defined __ALPHA && !defined __LINUX64

#  define FFTW_INPLACE_DRV_1D fftw_inplace_drv_1d_
#  define FFTW_INPLACE_DRV_2D fftw_inplace_drv_2d_
#  define FFTW_INPLACE_DRV_3D fftw_inplace_drv_3d_
#  define CREATE_PLAN_2D create_plan_2d_
#  define CREATE_PLAN_3D create_plan_3d_
#  define CREATE_PLAN_1D create_plan_1d_
#  define DESTROY_PLAN_1D destroy_plan_1d_
#  define DESTROY_PLAN_2D destroy_plan_2d_
#  define DESTROY_PLAN_3D destroy_plan_3d_
#  define FFT_X_STICK fft_x_stick_
#  define FFT_Y_STICK fft_y_stick_
#  define FFT_Z_STICK fft_z_stick_
#  define CPFLUSH cpflush_
#  define ELAPSED_SECONDS elapsed_seconds_
#  define CCLOCK cclock_
#  define LN_ALLOC ln_alloc_
#  define LN_DEALLOC ln_dealloc_
#  define LN_SET ln_set_
#  define LN_ACTIVATE ln_activate_
#  define LN_IND ln_ind_
#  define MEMSTAT memstat_
#  define C_MKDIR c_mkdir_

#endif

#if defined __ALPHA && defined __LINUX64

#    define FFTW_INPLACE_DRV_1D fftw_inplace_drv_1d__
#    define FFTW_INPLACE_DRV_2D fftw_inplace_drv_2d__
#    define FFTW_INPLACE_DRV_3D fftw_inplace_drv_3d__
#    define CREATE_PLAN_1D create_plan_1d__
#    define DESTROY_PLAN_1D destroy_plan_1d__
#    define CREATE_PLAN_2D create_plan_2d__
#    define CREATE_PLAN_3D create_plan_3d__
#    define DESTROY_PLAN_2D destroy_plan_2d__
#    define DESTROY_PLAN_3D destroy_plan_3d__
#    define FFT_X_STICK fft_x_stick__
#    define FFT_Y_STICK fft_y_stick__
#    define FFT_Z_STICK fft_z_stick__
#    define CPFLUSH cpflush_
#    define ELAPSED_SECONDS elapsed_seconds__
#    define CCLOCK cclock_
#    define LN_ALLOC ln_alloc__
#    define LN_DEALLOC ln_dealloc__
#    define LN_SET ln_set__
#    define LN_ACTIVATE ln_activate__
#    define LN_IND ln_ind__
#    define MEMSTAT memstat_
#    define C_MKDIR c_mkdir__

#endif
