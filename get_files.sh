#!/bin/bash

VARDEFNS="$(realpath ${1-var_defns.sh})"
source ${VARDEFNS}

CODEBASE="${HOMErrfs}"
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

source /scratch/software/Odin/python/anaconda2/etc/profile.d/conda.sh
conda activate regional_workflow

export EXPTDIR=${EXPTDIR}

EOF

sed "1d" ${CODEBASE}/ush/wrappers/run_get_ics.sh > ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

chmod +x ${jobscript}

${jobscript} >& out.get_files_ics


#
# Step 2.  Get files for LBCs
#

jobscript="get_lbc_files.sh"

read -r -d '' taskheader <<EOF
#!/bin/bash

source /scratch/software/Odin/python/anaconda2/etc/profile.d/conda.sh
conda activate regional_workflow

export EXPTDIR=${EXPTDIR}

EOF

sed "1d" ${CODEBASE}/ush/wrappers/run_get_lbcs.sh > ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

chmod +x ${jobscript}

${jobscript} >& out.get_files_lbc

exit 0
