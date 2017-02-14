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
reference=${ref_dir}/human_g1k_v37_decoy.fasta

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

echo GL,NC,hs37d5
cpus=0-3,8-11,16-19,24-27,32-35,40-43,48-51,56-59,64-67,72-75,80-83,88-91,96-99,104-107,112-115,120-123,128-131,136-139,144-147,152-155
tool_opt="-ERC GVCF --variant_index_type LINEAR --variant_index_parameter 128000"
chr=random_unplaced.intervals
input=${input_dir}/${sample}.recal_reads${chr}.bam
output=${input_dir}/${sample}.raw_variants${chr}.vcf
PHMM_N_THREADS=1 /usr/bin/time taskset -c ${cpus} java -jar ${gatk_dir}/GenomeAnalysisTK.jar -T HaplotypeCaller -nct 80 -L ${chr} -R ${ref_dir}/${reference} -I ${input} ${tool_opt} -o ${output} > ${output}.log-16 2>&1
echo 'done -> GL,NC,hs37d5'
