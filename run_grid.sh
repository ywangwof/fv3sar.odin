#!/bin/bash

CODEBASE="/scratch/ywang/comFV3SAR/regional_workflow.gsd"
VARDEFNS="/scratch/ywang/comFV3SAR/regional_workflow.gsd/expt_dirs/gsd_test/var_defns.sh"
WRKDIR="/scratch/ywang/comFV3SAR/regional_workflow.gsd/expt_dirs/gsd_test/log"

PDY="20180501"

read -r -d '' taskheader <<EOF
#!/bin/sh -l
#SBATCH -A smallqueue
#SBATCH -p workq
#SBATCH -J fv3_grid
#SBATCH -N 1 -n 1
#SBATCH --ntasks-per-node=1
#SBATCH --exclusive
#SBATCH -t 02:45:00
#SBATCH -o out.grid_%j
#SBATCH -e err.grid_%j

export SCRIPT_VAR_DEFNS_FP="${VARDEFNS}"
export PDY="${PDY}"

EOF

if [[ ! -d $WRKDIR ]]; then
  mkdir $WRKDIR
fi

cd $WRKDIR
cp ${CODEBASE}/ush/make_grid_orog.sh .

sed -i "1d" make_grid_orog.sh
echo "$taskheader" | cat - make_grid_orog.sh > temp && mv temp make_grid_orog.sh

sbatch make_grid_orog.sh

exit 0
