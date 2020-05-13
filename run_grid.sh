#!/bin/bash

VARDEFNS="$(realpath ${1-var_defns.sh})"
source ${VARDEFNS}

#
# Decode ${EXPTDIR}/FV3SAR_wflow.xml
#
while read line; do
  if [[ $line =~ "<!ENTITY" ]]; then
    line=${line##<!ENTITY}
    line=${line%%>}
    #echo $line
    read var val <<<$line
    eval $var=$val
    #echo $var=$val
  fi
done < ${EXPTDIR}/FV3SAR_wflow.xml

nodes=${PROC_MAKE_GRID%%:*}
ppn=${PROC_MAKE_GRID##*=}
numprocess=$(( nodes*ppn ))

walltime=${RSRC_MAKE_GRID#<walltime>}
walltime=${walltime%</walltime>}

queue=${QUEUE_DEFAULT#<queue>}
queue=${queue%</queue>}

##@@@@@@@@@@@@@@@@@@@@@@@@@@@@
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
#SBATCH -p ${queue}
#SBATCH -J fv3_grid
#SBATCH -N ${nodes} -n ${numprocess}
#SBATCH --ntasks-per-node=${ppn}
#SBATCH --exclusive
#SBATCH -t ${walltime}
#SBATCH -o out.grid_%j
#SBATCH -e err.grid_%j

export GLOBAL_VAR_DEFNS_FP="${VARDEFNS}"
export USHDIR="${HOMErrfs}/ush"

source ${HOMErrfs}/modulefiles/tasks/${MACHINE,,}/make_grid


EOF


cp ${CODEBASE}/jobs/JREGIONAL_MAKE_GRID make_grid.sh

sed -i "1d" make_grid.sh
echo "$taskheader" | cat - make_grid.sh > temp && mv temp make_grid.sh

sbatch make_grid.sh

exit 0
