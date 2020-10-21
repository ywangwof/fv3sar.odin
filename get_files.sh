#!/bin/bash

VARDEFNS="$(realpath ${1-var_defns.sh})"
source ${VARDEFNS}

host_name=$(hostname)
if [[ $host_name =~ "stampede2" ]]; then
  machine="stampede"
elif [[ $host_name =~ "odin" ]]; then
  machine="odin"
else
  echo "ERROR: unsupported machine - $host_name"
  exit 0
fi

##---------------- Prepare Python environment --------------------------

case $machine in
    odin)
        read -r -d '' pythonstring <<- EOM
		source /scratch/software/Odin/python/anaconda2/etc/profile.d/conda.sh
		conda activate regional_workflow"
EOM
        ;;
    stampede)
        pythonstring="module load python3/3.7.0"
        ;;
    *)
        echo "ERROR: unsupported machine - $machine"
        usage 0
        ;;
esac

##@@@@@@@@@@@@@@@@@@@@@ Run shell script @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

CODEBASE="${HOMErrfs}"
WRKDIR="${LOGDIR}"

if [[ ! -d $WRKDIR ]]; then
  mkdir $WRKDIR
fi

cd $WRKDIR

#
# Step 1.  Get files for IC
#

jobscript="get_ics_files.sh"

read -r -d '' taskheader <<EOF
#!/bin/bash

${pythonstring}

export EXPTDIR=${EXPTDIR}

EOF

sed "1d" ${CODEBASE}/ush/wrappers/run_get_ics.sh > ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

chmod +x ${jobscript}

${jobscript} >& out.get_files_ics


#
# Step 2.  Get files for LBCs
#

jobscript="get_lbc_files.sh"

read -r -d '' taskheader <<EOF
#!/bin/bash

${pythonstring}

export EXPTDIR=${EXPTDIR}

EOF

sed "1d" ${CODEBASE}/ush/wrappers/run_get_lbcs.sh > ${jobscript}
echo "$taskheader" | cat - ${jobscript} > temp && mv temp ${jobscript}

chmod +x ${jobscript}

${jobscript} >& out.get_files_lbc

exit 0
