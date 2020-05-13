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


nodes=${PROC_RUN_FCST%%:*}
ppn=${PROC_RUN_FCST##*=}
numprocess=$(( nodes*ppn ))

walltime=${RSRC_RUN_FCST#<walltime>}
walltime=${walltime%</walltime>}

queue=${QUEUE_FCST#<queue>}
#queue=${QUEUE_DEFAULT#<queue>}
queue=${queue%</queue>}

##@@@@@@@@@@@@@@@@@@@@@@@@@@@@

CODEBASE="${HOMErrfs}"
PDY="${DATE_FIRST_CYCL}"
HH="${CYCL_HRS}"
CYCLE_DIR="${EXPTDIR}/${PDY}${HH}"

WRKDIR="${LOGDIR}"

if [[ ! -d $WRKDIR ]]; then
  mkdir $WRKDIR
fi

cd $WRKDIR

jobscript="run_FV3SAR.sh"

read -r -d '' taskheader <<EOF
#!/bin/sh -l
#SBATCH -A ${ACCOUNT}
#SBATCH -p ${queue}
#SBATCH -J fv3sar
#SBATCH --nodes=${nodes} --ntasks-per-node=${ppn}
#SBATCH --exclusive
#SBATCH -t ${walltime}
#SBATCH -o out.fv3sar_%j
#SBATCH -e err.fv3sar_%j

export GLOBAL_VAR_DEFNS_FP="${VARDEFNS}"
export CDATE="${PDY}${HH}"
export PDY="${PDY}"
export CYCLE_DIR="${CYCLE_DIR}"

export NPROCS=${numprocess}

EOF


cd $WRKDIR
cp ${CODEBASE}/jobs/JREGIONAL_RUN_FCST ${jobscript}

sed -i "1d" ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

sbatch ${jobscript}

exit 0
