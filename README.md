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
 
