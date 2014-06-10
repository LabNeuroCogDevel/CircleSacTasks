#!/usr/bin/env bash

# 20 mins: 1200 seconds
# stims: button+spin=anticipation, win or nowin

set -xe


runTime=300                  # length of run:  5min*60sec/min (was too long, 20min*60sec/min)
TR=1.5                       # t_r, MRI setting
nTR=$(echo $runTime/$TR| bc) # number of TRs  # 200 TRs 

avgRT=.5      # how long does it take to resond
CATime=1      # duration of cue+attention
cueTime=.5    # just duration of cue 

CA_avgRT=$(echo $avgRT+$CATime|bc -l)

# parameters to test
nIts=200      # how many random timings to genereate to test a condition
maxCatch=20   # start at 0, go up by 5, to this number
meanITI=4     # time we want for ISI AND ITI (not actually set here, for loop iteratated)

# clear previous run
[ -d stims ] && mv stims stims.$(date +"%F_%H:%M")
mkdir stims
# start new record of each iteration
#        sum root mean square of the measurement error variance for each condition (minimize)
#        general linear test (Ward 1998 http://afni.nimh.nih.gov/pub/dist/doc/manual/3dDeconvolve.pdf pg43,82-88)
#           normalized variance-covariance matrix (X'X)^-1, lower=more power: Pr(Z>k - \theta/(s*d) ) -- d is our meassure
#        correlation between each regressor (minimize)
allinfo=info.txt
echo "it nTrial nEach nCatch RMSerror.cue RMSerror.attention RMSerror.LL RMSerror.RL RMSerror.LR RMSerror.RR GLT.c-a GLT.a-p GLT.la-ra GLT.al-ar GLT.cog-incog r.LL r.RL r.LR r.RR"|tee $allinfo

#for n_ea_posdir in 15 20 25; do
for meanITI in 3 4 5; do
 for nCatch in $(seq 4 4 $maxCatch); do
  possible=1 # might have some combination of settings that is not possible

  for i in $(seq 1 $nIts); do
    [ $possible -eq 0 ] && continue

    # total number of trials  # bc floors division
    # = time for actual trials                    / length of trial
    # = ( (endtime-last iti) - timeForCatches     /(CueAtten+RT+ITI)
    #
    # NB CATiem+CueTime are the 2 catch trials -- represented equally
    nTrials=$(echo "(($runTime-(12-$meanITI)) - (($CATime+$cueTime)*$nCatch)/2  )/($CATime+$avgRT+$meanITI) "|bc ) 
    n_ea_posdir=$(echo $nTrials/4|bc)
    


    # name for this iteration: #trials #each_stim #catch  #iteration
    ii=t$(printf %02d $nTrials)_e$(printf %02d $n_ea_posdir )_c$(printf %02d $nCatch)_$(printf %04d $i)

    # each posDir occurs equally
    # but maybe congruent/incongruent is the only thing thats important?
    nLL=$n_ea_posdir; nLR=$n_ea_posdir; nRL=$n_ea_posdir; nRR=$n_ea_posdir;

    nCue=$(echo $nCatch/2 | bc )

    nCA=$(echo "4*$n_ea_posdir + $nCatch/2"|bc) # not used 
    ntoteach=$(echo "$n_ea_posdir*4" |bc)       # not used


    echo "$nCatch = $nCue/2;  $nTrials trails $n_ea_posdir ea $ntoteach total"
    

    # make random timing using afni's python2 script
    # presentation is 
    #    (1) cue+attention+response -> NXTTRL
    #        .5s+.5s              +RT
    #    (1) cue            -> NXTTRL
    #        .5
    #    (1) cue+attention  -> NXTTRL
    #         1
    #
    # catch trials can be cue or cueAtten that is not followed by a posDir (eg leftLeft)
    #
    python2 $(which make_random_timing.py) -num_runs 1 -run_time $runTime  \
          -tr $TR \
          -num_stim 6  \
          -stim_labels cue      cueAtten CAleftLeft CAleftRight CArightRight CArightLeft\
          -num_reps    $nCue    $nCue     $nLL        $nLR         $nRR          $nRL \
          -stim_dur    $cueTime $CATime   $CA_avgRT   $CA_avgRT    $CA_avgRT     $CA_avgRT \
          -pre_stim_rest 0 -post_stim_rest 12           \
          -min_rest 2 -max_rest 8                       \
          -show_timing_stats -prefix stims/${ii}_stimes \
          #> stims/${ii}.makerandtimelog 2>&1 
          #-make_3dd_contrasts -save_3dd_cmd testwith3dd.tsch                 \
          #-min_rest 2 -max_rest 8 
          #  -seed 31415
    
    if [ $? -ne 0 ]; then echo "impossible combination: ${n_ea_posdir}e ${nCatch}c  ${nTrials}t " 1>&2; possible=0; continue; fi 
    # combine all the spins, as these are not different stims
    # (specifiying them as different allowed us to enfoce an order)
    ## perl -lne 'print sprintf("%.02f",$&) while(/\d+\.?\d*/g)' stims/${ii}_stimes_*spin*1D | \
    ##    sort -n | tr '\n' ' ' \
    ##    > stims/${ii}_stimes_slotstart.1D 
    # written easier as
    # timing_.py -timing stims/${ii}_stims_01*spin*1D \
    #            -extend stims/${ii}_stims_02*spin*1D \
    #            -extend stims/${ii}_stims_03*spin*1D \
    #            -sort -write_timing stims/${ii}_stims_spin.1D
    

    # use R to get timing into a dataframe
    # marry duration (ISI) to spin duration to get anticipation block
    Rscript -e "source('timingFromAfni.R'); write1Ds(getStimTime('$ii'),'$ii');"

    # run hrf through afni without any data
    # generates:
    #  design matrix (*.xmat)
    #  measurement error variance
    #  general linear tests
    3dDeconvolve                                           \
          -nodata $nTR $TR                                \
          -polort 9                                        \
          -num_stimts 6                                    \
          -stim_times 1 stims/${ii}_cue.1D 'BLOCK(1,1)' \
          -stim_label 1 cue                               \
          -stim_times 2 stims/${ii}_attention.1D 'BLOCK(1,1)' \
          -stim_label 2 attention                             \
          -stim_times 3 stims/${ii}_leftLeft.1D 'BLOCK(1,1)' \
          -stim_label 3 leftLeft                             \
          -stim_times 4 stims/${ii}_rightLeft.1D 'BLOCK(1,1)' \
          -stim_label 4 rightLeft                             \
          -stim_times 5 stims/${ii}_leftRight.1D 'BLOCK(1,1)' \
          -stim_label 5 leftRight                             \
          -stim_times 6 stims/${ii}_rightRight.1D 'BLOCK(1,1)' \
          -stim_label 6 rightRight                             \
          -num_glt 5                                           \
          -gltsym "SYM: cue -attention"                                           -glt_label 1 cue_attention  \
          -gltsym "SYM: attention -leftLeft -leftRight -rightLeft -rightRight" -glt_label 2 attention_Probe  \
          -gltsym "SYM: leftLeft +leftRight -rightLeft -rightRight"             -glt_label 3 leftAll_rightAll  \
          -gltsym "SYM: leftLeft +rightLeft -leftRight -rightRight"             -glt_label 4 allLeft_allRight\
          -gltsym "SYM: leftRight +rightLeft -leftLeft -rightRight"             -glt_label 5 cong_ingcong\
          -x1D stims/${ii}_X.xmat.1D   >  stims/${ii}.3ddlog 2>&1
          #-stim_times 1 stims/${ii}_stimes_spin.1D 'GAM' \
          #-stim_label 1 spin                               \
          #-stim_times 2 stims/${ii}_stimes_*_win.1D 'BLOCK(1.5,1)'     \
          # -stim_times 3 stims/${ii}_stimes_*nowin 'BLOCK(1.5,1)'    \
    
    ## ISI distribution
    #python2 $(which timing_tool.py) -multi_show_isi_stats \
    #                                -multi_stim_dur 1 1.5 1.5 \
    #                                -run_len 1200  \
    #                                -multi_timing stims/${ii}_stimes_{spin,*_win,*_nowin}.1D \
    #    >  stims/${ii}.info
        
    # correlation between regressors
    python2 $(which 1d_tool.py) -cormat_cutoff 0 -show_cormat_warnings -infile stims/${ii}_X.xmat.1D  \
        >> stims/${ii}.info

    # output the h (RMSvarErr) and LC (gen lin test) values from .3ddlog 
    # and the correlation ($F[1]) from anticipation vs (no)win from .info
    # space delminted
    #echo "it nTrial nEach nCatch RMSerror.cue RMSerror.attention RMSerror.LL RMSerror.RL RMSerror.LR RMSerror.RR GLT.c-a GLT.a-p GLT.la-ra GLT.al-ar GLT.cog-incog r.LL r.RL r.LR r.RR|tee $allinfo
    echo $i $nTrials $ntoteach $nCatch $(perl -ne \
        'push @a,$2 if m/.*(h|LC)\[.*norm. std. dev. = *(\d+.\d+)/; END{print join(" ",map(sprintf("%.05f",$_), @a))}'\
          stims/${ii}.3ddlog
     ) $(perl -slane  \
        '$a{$1}=$F[1] if m/attention.* (.*?(eft|ight).+)#\d/;END{print join(" ",@a{qw/leftLeft rightLeft leftRight rightRight/})}' \
          stims/${ii}.info
     ) |tee -a $allinfo

     # perl -slane '$a{"${1}_${2}"}=$F[1] if m/(\w+)#\d  vs.  (\w+)#\d/;END{print join(" ",@a{qw/cue_attention leftLeft_leftRight/})}' stims/*info

    
    ##sum regressor should be zero at some point (according to make_random_stimes.py)
    #1dplot -xlabel Time stims/${ii}_X.xmat.1D'[10]' -ylabel sum
    ##view the whole thing
    #1dplot -sep_scl stims/${ii}_X.xmat.1D
    #1dgrayplot -sep stims/${ii}_X.xmat.1D 
    #
  done
 done
done
#done
