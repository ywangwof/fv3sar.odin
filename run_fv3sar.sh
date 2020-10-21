#!/bin/bash

VARDEFNS="$(realpath ${1-var_defns.sh})"
source ${VARDEFNS}

xmlparser="$(dirname $0)/read_xml.py"

resources=$($xmlparser -t run_fcst -g nodes $EXPTDIR/FV3LAM_wflow.xml)
echo $resources

nodes=${resources%%:ppn=*}
ppn=${resources##?:ppn=}
numprocess=$(( nodes*ppn ))
walltime=$($xmlparser -t run_fcst -g walltime $EXPTDIR/FV3LAM_wflow.xml)
queue=${QUEUE_FCST}

##@@@@@@@@@@@@@@@@@@@@@@@@@@@@

CODEBASE="${HOMErrfs}"

WRKDIR="${LOGDIR}"
if [[ ! -d $WRKDIR ]]; then
  mkdir $WRKDIR
fi

cd $WRKDIR

jobscript="run_FV3SAR.job"

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

source /scratch/software/Odin/python/anaconda2/etc/profile.d/conda.sh
conda activate regional_workflow

export EXPTDIR=${EXPTDIR}

EOF


sed "1d" ${CODEBASE}/ush/wrappers/run_fcst.sh  > ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

sbatch ${jobscript}

exit 0
