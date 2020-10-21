#!/bin/bash

VARDEFNS="$(realpath ${1-var_defns.sh})"
source ${VARDEFNS}

xmlparser="$(dirname $0)/read_xml.py"
taskname="run_post"

resources=$($xmlparser -t $taskname -m -g nodes $EXPTDIR/FV3LAM_wflow.xml)
echo $resources

nodes=${resources%%:ppn=*}
ppn=${resources##?:ppn=}
numprocess=$(( nodes*ppn ))
walltime=$($xmlparser -t $taskname -m -g walltime $EXPTDIR/FV3LAM_wflow.xml)
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

read -r -d '' taskheader <<EOF
#!/bin/sh -l
#SBATCH -A ${ACCOUNT}
#SBATCH -p ${queue}
#SBATCH -J fv3_post
#SBATCH --nodes=${nodes} --ntasks-per-node=${ppn}
#SBATCH --exclusive
#SBATCH -t ${walltime}
#SBATCH -o out.post_%j
#SBATCH -e err.post_%j

source /scratch/software/Odin/python/anaconda2/etc/profile.d/conda.sh
conda activate regional_workflow

export EXPTDIR=${EXPTDIR}

EOF

jobscript="$taskname.job"

sed "1d" ${CODEBASE}/ush/wrappers/run_post.sh > ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

sbatch ${jobscript}

exit 0
