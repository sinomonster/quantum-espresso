# Makefile for PW
#Modified for v4.0 by obm

include ../../make.sys
IFLAGS         = -I../../include
LIBOBJS        = ../../flib/ptools.a ../../flib/flib.a ../../clib/clib.a ../../iotk/src/libiotk.a ../../Multigrid/mglib.a



# location of needed modules
MODFLAGS= $(MOD_FLAG)../../iotk/src $(MOD_FLAG)../../Modules \
          $(MOD_FLAG)../../EE $(MOD_FLAG) . $(MOD_FLAG)../../PW \
          $(MOD_FLAG)../../PH

QEMODS = ../../Modules/libqemod.a
PWOBJS = ../../PW/libpw.a
EEOBJS = ../../EE/libee.a
PHOBJS=../../PH/libph.a

LROBJS= \
lr_variables.o \
lr_charg_resp.o \
bcast_lr_input.o \
lr_readin.o \
lr_alloc_init.o \
lr_calc_dens.o \
lr_dot.o \
lr_dealloc.o \
lr_ortho.o \
lr_read_wf.o \
lr_normalise.o \
lr_lanczos.o \
lr_apply_liouvillian.o \
lr_main.o \
lr_dv_setup.o \
lr_setup_dgc.o \
lr_solve_e.o \
lr_dvpsi_e.o \
lr_ch_psi_all.o \
lr_cgsolve_all.o \
lr_h_psiq.o \
lr_sm1_psi.o \
stop_lr.o \
lr_read_d0psi.o \
lr_restart.o \
lr_write_restart.o \
print_clock_lr.o \
sd0psi.o \
lr_set_boxes_density.o \
lr_init_nfo.o 

TLDEPS=bindir libs pw ph
 
all :  tldeps tddfpt.x

#tddfpt.x : $(PWOBJS) $(EEOBJS) $(PHOBJS) $(LROBJS) 
#	$(MPIF90) $(LDFLAGS) -o tddfpt.x \
#	$(PWOBJS) $(EEOBJS) $(PHOBJS) $(LROBJS) $(MODULES) $(EEMODS) $(LIBOBJS) $(LIBS) 
#	- ( cd ../../bin; ln -fs ../../TDDFPT/tddfpt.x . )
#
tddfpt.x : $(LROBJS) $(PWOBJS) $(QEMODS) $(PWOBJS) $(PHOBJS) $(PWOBJS) $(EEOBJS) $(LIBOBJS)
	$(LD) $(LDFLAGS) -o $@ \
		$(LROBJS) $(PHOBJS) $(PWOBJS) $(EEOBJS) $(QEMODS) $(LIBOBJS) $(LIBS)
	- ( cd ../../bin ; ln -fs ../TDDFPT/src/$@ . )
	- if [ -d ../bin ] ; then  ( cd ../bin ; ln -fs ../src/$@ . ); fi

dene.x : obm_tests.o 
	$(MPIF90) $(LDFLAGS) -o dene.x \
        $(PWOBJS) $(PHOBJS) obm_tests.o $(QEMODS) $(LIBOBJS) $(LIBS)

tldeps:
	test -n "$(TLDEPS)" && ( cd ../.. ; $(MAKE) $(MFLAGS) $(TLDEPS) || exit 1) || :


clean :
	- /bin/rm -f ../bin/tddfpt.x *.x *.o *~ *.d *.mod *.i work.pc

include make.depend

# DO NOT DELETE
