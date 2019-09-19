#
#-----------------------------------------------------------------------
#
# This is the local workflow configuration file.  It is not tracked by
# the git repository.
#
#-----------------------------------------------------------------------
#
#RUN_ENVIR="nco"
RUN_ENVIR="community"

MACHINE="ODIN"
ACCOUNT="smallqueue"
QUEUE_DEFAULT="workq"
QUEUE_HPSS="None"
QUEUE_RUN_FV3="workq"

BASEDIR="/scratch/ywang/comFV3SAR/regional_workflow.gsd"
UPPDIR="/scratch/ywang/comFV3SAR/regional_workflow.gsd/sorc/EMC_post/sorc/ncep_post.fd"

EXPT_BASEDIR="$BASEDIR/expt_dirs"
# If EXPT_SUBDIR is specified, then expt_title will be ignored.
EXPT_SUBDIR="gsd_test"
#expt_title="my_experiment"

DATE_FIRST_CYCL="20180501"
DATE_LAST_CYCL="20180501"
#CYCL_HRS=( "00" "12" )
CYCL_HRS=( "00" )

fcst_len_hrs="6"
LBC_UPDATE_INTVL_HRS="6"
#LBC_UPDATE_INTVL_HRS="1"

#predef_domain="GSD_HRRR3km"
predef_domain="GSD_HRRR25km"
grid_gen_method="JPgrid"

preexisting_dir_method="delete"
quilting=".true."
#
CCPP="true"
#CCPP_phys_suite="GSD"
CCPP_phys_suite="GFS"

#EXTRN_MDL_NAME_ICSSURF="GSMGFS"
EXTRN_MDL_NAME_ICSSURF="GSMGFS"
#EXTRN_MDL_NAME_ICSSURF="HRRRX"

#EXTRN_MDL_NAME_LBCS="GSMGFS"
EXTRN_MDL_NAME_LBCS="GSMGFS"
#EXTRN_MDL_NAME_LBCS="RAPX"
#EXTRN_MDL_NAME_LBCS="HRRRX"

RUN_TASK_MAKE_GRID_OROG="TRUE"
#RUN_TASK_MAKE_GRID_OROG="FALSE"
#PREGEN_GRID_OROG_DIR="$BASEDIR/pregen_grid_orog"

RUN_TASK_MAKE_SFC_CLIMO="TRUE"
#RUN_TASK_MAKE_SFC_CLIMO="FALSE"
#PREGEN_SFC_CLIMO_DIR="$BASEDIR/pregen_sfc_climo"

TMPDIR=/scratch/ywang/comFV3SAR/tmp/gsd_test
