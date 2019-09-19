#!/bin/bash

CODEBASE="/scratch/ywang/comFV3SAR/regional_workflow.gsd"
VARDEFNS="/scratch/ywang/comFV3SAR/regional_workflow.gsd/expt_dirs/gsd_test/var_defns.sh"
WRKDIR="/scratch/ywang/comFV3SAR/regional_workflow.gsd/expt_dirs/gsd_test/log"

PDY="20180501"
jobscript="make_sfc_climo.sh"

read -r -d '' taskheader <<EOF
#!/bin/bash
#SBATCH -A smallqueue
#SBATCH -p workq
#SBATCH -J fv3_sfc
#SBATCH -N 2 -n 48
#SBATCH --ntasks-per-node=24
#SBATCH --exclusive
#SBATCH -t 00:45:00
#SBATCH -o out.sfc_%j
#SBATCH -e err.sfc_%j

export SCRIPT_VAR_DEFNS_FP="${VARDEFNS}"
export PDY="${PDY}"

EOF


cd $WRKDIR
cp ${CODEBASE}/jobs/JREGIONAL_MAKE_SFC_CLIMO ${jobscript}

sed -i "1d" ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

sbatch ${jobscript}

exit 0
