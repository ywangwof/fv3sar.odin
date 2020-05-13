## To run FV3SAR forecast on Odin/Stampede that replaces Rocoto

> Step 0: Edit file config.sh following instructions on Google drive, Community Workflow Instruction,
>        https://docs.google.com/document/d/1vVIge70v6Em1imsfbXEx_N0mcfU_QtghZy5AaPKwIuA/edit
>
> Step 1: run ush/generate_FV3SAR_wflow.sh
>        and link/copy ${EXPTDIR}/var_defns.sh to the script directory 
>
> Step 2: run_grid.sh
>
> Step 3: run_orog.sh
>
> Step 4: run_sfc.sh
>
> Step 5: get_files.sh
>
> Step 6: run_ics.sh
>
> Step 7: run_lbc.sh
>
> Step 8: run_fv3sar.sh
>
> Step 9: run_post.sh
>
**Note**: Step 2-4, 6-8 will generate job script (SLURM) and then submit the job. Step 0,1,5 will run the scripts on the front node. Step 9 will hold the script to wait for forecast files (*dynf???.nc* & *phyf???.nc*) and submit a UPP job as forecast files are available at one specific forecast hour.
