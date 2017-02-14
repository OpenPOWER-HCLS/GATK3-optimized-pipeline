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
targets := $(shell cat regions)
tool := PrintReads
step := .recal_reads
input := $(input_dir)/$(sample)$(sample_ext)
out_suffix := .bam
outputs := $(addsuffix $(out_suffix), $(addprefix $(input_dir)/$(sample)$(step), $(targets)))

nct := 4

cpusO := 32-127

all: $(outputs)

chr=$(subst ~~~,.intervals,$(subst $(step),,$(suffix $(notdir $(basename $(subst .intervals,~~~,$@))))))
input2=$(input_dir)/$(sample)$(step)$(chr).table
tool_opt=-BQSR $(input2) --filter_bases_not_stored
$(outputs):
	/usr/bin/time taskset -c $(cpusO) java -jar $(gatk_bin) -T $(tool) -L $(chr) -nct $(nct) -R $(reference) -I $(input) $(tool_opt) -o $@ > $@.log-$(nct) 2>&1

clean:
	rm -f $(outputs) $(input_dir)/$(sample)$(step)*.log-$(nct)
