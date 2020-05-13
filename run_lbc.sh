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

nodes=${PROC_MAKE_LBC1_TO_LBCN%%:*}
ppn=${PROC_MAKE_LBC1_TO_LBCN##*=}
numprocess=$(( nodes*ppn ))

walltime=${RSRC_MAKE_LBC1_TO_LBCN#<walltime>}
walltime=${walltime%</walltime>}

queue=${QUEUE_DEFAULT#<queue>}
queue=${queue%</queue>}

##@@@@@@@@@@@@@@@@@@@@@@@@@@@@

#
# Prepare job script based on ${CODEBASE}/jobs/JREGIONAL_MAKE_LBCS
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

jobscript="make_LBC.sh"

read -r -d '' taskheader <<EOF
#!/bin/sh -l
#SBATCH -A ${ACCOUNT}
#SBATCH -p ${queue}
#SBATCH -J make_LBC
#SBATCH -N ${nodes} -n ${numprocess}
#SBATCH --ntasks-per-node=${ppn}
#SBATCH --exclusive
#SBATCH -t 00:45:00
#SBATCH -o out.lbc_%j
#SBATCH -e err.lbc_%j

export GLOBAL_VAR_DEFNS_FP="${VARDEFNS}"
export CDATE="${PDY}${HH}"
export PDY="${PDY}"
export CYCLE_DIR="${CYCLE_DIR}"
export NPROCS=${NPROCS_MAKE_LBC1_TO_LBCN}

EOF


cd $WRKDIR
cp ${CODEBASE}/jobs/JREGIONAL_MAKE_LBCS ${jobscript}

sed -i "1d" ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

sbatch ${jobscript}

exit 0
