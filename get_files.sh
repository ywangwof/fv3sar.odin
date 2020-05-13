#!/bin/bash

VARDEFNS="${1-/scratch/ywang/comFV3SAR/test_runs/GDAS0530/var_defns.sh}"
source ${VARDEFNS}

CODEBASE="${HOMErrfs}"
PDY="${DATE_FIRST_CYCL}"
HH="${CYCL_HRS}"
CYCLE_DIR="${EXPTDIR}/${PDY}${HH}"

sed -i -e "/EXTRN_MDL_FILES_SYSBASEDIR_ICS=/c\EXTRN_MDL_FILES_SYSBASEDIR_ICS=\"/scratch/ywang/EPIC/GDAS/${PDY}${HH}_mem001\"" ${VARDEFNS}
sed -i -e "/EXTRN_MDL_FILES_SYSBASEDIR_LBCS=/c\EXTRN_MDL_FILES_SYSBASEDIR_LBCS=\"/scratch/ywang/EPIC/GDAS/${PDY}${HH}_mem001\"" ${VARDEFNS}

WRKDIR="${LOGDIR}"

if [[ ! -d $WRKDIR ]]; then
  mkdir $WRKDIR
fi

cd $WRKDIR

#
# Step 1.  Get files for IC
#

jobscript="get_ics_files.sh"

read -r -d '' taskheader <<EOF
#!/bin/bash

export GLOBAL_VAR_DEFNS_FP="${VARDEFNS}"
export PDY="${PDY}"

export CDATE="${PDY}${HH}"
export EXTRN_MDL_NAME="${EXTRN_MDL_NAME_ICS}"
export ICS_OR_LBCS="ICS"
export CYCLE_DIR="${CYCLE_DIR}"

EOF

cp ${CODEBASE}/jobs/JREGIONAL_GET_EXTRN_FILES ${jobscript}

sed -i "1d" ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

chmod +x ${jobscript}

${jobscript} >& out.get_files_ics


#
# Step 2.  Get files for LBCs
#

jobscript="get_lbc_files.sh"

read -r -d '' taskheader <<EOF
#!/bin/bash

export GLOBAL_VAR_DEFNS_FP="${VARDEFNS}"
export PDY="${PDY}"

export CDATE="${PDY}${HH}"
export EXTRN_MDL_NAME="${EXTRN_MDL_NAME_LBCS}"
export ICS_OR_LBCS="LBCS"
export CYCLE_DIR="${CYCLE_DIR}"

EOF

cp ${CODEBASE}/jobs/JREGIONAL_GET_EXTRN_FILES ${jobscript}

sed -i "1d" ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

chmod +x ${jobscript}

${jobscript} >& out.get_files_lbc

exit 0
