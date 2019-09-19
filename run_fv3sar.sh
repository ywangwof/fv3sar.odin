#!/bin/bash

source config.sh

CODEBASE="${BASEDIR}"
VARDEFNS="${EXPT_BASEDIR}/${EXPT_SUBDIR}/var_defns.sh"
WRKDIR="${TMPDIR}"

PDY="${DATE_FIRST_CYCL}"

jobscript="run_FV3SAR.sh"

read -r -d '' taskheader <<EOF
#!/bin/sh -l
#SBATCH -A ${ACCOUNT}
#SBATCH -p ${QUEUE_DEFAULT}
#SBATCH -J fv3sar
#SBATCH -N 1 -n 24
#SBATCH --ntasks-per-node=24
#SBATCH --exclusive
#SBATCH -t 08:45:00
#SBATCH -o out.fv3sar_%j
#SBATCH -e err.fv3sar_%j

export SCRIPT_VAR_DEFNS_FP="${VARDEFNS}"
export CDATE="${PDY}00"
export PDY="${PDY}"

EOF


cd $WRKDIR
cp ${CODEBASE}/jobs/JREGIONAL_RUN_FV3 ${jobscript}

sed -i "1d" ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

sbatch ${jobscript}

exit 0
