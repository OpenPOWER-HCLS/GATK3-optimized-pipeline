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
sample=Solexa-272221

input_dir=./data
gatk_dir=.
ref_dir=.
reference=${ref_dir}/Homo_sapiens_assembly38.fasta

export JAVA_TOOL_OPTIONS="-Xmn18g -Xms21g -Xmx21g -XX:ParallelGCThreads=16 -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+AggressiveOpts -Djava.library.path=."
if [ -e libVectorLoglessPairHMM.so ]; then
  echo "OK: vector pairHMM lib"
else
  echo "Cannot find vector pairHMM lib"
  exit -1
fi
./affinity-HC.sh ${input_dir}/${sample}.raw_variants .vcf.log-16 >& affinity-HC.log &
ts=$!
make reference=${reference} gatk_dir=${gatk_dir} ref_dir=${ref_dir} input_dir=${input_dir} sample=${sample} -j7 -f runHC.mk
kill ${ts}
