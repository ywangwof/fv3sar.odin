#!/bin/bash

CODEBASE="/scratch/ywang/comFV3SAR/regional_workflow.gsd"
VARDEFNS="/scratch/ywang/comFV3SAR/regional_workflow.gsd/expt_dirs/gsd_test/var_defns.sh"
WRKDIR="/scratch/ywang/comFV3SAR/regional_workflow.gsd/expt_dirs/gsd_test/log"

PDY="20180501"
jobscript="run_FV3SAR.sh"

read -r -d '' taskheader <<EOF
#!/bin/sh -l
#SBATCH -A smallqueue
#SBATCH -p workq
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
