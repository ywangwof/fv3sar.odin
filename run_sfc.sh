#!/bin/bash
VARDEFNS="$(realpath ${1-var_defns.sh})"
source ${VARDEFNS}

xmlparser="$(dirname $0)/read_xml.py"
taskname="make_sfc_climo"

resources=$($xmlparser -t $taskname -g nodes $EXPTDIR/FV3LAM_wflow.xml)
#echo $resources

nodes=${resources%%:ppn=*}
ppn=${resources##?:ppn=}
numprocess=$(( nodes*ppn ))
walltime=$($xmlparser -t $taskname -g walltime $EXPTDIR/FV3LAM_wflow.xml)
queue=${QUEUE_DEFAULT}


##@@@@@@@@@@@@@@@@@@@@@@@@@@@@

CODEBASE="${HOMErrfs}"

#
# Prepare the job script and submit
#
WRKDIR="${EXPTDIR}/log"
if [[ ! -d $WRKDIR ]]; then
  mkdir $WRKDIR
fi

cd $WRKDIR

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

export EXPTDIR=${EXPTDIR}

EOF

jobscript="$taskname.job"

sed "1d" ${CODEBASE}/ush/wrappers/run_make_sfc_climo.sh > ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

sbatch ${jobscript}

exit 0
