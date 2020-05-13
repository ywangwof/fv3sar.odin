#!/bin/bash

VARDEFNS="${1-/scratch/ywang/comFV3SAR/test_runs/GDAS0530/var_defns.sh}"
source ${VARDEFNS}
#
# Decode ${EXPTDIR}/FV3SAR_wflow.xml
#
read_dom () {
    local IFS=\>
    read -d \< ENTITY CONTENT
    local ret=$?
    TAG_NAME=${ENTITY%% *}
    ATTRIBUTES=${ENTITY#* }
    #echo "$TAG_NAME, $ATTRIBUTES"
    return $ret
}

parse_entity () {
    if [[ $TAG_NAME == "!ENTITY" ]] ; then
        if [[ $ATTRIBUTES =~ "$1" ]]; then
          #echo $ATTRIBUTES
          local a=${ATTRIBUTES##* \"}
          local b=${a%%\"}
          #echo $b
          eval ${1}=$b
          return
        fi
    fi
}

while read_dom; do
    parse_entity NPROCS_MAKE_LBC1_TO_LBCN
    parse_entity NCORES_PER_NODE
    parse_entity PROC_MAKE_LBC1_TO_LBCN
done < ${EXPTDIR}/FV3SAR_wflow.xml

nodes=${PROC_MAKE_LBC1_TO_LBCN%%:*}
ppn=${PROC_MAKE_LBC1_TO_LBCN##*=}
numprocess=$(( nodes*ppn ))

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
#SBATCH -p ${QUEUE_DEFAULT}
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
