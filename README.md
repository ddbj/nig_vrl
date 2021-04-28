# NIG_VRL

## 1. git clone

```
git clone git@github.com:ddbj/nig_vrl.git && cd nig_vrl
```

## 2. setup 

TODO
```
bash setup.sh
```

### meta_vrl
### dfast_vrl 
Create singularity container 
```
singularity pull dfast_vrl:latest.sif docker://nigyta/dfast_vrl:latest
```
or
```
singularity pull dfast_vrl:1.2-0.3.sif docker://nigyta/dfast_vrl:1.2-0.3
```

Alternatively, the container file located in `/lustre6/public/vrl` can be used. 

### miniconda
### pangolin

## 3. env

### .env

### .bashrc
```
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/tf/repos/nig_vrl/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/tf/repos/nig_vrl/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/tf/repos/nig_vrl/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/tf/repos/nig_vrl/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
```

## 4. run sample 

* meta_vrl Input 
http://palaeo.nig.ac.jp/Resources/META_VRL/SRR10903401_1.fastq.gz
http://palaeo.nig.ac.jp/Resources/META_VRL/SRR10903401_2.fastq.gz

* Output
https://github.com/h-mori/meta_vrl/blob/main/SRR10903401_1.fastq.final.contigs.cleaned.2000.fa

* dfast_vrl Input  
https://github.com/h-mori/meta_vrl/blob/main/SRR10903401_1.fastq.final.contigs.cleaned.2000.fa (Output of meta_vrl)
https://raw.githubusercontent.com/nigyta/dfast_vrl/main/examples/metadata.txt  

* run dfast_vrl
```
singularity exec dfast_vrl:latest.sif dfast_vrl -i SRR10903401_1.fastq.final.contigs.cleaned.2000.f -m metadata.txt -o hCov-19_Japan_SZ-NIG-12345_2021 --isolate "hCov-19/Japan/SZ-NIG-12345/2021"
```
The FASTA file is the only mandatory parameter (-i), others are optional.
