# NIG_VRL

## 1. setup

gw.ddbj.nig.ac.jpにログイン後、pangolinやpythonスクリプト実行のために、メモリを割り当てて以下でqloginする。
```
qlogin -l mem_req=20G,s_vmem=20G
```

git clone後に移動して、meta_vrl, minimongo/pangolin, dfast_vrl実行環境構築用setup.sh スクリプトを実行する

```
git clone git@github.com:ddbj/nig_vrl.git && cd nig_vrl
bash setup.sh
```

## 2. run samples

以下、一般解析区画環境で動作を確認している

## meta_vrl_short_denovo
meta_vrl_short_denovoを実行し、$HOME/Testdirに結果を出力

```
mkdir $HOME/Testdir
qsub -l s_vmem=10G -l mem_req=10G -wd $HOME/Testdir -v ENVFILE=$PWD/meta_vrl/env_gw meta_vrl/meta_vrl_short_denovo/meta_vrl_short_denovo.sh /lustre6/public/reference/meta_vrl/SRR10903401_1.fastq /lustre6/public/reference/meta_vrl/SRR10903401_2.fastq $HOME/Testdir
```
https://github.com/h-mori/meta_vrl/tree/main/meta_vrl_short_denovo

### meta_vrl_short_map
meta_vrl_short_map.sh を実行し、$HOME/Testdir2に結果を出力

```
mkdir $HOME/Testdir2
qsub -l s_vmem=32G -l mem_req=32G -wd $HOME/Testdir2 -v ENVFILE=$PWD/meta_vrl/env_gw meta_vrl/meta_vrl_short_map/meta_vrl_short_map.sh /lustre6/public/reference/meta_vrl/SRR10903401_1.fastq /lustre6/public/reference/meta_vrl/SRR10903401_2.fastq $HOME/Testdir2
```
https://github.com/h-mori/meta_vrl/tree/main/meta_vrl_short_map

### meta_vrl_long_map
meta_vrl_long_map.sh を実行し、$HOME/Testdir3に結果を出力
```
mkdir $HOME/Testdir3
qsub -l s_vmem=100G -l mem_req=100G -wd $HOME/Testdir3 -v ENVFILE=$PWD/meta_vrl/env_gw meta_vrl/meta_vrl_long_map/meta_vrl_long_map.sh /lustre6/public/reference/meta_vrl/SP1-mapped.fastq /lustre6/public/reference/meta_vrl/SP1-fast5-mapped/ $HOME/Testdir3
```
https://github.com/h-mori/meta_vrl/tree/main/meta_vrl_long_map

### excel2dfast
excel2dfastで metadata.txt生成とjob_dfast_vrl.sh実行までの動作確認
* input: nig_vrl/ddbj_data_submission/dfast_sample_list.xlsx
* output: nig_vrl/ddbj_data_submission/metadata, nig_vrl/ddbj_data_submission/results
* logs: nig_vrl/ddbj_data_submission/logs

```
cd ddbj_data_submission
singularity exec -B /lustre6/private/vrl /usr/local/biotools/d/dram:1.2.0--py_0 python excel2dfast.py
qsub job_dfast_vrl.sh
```
TODO: input,output,logの出力先を現在のddbj_data_submission配下からのmeta_vrl入出力に合わせて最適化

https://github.com/ddbj/nig_vrl/tree/main/ddbj_data_submission

### pangolin

pangolin実行し、$HOME/Testdir4/SRR10903401_1.fastq.final.contigs.cleaned.2000.lineage_report.csv に結果出力

```
mongo activate pangolin
pangolin meta_vrl/SRR10903401_1.fastq.final.contigs.cleaned.2000.fa --outdir $HOME/Testdir4 --outfile SRR10903401_1.fastq.final.contigs.cleaned.2000.lineage_report.csv
mongo inactivate
```

## TODO
* コンテナやリファレンス置き場の整理と１次ソースからのhttps取得スクリプトを作成
* 個人ゲノム解析環境整備
* リファレンス配列の統一: Wuhan-Hu-1.fasta、NC_045512.2.fasta、...
* Isolate番号を利用してInput directory, Output directoryを整える

---
## 関連情報
### envfile
* リファレンスのパスやそのSINGULARITY_BINDPATH指定のために必要。meta_vrl_short_denovo, meta_vrl_short_map, meta_vrl_long_mapの環境変数を統合した。
   * 一般解析区画用env_gw: https://github.com/h-mori/meta_vrl/blob/tf/env_gw
   * 個人ゲノム解析区画用env_gwa: TODO

```
KRAKEN2REF=/lustre6/public/reference/meta_vrl/GRCh38.Wuhan
MINIMAP2REF=/lustre6/public/reference/meta_vrl/Wuhan-Hu-1.fasta
BWAREF=/lustre6/public/reference/meta_vrl/NC_045512.2.fasta
SINGULARITY_BINDPATH=/lustre6/public/reference/meta_vrl
```

### pangolin
```
# install
conda env create -f environment.yml
conda activate pangolin
python setup.py install
conda deactivate
    
# update
conda activate pangolin
pangolin --update

# execution
conda activate pangolin
pangolin input_fasta
```

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

* run dfast_vrl
```
singularity exec dfast_vrl:latest.sif dfast_vrl -i SRR10903401_1.fastq.final.contigs.cleaned.2000.f -m metadata.txt -o hCov-19_Japan_SZ-NIG-12345_2021 --isolate "hCov-19/Japan/SZ-NIG-12345/2021"
```
The FASTA file is the only mandatory parameter (-i), others are optional.

### 動作確認のためのサンプル情報
* meta_vrl_short_denovo, meta_vrl_short_map
   * Input 
http://palaeo.nig.ac.jp/Resources/META_VRL/SRR10903401_1.fastq.gz
http://palaeo.nig.ac.jp/Resources/META_VRL/SRR10903401_2.fastq.gz
   * Output
https://github.com/h-mori/meta_vrl/blob/main/SRR10903401_1.fastq.final.contigs.cleaned.2000.fa  

* dfast_vrl Input
https://github.com/h-mori/meta_vrl/blob/main/SRR10903401_1.fastq.final.contigs.cleaned.2000.fa (Output of meta_vrl)  
https://raw.githubusercontent.com/nigyta/dfast_vrl/main/examples/metadata.txt  


### singularity コンテナ実行時の注意  
コンテナ内から自ホームディレクトリ以外にあるファイルを参照する場合には、ディレクトリをコンテナにバインドする必要がある。  
`-B`オプションを指定するか、環境変数 `SINGULARITY_BINDPATH`を設定しておくこと。  
特に meta_vrl のジョブをqsubで実行する場合には、あらかじめ .bash_profile に

```
export SINGULARITY_BINDPATH="/lustre6/public/vrl"
```

のような形で記載してくとスクリプトを改変せずに実行できる。

## 6. 任意の時点での pangolin 参照データを使用する方法

pangolin v2.4 以降、以下の方法は使えないかも（確認中）

pangolin の conda 仮想環境を activateした 状態で下記を実行

```
$ pip install git+https://github.com/cov-lineages/pangoLEARN.git@2021-04-01
```
@以下の部分には https://github.com/cov-lineages/pangoLEARN/tags にあるタグ名を記載する。

使用しているバージョンの確認は
```
$ pangolin -pv                                                             
pangoLEARN 2021-04-01
```

元に戻す（最新バージョンにする)には
```
$ pangolin --update
```
を実行する。

pangolin 本体もアップデートされているので古いバージョンの参照データでは動作しない可能性がある。その場合には
```

```