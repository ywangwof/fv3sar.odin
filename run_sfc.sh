#!/bin/bash
VARDEFNS="${1-/scratch/ywang/comFV3SAR/test_runs/GDAS0530/var_defns.sh}"
source ${VARDEFNS}

CODEBASE="${HOMErrfs}"
PDY="${DATE_FIRST_CYCL}"

#
# Decode XML to retrieve
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
        fi
    fi
}

while read_dom; do
    parse_entity PROC_MAKE_SFC_CLIMO
done < ${EXPTDIR}/FV3SAR_wflow.xml

nodes=${PROC_MAKE_SFC_CLIMO%%:*}
ppn=${PROC_MAKE_SFC_CLIMO##*=}
numprocess=$(( nodes*ppn ))


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
#SBATCH -p ${QUEUE_DEFAULT}
#SBATCH -J fv3_sfc
#SBATCH -N $nodes -n $numprocess
#SBATCH --ntasks-per-node=$ppn
#SBATCH --exclusive
#SBATCH -t 00:45:00
#SBATCH -o out.sfc_%j
#SBATCH -e err.sfc_%j

export GLOBAL_VAR_DEFNS_FP="${VARDEFNS}"
export PDY="${PDY}"

#export APRUN_SFC="srun -n $numprocess"

source ${HOMErrfs}/sorc/UFS_UTILS_develop/modulefiles/modulefile.sfc_climo_gen.odin

EOF


cp ${CODEBASE}/jobs/JREGIONAL_MAKE_SFC_CLIMO ${jobscript}

sed -i "1d" ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

sbatch ${jobscript}

exit 0
