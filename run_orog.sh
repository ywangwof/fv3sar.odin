#!/bin/bash

VARDEFNS="$(realpath ${1-var_defns.sh})"
source ${VARDEFNS}

xmlparser="$(dirname $0)/read_xml.py"
taskname="make_orog"

resources=$($xmlparser -t $taskname -g nodes $EXPTDIR/FV3LAM_wflow.xml)
#echo $resources

nodes=${resources%%:ppn=*}
ppn=${resources##?:ppn=}
numprocess=$(( nodes*ppn ))
walltime=$($xmlparser -t $taskname -g walltime $EXPTDIR/FV3LAM_wflow.xml)
queue=${QUEUE_DEFAULT}

#echo $nodes, $ppn, $numprocess, $walltime, $queue
#exit 0

##@@@@@@@@@@@@@@@@@@@@@@@@@@@@

CODEBASE="${HOMErrfs}"

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

export EXPTDIR=${EXPTDIR}

EOF

jobscript="$taskname.job"
sed "1d" ${CODEBASE}/ush/wrappers/run_make_orog.sh > $jobscript
echo "$taskheader" | cat - $jobscript > temp && mv temp $jobscript

sbatch $jobscript

exit 0
