#!/bin/bash

source config.sh

CODEBASE="${BASEDIR}"
VARDEFNS="${EXPT_BASEDIR}/${EXPT_SUBDIR}/var_defns.sh"
WRKDIR="${TMPDIR}"

PDY="${DATE_FIRST_CYCL}"

jobscript="make_ICS_surf_LBC0.sh"

read -r -d '' taskheader <<EOF
#!/bin/sh -l
#SBATCH -A ${ACCOUNT}
#SBATCH -p ${QUEUE_DEFAULT}
#SBATCH -J make_ICS
#SBATCH -N 2 -n 48
#SBATCH --ntasks-per-node=24
#SBATCH --exclusive
#SBATCH -t 00:45:00
#SBATCH -o out.ics_%j
#SBATCH -e err.ics_%j

export SCRIPT_VAR_DEFNS_FP="${VARDEFNS}"
export CDATE="${PDY}00"
export PDY="${PDY}"

EOF


cd $WRKDIR
cp ${CODEBASE}/jobs/JREGIONAL_MAKE_IC_LBC0 ${jobscript}

sed -i "1d" ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

sbatch ${jobscript}

exit 0
