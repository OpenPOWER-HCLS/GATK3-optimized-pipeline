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
gatk_bin := $(gatk_dir)/GenomeAnalysisTK.jar
targets := $(shell cat regions | grep -v random_unplaced.intervals)
tool := HaplotypeCaller
tool_opt := -ERC GVCF --variant_index_type LINEAR --variant_index_parameter 128000
step := .raw_variants
out_suffix := .vcf
outputs := $(addsuffix $(out_suffix), $(addprefix $(input_dir)/$(sample)$(step), $(targets)))

nt = 1
nct = 20

all: $(outputs)

chr=$(subst ~~~,.intervals,$(subst $(step),,$(suffix $(notdir $(basename $(subst .intervals,~~~,$@))))))
input=$(input_dir)/$(sample).recal_reads$(chr).bam
$(outputs):
	PHMM_N_THREADS=$(nt) /usr/bin/time java -jar $(gatk_bin) -T $(tool) -nct $(nct) -L $(chr) -R $(reference) -I $(input) $(tool_opt) -o $@ > $@.log-16 2>&1

clean:
	rm -f $(outputs) $(input_dir)/$(sample)$(step)*.log-$(nt)
