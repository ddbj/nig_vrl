# conda環境でMETA_VRL_LONG_MAPを実行する方法
1. 概要  
    conda環境で必要なツールをインストールし、META_VRL_LONGを実行する手順を記す。実行スクリプトは [meta_vrl_long_map_conda.sh](meta_vrl_long_map_conda.sh)  
    マッピング(minimap 2.17)および変異同定(medaka 1.3.2)は [meta_vrl_long_map.sh](meta_vrl_long_map.sh) で用いられているものと同じバージョンを指定しているが、それ以外のsamtools、BEDtools等に関してはバージョンの指定は行っていない。また、bamutils (NGSutils) はPython2.7環境でしか動かないため、`meta_vrl_long_map_conda.sh`においては、BEDtoolsとin-houseのawkスクリプトを組み合わせて同等の処理を行っている。  
    Linuxでの動作を確認済み(Macではツールのインストールに失敗したため、動作未確認)。

1. 実行環境の準備  
    anaconda/minicondaはあらかじめインストールが済んでいることとする。  
    git clone後、nig_vrl/meta_vrl_long_mapディレクトリに移動。下記を実行して仮想conda環境を作成しツールのインストールを行う。  
    ```
    conda env create --file conda_environment.yml
    ```
    上記コマンドでは`meta_vrl_long_map`という名称のconda環境を作成してツールのインストールを行っている。仮想環境の名称を自分で指定する場合には、
    ```
    conda env create -n your_env --file conda_environment.yml
    ```
    とする。  
    インストール後、
    ```
    conda activate meta_vrl_long_map
    ```
    を実行して仮想環境を有効化する。


1. 実行  
    FASTQファイル(Nanopore)、出力先ディレクトリ、サンプル名を指定して実行。出力先ディレクトリはあらかじめ作成しておく必要がある。  
    ```
    path/to/meta_vrl_long_map_conda.sh read.fastq out_dir SAMPLE_NAME
    ```
    必要メモリ10G程度。  

    出力結果(代表的なもののみ)  
    - バリアント(VCF): READNAME.sam.mapped.bam.sort.bam.filter.anno.vcf.filter.vcf.Low.vcf  
    - コンセンサス配列(FASTA): READNAME.sam.mapped.bam.sort.bam.filter.anno.vcf.masked.9.rename.fasta  

