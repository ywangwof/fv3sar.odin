To run FV3SAR forecast on Odin/Stampede that replaces Rocoto

Step 0: Edit file config.sh following instructions on Google drive, Community Workflow Instruction,
        https://docs.google.com/document/d/1vVIge70v6Em1imsfbXEx_N0mcfU_QtghZy5AaPKwIuA/edit

Step 1: run ush/generate_FV3SAR_wflow.sh
        and link/copy ${EXPTDIR}/var_defns.sh to the script directory

Step 2: Stage exernal model files
        $> `get_files.sh var_defns.sh`

Step 3: run run_fv3lam.sh following these steps one by one

    3.1: `run_fv3lam.sh -r grid var_defns.sh`
    3.2: `run_fv3lam.sh -r orog var_defns.sh`
    3.3: `run_fv3lam.sh -r sfc  var_defns.sh`
    3.4: `run_fv3lam.sh -r ics  var_defns.sh`
    3.5: `run_fv3lam.sh -r lbc  var_defns.sh`
    3.6: `run_fv3lam.sh -r fcst var_defns.sh`
    3.7: `run_fv3lam.sh -r post var_defns.sh`

Note: Step 3.1 - 3.7 will generate job script (SLURM) and then submit the job.
      Step 0, 1 and 2 will run the scripts on the front node.
