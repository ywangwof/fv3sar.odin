#!/bin/bash

source config.sh

CODEBASE="${BASEDIR}"
VARDEFNS="${EXPT_BASEDIR}/${EXPT_SUBDIR}/var_defns.sh"
WRKDIR="${TMPDIR}"

PDY="${DATE_FIRST_CYCL}"

read -r -d '' taskheader <<EOF
#!/bin/bash

export SCRIPT_VAR_DEFNS_FP="${VARDEFNS}"
export PDY="${PDY}"

EOF


cd $WRKDIR

#
# Step 1.  run stage_static.sh
#
cp ${CODEBASE}/ush/stage_static.sh stage_static.sh

sed -i "1d" stage_static.sh
echo "$taskheader" | cat - stage_static.sh > temp && mv temp stage_static.sh

chmod +x stage_static.sh

stage_static.sh >& out.stage_static

#
# Step 2.  Get files ICS
#

read -r -d '' taskheader <<EOF
#!/bin/bash

export SCRIPT_VAR_DEFNS_FP="${VARDEFNS}"
export PDY="${PDY}"

export CDATE="${PDY}00"
export EXTRN_MDL_NAME="GSMGFS"
export ICSSURF_OR_LBCS="ICSSURF"

EOF

cp ${CODEBASE}/jobs/JREGIONAL_GET_EXTRN_FILES get_extrn_ics_files.sh

sed -i "1d" get_extrn_ics_files.sh
echo "$taskheader" | cat - get_extrn_ics_files.sh > temp && mv temp get_extrn_ics_files.sh

chmod +x get_extrn_ics_files.sh

get_extrn_ics_files.sh >& out.get_files_ics


#
# Step 3.  Get files LBC
#

read -r -d '' taskheader <<EOF
#!/bin/bash

export SCRIPT_VAR_DEFNS_FP="${VARDEFNS}"
export PDY="${PDY}"

export CDATE="${PDY}00"
export EXTRN_MDL_NAME="GSMGFS"
export ICSSURF_OR_LBCS="LBCS"

EOF

cp ${CODEBASE}/jobs/JREGIONAL_GET_EXTRN_FILES get_extrn_lbc_files.sh

sed -i "1d" get_extrn_lbc_files.sh
echo "$taskheader" | cat - get_extrn_lbc_files.sh > temp && mv temp get_extrn_lbc_files.sh

chmod +x get_extrn_lbc_files.sh

get_extrn_lbc_files.sh >& out.get_files_lbc

exit 0
