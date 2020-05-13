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
# make orog
#
read -r -d '' taskheader <<EOF
#!/bin/sh -l
#SBATCH -A ${ACCOUNT}
#SBATCH -p ${QUEUE_DEFAULT}
#SBATCH -J fv3_orog
#SBATCH -N 1 -n 1
#SBATCH --ntasks-per-node=1
#SBATCH --exclusive
#SBATCH -t 02:45:00
#SBATCH -o out.orog_%j
#SBATCH -e err.orog_%j

export GLOBAL_VAR_DEFNS_FP="${VARDEFNS}"
export PDY="${PDY}"

EOF
cp ${CODEBASE}/jobs/JREGIONAL_MAKE_OROG make_orog.sh

sed -i "1d" make_orog.sh
echo "$taskheader" | cat - make_orog.sh > temp && mv temp make_orog.sh

sbatch make_orog.sh

exit 0
