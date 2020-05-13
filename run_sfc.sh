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

nodes=${PROC_MAKE_SFC_CLIMO%%:*}
ppn=${PROC_MAKE_SFC_CLIMO##*=}
numprocess=$(( nodes*ppn ))

walltime=${RSRC_MAKE_GRID#<walltime>}
walltime=${walltime%</walltime>}

queue=${QUEUE_DEFAULT#<queue>}
queue=${queue%</queue>}

##@@@@@@@@@@@@@@@@@@@@@@@@@@@@

CODEBASE="${HOMErrfs}"
PDY="${DATE_FIRST_CYCL}"

#
# Prepare the job script and submit
#
WRKDIR="${EXPTDIR}/log"

if [[ ! -d $WRKDIR ]]; then
  mkdir $WRKDIR
fi

cd $WRKDIR

jobscript="make_sfc_climo.sh"

read -r -d '' taskheader <<EOF
#!/bin/bash
#SBATCH -A ${ACCOUNT}
#SBATCH -p ${queue}
#SBATCH -J fv3_sfc
#SBATCH -N $nodes -n $numprocess
#SBATCH --ntasks-per-node=$ppn
#SBATCH --exclusive
#SBATCH -t ${walltime}
#SBATCH -o out.sfc_%j
#SBATCH -e err.sfc_%j

export GLOBAL_VAR_DEFNS_FP="${VARDEFNS}"
export PDY="${PDY}"

source ${HOMErrfs}/modulefiles/tasks/${MACHINE,,}/make_sfc_climo

export NPROCS=${numprocess}

EOF


cp ${CODEBASE}/jobs/JREGIONAL_MAKE_SFC_CLIMO ${jobscript}

sed -i "1d" ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

sbatch ${jobscript}

exit 0
