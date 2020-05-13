#!/bin/bash

VARDEFNS="${1-/scratch/ywang/comFV3SAR/test_runs/GDAS0530/var_defns.sh}"
source ${VARDEFNS}

CODEBASE="${HOMErrfs}"
PDY="${DATE_FIRST_CYCL}"

WRKDIR="${LOGDIR}"
if [[ ! -d $WRKDIR ]]; then
  mkdir $WRKDIR
fi

cd $WRKDIR
#
# make grid
#
read -r -d '' taskheader <<EOF
#!/bin/sh -l
#SBATCH -A ${ACCOUNT}
#SBATCH -p ${QUEUE_DEFAULT}
#SBATCH -J fv3_grid
#SBATCH -N 1 -n 1
#SBATCH --ntasks-per-node=1
#SBATCH --exclusive
#SBATCH -t 02:45:00
#SBATCH -o out.grid_%j
#SBATCH -e err.grid_%j

export GLOBAL_VAR_DEFNS_FP="${VARDEFNS}"
export USHDIR="${HOMErrfs}/ush"

source ${HOMErrfs}/sorc/UFS_UTILS_develop/modulefiles/fv3gfs/fre-nctools.odin


EOF


cp ${CODEBASE}/jobs/JREGIONAL_MAKE_GRID make_grid.sh

sed -i "1d" make_grid.sh
echo "$taskheader" | cat - make_grid.sh > temp && mv temp make_grid.sh

sbatch make_grid.sh

exit 0
