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

nodes=${PROC_MAKE_ICS_SURF_LBC0%%:*}
ppn=${PROC_MAKE_ICS_SURF_LBC0##*=}
numprocess=$(( nodes*ppn ))

walltime=${RSRC_MAKE_ICS_SURF_LBC0#<walltime>}
walltime=${walltime%</walltime>}

queue=${QUEUE_DEFAULT#<queue>}
queue=${queue%</queue>}

##@@@@@@@@@@@@@@@@@@@@@@@@@@@@


#echo $NPROCS_MAKE_ICS_SURF_LBC0, $NCORES_PER_NODE, $PROC_MAKE_ICS_SURF_LBC0
#echo $nodes, $ppn, $numprocess
#exit 0

#
# Prepare job script based on ${CODEBASE}/jobs/JREGIONAL_MAKE_ICS
#
CODEBASE="${HOMErrfs}"
PDY="${DATE_FIRST_CYCL}"
HH="${CYCL_HRS}"
CYCLE_DIR="${EXPTDIR}/${PDY}${HH}"

WRKDIR="${LOGDIR}"

if [[ ! -d $WRKDIR ]]; then
  mkdir $WRKDIR
fi

cd $WRKDIR

jobscript="make_ICS.sh"

read -r -d '' taskheader <<EOF
#!/bin/sh -l
#SBATCH -A ${ACCOUNT}
#SBATCH -p ${queue}
#SBATCH -J make_ICS
#SBATCH -N ${nodes} -n ${numprocess}
#SBATCH --ntasks-per-node=${ppn}
#SBATCH --exclusive
#SBATCH -t ${walltime}
#SBATCH -o out.ics_%j
#SBATCH -e err.ics_%j

export GLOBAL_VAR_DEFNS_FP="${VARDEFNS}"
export CDATE="${PDY}${HH}"
export PDY="${PDY}"
export CYCLE_DIR="${CYCLE_DIR}"
export NPROCS=${NPROCS_MAKE_ICS_SURF_LBC0}

EOF


cp ${CODEBASE}/jobs/JREGIONAL_MAKE_ICS ${jobscript}

sed -i "1d" ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

sbatch ${jobscript}

exit 0
