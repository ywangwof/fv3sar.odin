#!/bin/bash

source config.sh

CODEBASE="${BASEDIR}"
VARDEFNS="${EXPT_BASEDIR}/${EXPT_SUBDIR}/var_defns.sh"
WRKDIR="${TMPDIR}"

PDY="${DATE_FIRST_CYCL}"

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
