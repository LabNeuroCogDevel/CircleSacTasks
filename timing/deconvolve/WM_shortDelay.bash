#!/usr/bin/env bash

i=$1 
[ -z "$i" ] && echo "no interation number; need as first argument" && exit 1

3dDeconvolve\
   -nodata 240 1.5\
   -polort 4\
   -x1D shortDelay.X.xmat.1D \
   -num_stimts 8\
   -stim_times 1 ../workingMemory_shortDelay/stims/$i/snd.1D 'BLOCK(0.2,1)'\
   -stim_label 1 snd\
   -stim_times 2 ../workingMemory_shortDelay/stims/$i/RSP:change.1D 'BLOCK(2,1)'\
   -stim_label 2 RSP:change\
   -stim_times 3 ../workingMemory_shortDelay/stims/$i/mem:L4.1D 'BLOCK(0.2,1)'\
   -stim_label 3 mem:L4\
   -stim_times 4 ../workingMemory_shortDelay/stims/$i/mem:L1.1D 'BLOCK(0.2,1)'\
   -stim_label 4 mem:L1\
   -stim_times 5 ../workingMemory_shortDelay/stims/$i/snd::isi::mem:L1::dly:short.1D 'BLOCK(1,1)'\
   -stim_label 5 L1:dly:short\
   -stim_times 6 ../workingMemory_shortDelay/stims/$i/isi.1D 'BLOCK(0.37,1)'\
   -stim_label 6 isi\
   -stim_times 7 ../workingMemory_shortDelay/stims/$i/RSP:nochange.1D 'BLOCK(2,1)'\
   -stim_label 7 RSP:nochange\
   -stim_times 8 ../workingMemory_shortDelay/stims/$i/snd::isi::mem:L4::dly:short.1D 'BLOCK(1,1)'\
   -stim_label 8 L4:dly:short\
   -num_glt 8\
   -gltsym 'SYM:  +mem:L1 +mem:L4' \
   -glt_label 1 mem\
   \
   -gltsym 'SYM:  +mem:L4 -mem:L1' \
   -glt_label 2 mem:L4-mem:L1\
   \
   -gltsym 'SYM:  +.5*L1:dly:short +.5*L4:dly:short ' \
   -glt_label 3 dly\
   \
   -gltsym 'SYM:  -.5*L1:dly:short +.5*L4:dly:short' \
   -glt_label 4 dlyL4-L1 \
   \
   -gltsym 'SYM:  +mem:L1 +mem:L4 -snd' \
   -glt_label 5 mem-snd\
   \
   -gltsym 'SYM:  +mem:L1 +mem:L4 -RSP:change -RSP:nochange' \
   -glt_label 6 mem-RSP \
   \
   -gltsym 'SYM:  -.5*L1:dly:short -.5*L4:dly:short +.5*RSP:change +.5*RSP:nochange' \
   -glt_label 7 RSP-dly \
   \
   -gltsym 'SYM:  -.5*mem:L1 -.5*mem:L4   +.5*L1:dly:short +.5*L4:dly:short' \
   -glt_label 8 dly-mem  \

