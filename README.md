# NIG_VRL

## 1. git clone

```
git clone git@github.com:ddbj/nig_vrl.git && cd nig_vrl
```

## 2. setup 

```
bash setup.sh
```

* meta_vrl
* TODO
  * miniconda/pangolin
* dfast_vrl 


Create singularity container 
```
singularity pull dfast_vrl:latest.sif docker://nigyta/dfast_vrl:latest
```
or
```
singularity pull dfast_vrl:1.2-0.3.sif docker://nigyta/dfast_vrl:1.2-0.3
```
Alternatively, the container file located in `/lustre6/public/vrl` can be used. 


## 3. env
### 一般解析区画用 env_gw

#### meta_vrl_short_denovo
```
#KRAKEN2REF=/home/hoge/META_VRL/GRCh38.Wuhan
#MINIMAP2REF=/home/hoge/META_VRL/WuHan.fasta
KRAKEN2REF=/lustre6/public/reference/meta_vrl/GRCh38.Wuhan
MINIMAP2REF=/lustre6/public/reference/meta_vrl/Wuhan-Hu-1.fasta
SINGULARITY_BINDPATH=/lustre6/public/reference/meta_vrl
```
#### meta_vrl_short_map, meta_vrl_long_map
```
#BWAREF=/home/hoge/META_VRL/NC_045512.2.fasta
BWAREF=/lustre6/public/reference/meta_vrl/NC_045512.2.fasta
```

## 4. run sample 

### 一般解析区画環境

* meta_vrl_short_denovoを実行し、$HOME/Testdirに結果を出力

```
mkdir $HOME/Testdir
qsub -l s_vmem=10G -l mem_req=10G -wd $HOME/Testdir -v ENVFILE=$PWD/meta_vrl/env_gw meta_vrl/meta_vrl_short_denovo/meta_vrl_short_denovo.sh /lustre6/public/reference/meta_vrl/SRR10903401_1.fastq /lustre6/public/reference/meta_vrl/SRR10903401_2.fastq $HOME/Testdir
```

https://github.com/h-mori/meta_vrl/tree/main/meta_vrl_short_denovo

* meta_vrl_short_map.sh を実行し、$HOME/Testdir2に結果を出力

```
mkdir $HOME/Testdir2
qsub -l s_vmem=32G -l mem_req=32G -wd $HOME/Testdir2 -v ENVFILE=$PWD/meta_vrl/env_gw meta_vrl/meta_vrl_short_map/meta_vrl_short_map.sh /lustre6/public/reference/meta_vrl/SRR10903401_1.fastq /lustre6/public/reference/meta_vrl/SRR10903401_2.fastq $HOME/Testdir2
```

https://github.com/h-mori/meta_vrl/tree/main/meta_vrl_short_map

* meta_vrl_long_map.sh を実行し、$HOME/Testdir3に結果を出力
```
mkdir $HOME/Testdir3
qsub -l s_vmem=100G -l mem_req=100G -wd $HOME/Testdir3 -v ENVFILE=$PWD/meta_vrl/env_gw meta_vrl/meta_vrl_long_map/meta_vrl_long_map.sh /lustre6/public/reference/meta_vrl/SP1-mapped.fastq /lustre6/public/reference/meta_vrl/SP1-fast5-mapped/ $HOME/Testdir3
```

https://github.com/h-mori/meta_vrl/tree/main/meta_vrl_long_map

* TODO: excel2dfastで metadata.txt生成とjob_dfast_vrl.sh実行までの動作確認（現在のinput,outputはddbj_data_submission配下を想定 
   * input: nig_vrl/ddbj_data_submission/dfast_sample_list.xlsx
   * output: nig_vrl/ddbj_data_submission/metadata, nig_vrl/ddbj_data_submission/results

```
cd ddbj_data_submission
singularity exec -B /lustre6/private/vrl /usr/local/biotools/d/dram:1.2.0--py_0 python excel2dfast.py
qsub job_dfast_vrl.sh
```

ddbj_data_submission/logs
```
Running command: singularity exec /lustre6/public/vrl/dfast_vrl:1.2-0.2.sif dfast_vrl -i ../dfast_vrl/examples/SRR10903401.meta_vrl.contig.fa -m metadata/hCov-19_Japan_SZ-NIG-2_2021.metadata.txt -o results/hCov-19_Japan_SZ-NIG-2_2021 --force
Running command: singularity exec /lustre6/public/vrl/dfast_vrl:1.2-0.2.sif dfast_vrl -i ../dfast_vrl/examples/test_chimeric.fa -m metadata/hCov-19_Japan_SZ-NIG-3_2021.metadata.txt -o results/hCov-19_Japan_SZ-NIG-3_2021 --force
FATAL:   could not open image /lustre6/public/vrl/dfast_vrl:1.2-0.2.sif: failed to retrieve path for /lustre6/public/vrl/dfast_vrl:1.2-0.2.sif: lstat /lustre6/public/vrl/dfast_vrl:1.2-0.2.sif: no such file or directory
FATAL:   could not open image /lustre6/public/vrl/dfast_vrl:1.2-0.2.sif: failed to retrieve path for /lustre6/public/vrl/dfast_vrl:1.2-0.2.sif: lstat /lustre6/public/vrl/dfast_vrl:1.2-0.2.sif: no such file or directory
Running command: singularity exec /lustre6/public/vrl/dfast_vrl:1.2-0.2.sif dfast_vrl -i ../dfast_vrl/examples/LC570964-6.draft.contigs.fa -m metadata/hCov-19_Japan_SZ-NIG-1_2021.metadata.txt -o results/hCov-19_Japan_SZ-NIG-1_2021 --force
FATAL:   could not open image /lustre6/public/vrl/dfast_vrl:1.2-0.2.sif: failed to retrieve path for /lustre6/public/vrl/dfast_vrl:1.2-0.2.sif: lstat /lustre6/public/vrl/dfast_vrl:1.2-0.2.sif: no such file or directory
```

https://github.com/ddbj/nig_vrl/tree/main/ddbj_data_submission



---
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


## 5. singularity コンテナ実行時の注意  
コンテナ内から自ホームディレクトリ以外にあるファイルを参照する場合には、ディレクトリをコンテナにバインドする必要がある。  
`-B`オプションを指定するか、環境変数 `SINGULARITY_BINDPATH`を設定しておくこと。  
特に meta_vrl のジョブをqsubで実行する場合には、あらかじめ .bash_profile に

```
export SINGULARITY_BINDPATH="/lustre6/public/vrl"
```

のような形で記載してくとスクリプトを改変せずに実行できる。
