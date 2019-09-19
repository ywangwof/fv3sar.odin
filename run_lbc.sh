#!/bin/bash

CODEBASE="/scratch/ywang/comFV3SAR/regional_workflow.gsd"
VARDEFNS="/scratch/ywang/comFV3SAR/regional_workflow.gsd/expt_dirs/gsd_test/var_defns.sh"
WRKDIR="/scratch/ywang/comFV3SAR/regional_workflow.gsd/expt_dirs/gsd_test/log"

PDY="20180501"
jobscript="make_LBC1_to_LBCN.sh"

read -r -d '' taskheader <<EOF
#!/bin/sh -l
#SBATCH -A smallqueue
#SBATCH -p workq
#SBATCH -J make_LBC
#SBATCH -N 2 -n 48
#SBATCH --ntasks-per-node=24
#SBATCH --exclusive
#SBATCH -t 00:45:00
#SBATCH -o out.lbc_%j
#SBATCH -e err.lbc_%j

export SCRIPT_VAR_DEFNS_FP="${VARDEFNS}"
export CDATE="${PDY}00"
export PDY="${PDY}"

EOF


cd $WRKDIR
cp ${CODEBASE}/jobs/JREGIONAL_MAKE_LBC1_TO_LBCN ${jobscript}

sed -i "1d" ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

sbatch ${jobscript}

exit 0
