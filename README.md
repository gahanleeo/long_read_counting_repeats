## counting repeat sequence in Long-read data

#README


## Short-tandem repeat genotyping using long reads ##
https://github.com/bcgsc/straglr


############################
# install conda in Biowulf##
############################

### install conda in your biowulf
 https://hpc.nih.gov/apps/python.html#envs

### go to desire folder, export TMPDIR
`export TMPDIR=/lscratch/$SLURM_JOB_ID`

### download conda to your folder
`wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh`
### install conda, -p is creating installed conda folder
`bash Mambaforge-Linux-x86_64.sh -p /data/$USER/conda -b`
### remove installation app
`rm Mambaforge-Linux-x86_64.sh`

### After sourcing the conda init file, activate the base environment and update the conda package manager which itself is just a package:

`source /data/$USER/conda/etc/profile.d/conda.sh && source /data/$USER/conda/etc/profile.d/mamba.sh`

### to make things easier you can create a file called `myconda` in a directory
### on your path such as ~/bin. This could be done like so (assuming the same
### paths as we used here).

``mkdir -p ~/bin``

```cat <<'__EOF__' > ~/bin/myconda```

```
__conda_setup="$('/data/$USER/conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/data/$USER/conda/etc/profile.d/conda.sh" ]; then
        . "/data/$USER/conda/etc/profile.d/conda.sh"
    else
        export PATH="/data/$USER/conda/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "/data/$USER/conda/etc/profile.d/mamba.sh" ]; then
    . "/data/$USER/conda/etc/profile.d/mamba.sh"
fi
__EOF__
```

### everytime you need to use conda, just type:
`source myconda`
# once done, can use conda funstion




########################################################
# install straglr using conda in Biowulf/own computer ##
########################################################


`git clone https://github.com/bcgsc/straglr.git`

### go to straglr folder
`cd straglr`
### use conda to install straglr
`conda env create --name straglr --file=environment.yaml`
`conda activate straglr`
### to see if it can excute, type
`./straglr.py`



######################
# Scoring Bam files #
#####################


# since it's bam file, it can score directly after finish
```
for i in *.bam
do
ff=`echo $i | sed 's/.sorted.bam//'`
straglr.py ${i} ~/Desktop/straglr_scoring_tool_for_long_read/toolinpus_and_HPRC_bams/hg38.fa ~/Desktop/straglr_scoring_tool_for_long_read/HPRC_pac_straglr_all_repeat_output/${ff} --loci ~/Desktop/straglr_scoring_tool_for_long_read/toolinpus_and_HPRC_bams/clp_target_hg38_3.bed \
 --max_str_len 100 #optional
echo "done ${ff}"
done
```

# after finshed, the .tsv file can be modify throug "adding_filename_and_combine_big.R" in R_script folder
# for genotyping, can use igvtoolcount.R in conda env called "igvtool_count_auto.R"
# enter env, activte rstudio through command, and use it


########################################################################################################################################################



######################################
## Oscar all fasta files per sample ##
######################################

# go to folder of bam files, use samtools to get all the read sequence from bam file.
```
for j in *
do
cd ${j}
ff=${j}
for i in *.bam
do
samtools view ${i} | awk '{print ">"$1 "\t" $10}' >> ~/Desktop/fasta_of_each/${ff}_all_fasta.txt
done
cat ~/Desktop/fasta_of_each/${ff}_all_fasta.txt |sort | uniq | tr '\t' '\n' > ~/Desktop/fasta_of_each/final.${ff}_all_fasta.txt
rm ~/Desktop/fasta_of_each/${ff}_all_fasta.txt
cd ..
done
```


####################################################################################################
#  set primer sets and measure the length of the in vitro PCR product to determine the repeat size #
####################################################################################################

# the other tool I found is pretty solid
https://github.com/egonozer/in_silico_pcr

# just download and use perl to excute


# The target sequence:
```
Repeat unit: 42 bp
T4_Forw_-->: ATGGGCAACCGGCGCAGCTGTGGCTATAGAAA
T4_Rev_--->: GGGGACCACGCCTCACTCCCTGCATAA

T4_Rev_with_<--- TTATGCAGGGAGTGAGGCGTGGTCCCC


Repeat unit: 35 bp
C3_Forw: CTTTGAACACACCCCCTGAG
C3_Rev: GGCAGCCTCTAGCAGAAAGT
```
########
```
perl in_silico_pcr-master/in_silico_PCR.pl -s input.fa -a ATGGGCAACCGGCGCAGCTGTGGCTATAGAAA -b TTATGCAGGGAGTGAGGCGTGGTCCCC -l 20000000 > output.txt
```
# output the result txt file, take avg of length, and divide 42bp
```
cat output.txt | awk 'NR>1' | awk '{total += $4} END {print total/NR/42}'
```
# make for loop and cat all the result
