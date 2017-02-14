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

# chromosomes 1-22 X Y
list=`cat regions`

# processor affinity table (i-th row includes 4 logical processors for main/worker0, worker[1-3] threads)
lpc18=(\
  0 1 8 9 \
  16 17 24 25 \
  32 33 34 35 \
  40 41 42 43 \
  48 49 50 51 \
  56 57 58 59 \
  64 65 66 67 \
  72 73 74 75 \
  80 81 82 83 \
  88 89 90 91 \
  96 97 98 99 \
  104 105 106 107 \
  112 113 114 115 \
  120 121 122 123 \
  128 129 130 131 \
  136 137 138 139 \
  144 145 146 147 \
  152 153 154 155)
lpc17=(\
  0 1 8 9 \
  16 17 24 25 \
  32 33 40 41 \
  48 49 50 51 \
  56 57 58 59 \
  64 65 66 67 \
  72 73 74 75 \
  80 81 82 83 \
  88 89 90 91 \
  96 97 98 99 \
  104 105 106 107 \
  112 113 114 115 \
  120 121 122 123 \
  128 129 130 131 \
  136 137 138 139 \
  144 145 146 147 \
  152 153 154 155)
lpc16=(\
  0 1 8 9 \
  16 17 24 25 \
  32 33 40 41 \
  48 49 56 57 \
  64 65 66 67 \
  72 73 74 75 \
  80 81 82 83 \
  88 89 90 91 \
  96 97 98 99 \
  104 105 106 107 \
  112 113 114 115 \
  120 121 122 123 \
  128 129 130 131 \
  136 137 138 139 \
  144 145 146 147 \
  152 153 154 155)
lpc15=(\
  0 1 8 9 \
  16 17 24 25 \
  32 33 40 41 \
  48 49 56 57 \
  64 65 72 73 \
  80 81 82 83 \
  88 89 90 91 \
  96 97 98 99 \
  104 105 106 107 \
  112 113 114 115 \
  120 121 122 123 \
  128 129 130 131 \
  136 137 138 139 \
  144 145 146 147 \
  152 153 154 155)
lpc14=(\
  0 1 8 9 \
  16 17 24 25 \
  32 33 40 41 \
  48 49 56 57 \
  64 65 72 73 \
  80 81 88 89 \
  96 97 98 99 \
  104 105 106 107 \
  112 113 114 115 \
  120 121 122 123 \
  128 129 130 131 \
  136 137 138 139 \
  144 145 146 147 \
  152 153 154 155)
lpc13=(\
  0  8  16 24 \
  32 33 40 41 \
  48 49 56 57 \
  64 65 72 73 \
  80 81 88 89 \
  96 97 98 99 \
  104 105 106 107 \
  112 113 114 115 \
  120 121 122 123 \
  128 129 130 131 \
  136 137 138 139 \
  144 145 146 147 \
  152 153 154 155)
lpc12=(\
  0  8  16 24 \
  32 40 48 56 \
  64 65 72 73 \
  80 81 88 89 \
  96 97 98 99 \
  104 105 106 107 \
  112 113 114 115 \
  120 121 122 123 \
  128 129 130 131 \
  136 137 138 139 \
  144 145 146 147 \
  152 153 154 155)
lpc11=(\
  0  8  16 24 \
  32 40 48 56 \
  64 65 72 73 \
  80 81 88 89 \
  96 97 104 105 \
  112 113 114 115 \
  120 121 122 123 \
  128 129 130 131 \
  136 137 138 139 \
  144 145 146 147 \
  152 153 154 155)
lpc10=(\
  0  8  16 24 \
  32 40 48 56 \
  64 65 72 73 \
  80 81 88 89 \
  96 97 104 105 \
  112 113 120 121 \
  128 129 130 131 \
  136 137 138 139 \
  144 145 146 147 \
  152 153 154 155)
lpc9=(\
  0  8  16 24 \
  32 40 48 56 \
  64 65 72 73 \
  80 81 88 89 \
  96 97 104 105 \
  112 113 120 121 \
  128 129 136 137 \
  144 145 146 147 \
  152 153 154 155)
lpc8=(\
  0  8  16 24 \
  32 40 48 56 \
  64 65 72 73 \
  80 81 88 89 \
  96 97 104 105 \
  112 113 120 121 \
  128 129 136 137 \
  144 145 152 153)
lpc7=(\
  0  8  16 24 \
  32 40 48 56 \
  64 72 80 88 \
  96 97 104 105 \
  112 113 120 121 \
  128 129 136 137 \
  144 145 152 153)
lpc6=(\
  0  8  16 24 \
  32 40 48 56 \
  64 72 80 88 \
  96 104 112 120 \
  128 129 136 137 \
  144 145 152 153)
lpc5=(\
  0  8  16 24 \
  32 40 48 56 \
  64 72 80 88 \
  96 104 112 120 \
  128 136 144 152 )
lpc4=(\
  0  8  16 24 \
  32 40 48 56 \
  64 72 80 88 \
  96 104 112 120)
lpc3=(\
  0  8  16 24 \
  32 40 48 56 \
  64 72 80 88)
lpc2=(\
  0  8  16 24 \
  32 40 48 56)
lpc1=(\
  0  8  16 24)

# default logical processors (0-31 not used to use core0-3 as high-priority cores 
# by running all of GC threads on cores except core0-3)
nbnd_cpu=32-159

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
  "18" ) lpc=("${lpc18[@]}") ;;
  "17" ) lpc=("${lpc17[@]}") ;;
  "16" ) lpc=("${lpc16[@]}") ;;
  "15" ) lpc=("${lpc15[@]}") ;;
  "14" ) lpc=("${lpc14[@]}") ;;
  "13" ) lpc=("${lpc13[@]}") ;;
  "12" ) lpc=("${lpc12[@]}") ;;
  "11" ) lpc=("${lpc11[@]}") ;;
  "10" ) lpc=("${lpc10[@]}") ;;
  "9" ) lpc=("${lpc9[@]}") ;;
  "8" ) lpc=("${lpc8[@]}") ;;
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
    i0=$(( $i * 4 ))
    g=`pgrep -f '^java.* -L '${sort[$i]}' '`
    t5=(`ps --pid ${g} -Lo pid,tid,%cpu,etimes | gawk '{if($3>5 && $3<=50){print $2}}'`)
    t50=(`ps --pid ${g} -Lo pid,tid,%cpu,etimes | gawk '{if($3>50){print $2}}'`)
    # restore affinity (in particular, for GC threads that were bound to lpc by error)
    taskset -apc ${nbnd_cpu} ${g} >& /dev/null
    # bind main thread to lpc[0]
    echo chr ${sort[$i]} t5[0] taskset -pc ${lpc[${i0}]} ${t5[0]}
    taskset -pc ${lpc[${i0}]} ${t5[0]} >& /dev/null
    # bind worker threads 0-3 to lpc[0-3]
    for ((j=0; j<=3; j++)); do
      i1=$(( $i * 4 + $j ))
      echo chr ${sort[$i]} t50[$j] taskset -pc ${lpc[$i1]} ${t50[$j]}
      taskset -pc ${lpc[$i1]} ${t50[$j]} >& /dev/null
    done
  done
  echo "*** sleep 30 ***"
  sleep 30
done
