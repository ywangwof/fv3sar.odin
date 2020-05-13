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

nodes=${PROC_MAKE_OROG%%:*}
ppn=${PROC_MAKE_OROG##*=}
numprocess=$(( nodes*ppn ))

walltime=${RSRC_MAKE_OROG#<walltime>}
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
# make orog
#
read -r -d '' taskheader <<EOF
#!/bin/sh -l
#SBATCH -A ${ACCOUNT}
#SBATCH -p ${queue}
#SBATCH -J fv3_orog
#SBATCH -N ${nodes} -n ${numprocess}
#SBATCH --ntasks-per-node=${ppn}
#SBATCH --exclusive
#SBATCH -t ${walltime}
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
