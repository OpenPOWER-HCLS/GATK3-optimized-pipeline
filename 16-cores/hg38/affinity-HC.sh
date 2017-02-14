#!/bin/bash
# (C) Copyright IBM Corp. 2017
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

#log file prefix=data/Solexa-272221.recal_
prefix=$1
#log file postfix=.table.log-4
postfix=$2

ncore=16

# chromosomes 1-22 X Y
list=`cat regions`

# processor affinity table (i-th row includes 4 logical processors for main/worker0, worker[1-3] threads)
lpc7=(\
  0  1  8  9  16 17  24  25  32  33  40  41  48  49  56  57 \
  2  3  10 11 18 19  26  27  34  35  42  43  50  51  58  59 \
  4  5  12 13 20 21  28  29  36  37  44  44  52  53  60  61 \
  64 65 72 73 80 81  88  89  96  97 104 105 112 113 120 121 \
  66 67 74 75 82 83  90  91  98  99 106 107 114 115 122 123 \
  68 69 76 77 84 85  92  93 100 101 108 109 116 117 124 125 \
  70 71 78 79 86 87  94  95 102 103 110 111 118 119 126 127 )
lpc6=(\
  0  1  8  9  16 17  24  25  32  33  40  41  48  49  56  57 \
  2  3  10 11 18 19  26  27  34  35  42  43  50  51  58  59 \
  4  5  12 13 20 21  28  29  36  37  44  44  52  53  60  61 \
  64 65 72 73 80 81  88  89  96  97 104 105 112 113 120 121 \
  66 67 74 75 82 83  90  91  98  99 106 107 114 115 122 123 \
  68 69 76 77 84 85  92  93 100 101 108 109 116 117 124 125)
lpc5=(\
  0  1  8  9  16 17  24  25  32  33  40  41  48  49  56  57 \
  2  3  10 11 18 19  26  27  34  35  42  43  50  51  58  59 \
  64 65 72 73 80 81  88  89  96  97 104 105 112 113 120 121 \
  66 67 74 75 82 83  90  91  98  99 106 107 114 115 122 123 \
  68 69 76 77 84 85  92  93 100 101 108 109 116 117 124 125)
lpc4=(\
  0  1  8  9  16 17  24  25  32  33  40  41  48  49  56  57 \
  64 65 72 73 80 81  88  89  96  97 104 105 112 113 120 121 \
  66 67 74 75 82 83  90  91  98  99 106 107 114 115 122 123 \
  68 69 76 77 84 85  92  93 100 101 108 109 116 117 124 125)
lpc3=(\
  0  1  8  9  16 17  24  25  32  33  40  41  48  49  56  57 \
  64 65 72 73 80 81  88  89  96  97 104 105 112 113 120 121 \
  66 67 74 75 82 83  90  91  98  99 106 107 114 115 122 123)
lpc2=(\
  0  1  8  9  16 17  24  25  32  33  40  41  48  49  56  57 \
  64 65 72 73 80 81  88  89  96  97 104 105 112 113 120 121)
lpc1=(\
  0  8  16 24  32  40  48  56  64  72  80 88 96 104 112 120)

# default logical processors (0-31 not used to use core0-3 as high-priority cores 
# by running all of GC threads on cores except core0-3)
nbnd_cpu=32-127

while :
do
  chr=()
  tim=()
  # obtain the remaining time for each chromosome
  for v in ${list[@]}; do
    f=${prefix}${v}${postfix}
    if [ -f ${f} ]; then
      t=`tail -c 120000 $f | egrep 'INFO.*%|INFO.*Total' | tail -n1 | grep -v 'INFO.*Total'| gawk '{if($15=="d"){sec=$14*24*3600}else if($15=="h"){sec=$14*3600}else if($15=="m"){sec=$14*60}else{sec=$14};print sec}'`
      echo "f:"$f" v:"$v" t:"$t
      if [ "$t" != "" ]; then
        chr+=( $v )
        tim+=( $t )
      fi
    fi
  done
  # sort chromosomes by the remaining time
  s=$(for (( i=0; i<${#chr[@]}; i++ )); do \
    echo ${chr[$i]} ${tim[$i]}; \
  done \
  | sort -k2,2nr | gawk '{print $1}')
  sort=(`echo $s`)
echo sort= ${sort[@]} N ${#sort[@]}
  case "${#sort[@]}" in
  "7" ) lpc=("${lpc7[@]}") ;;
  "6" ) lpc=("${lpc6[@]}") ;;
  "5" ) lpc=("${lpc5[@]}") ;;
  "4" ) lpc=("${lpc4[@]}") ;;
  "3" ) lpc=("${lpc3[@]}") ;;
  "2" ) lpc=("${lpc2[@]}") ;;
  "1" ) lpc=("${lpc1[@]}") ;;
  esac
echo lpc= ${lpc[@]}
  # bind threads for chromosomes to lpc
  for (( i=0; i<${#sort[@]}; i++ )); do
    cpus=
    i0=$(( $i * ${ncore} ))
    g=`pgrep -f '^java.* -L '${sort[$i]}' '`
    for ((j=0; j<${ncore}; j++)); do
      i1=$(( $i * ${ncore} + $j ))
      if [ "$cpus" = "" ]; then
        cpus=${lpc[$i1]}
      else
        cpus=$cpus","${lpc[$i1]}
      fi
    done
echo taskset -apc ${cpus} ${g}
    taskset -apc ${cpus} ${g}
  done
  echo "*** sleep 30 ***"
  sleep 30
done
