# excel2dfast

## 概要

Excelファイルに記載されたメタデータ情報等から dfast_vrl を実行するための metadata.txt ファイルやジョブスクリプトを生成する

## 準備

Excelファイルにメタデータを記載する。赤字の項目が必須（isolate名などサンプルごとに異なる項目）。それ以外の項目は空欄にしておけば excel2dfast.py スクリプト中に記載された値が使用される。  
ゲノムのFASTAファイルへのパスは1列目に記載する（必須）。パスは絶対パスまたは、excel2dfast.py を実行したディレクトリからの相対パスとすること。ファイルが見つからない場合、excel2dfast.py は処理を中断する。

 

## スクリプト実行 

python の拡張モジュール pandas と openpyxl が必要なので conda または pip でインストールする。あるいは、これらが入ったコンテナを使うことで代用する(後述)。  


デフォルトだと実行時にメモリが不足するので qlogin 時にメモリを増やしてログインしておく 
```
qlogin -l mem_req=20G,s_vmem=20G
```

```
python excel2dfast.py -i dfast_sample_list.xlsx
```

ジョブ実行スクリプト (アレイジョブになっている)と サンプルごとのメタデータファイルが出力される。Excelファイルへのパス (-i) は必須。出力ファイル名、ディレクトリ等、それ以外はオプション。`python excel2dfast.py -h`でヘルプ表示。  

#### singularity コンテナを使った実行方法
モジュールをインストールしない場合には、  

```
singularity exec -B /lustre6/private/vrl /usr/local/biotools/d/dram:1.2.0--py_0 python excel2dfast.py
```

で実行可能。（自ホーム以外で実行する場合、-B オプションでコンテナにディレクトリをバインドすること）

#### スクリプト実行時の環境変数について  
- DFV_SINGULARITY_CONTAINER: dfast_vrl のsingularityコンテナへのパス (指定しなかった場合、`/lustre6/public/vrl/dfast_vrl:latest.sif`が用いられる)  
- DFV_SINGULARITY_OPTION: `singularity exec`を実行時に与えるコマンドラインオプションを記載。指定しなかった場合無視される。例) ディレクトリのバインドパス等 `-B /lustre6/private/vrl` など。  




## バッチジョブ実行

デフォルトでは job_dfast_vrl.sh という名称でジョブスクリプトが出力されるので
```
qsub job_dfast_vrl.sh
```
でジョブ投入する。アレイジョブになっているので並列で実行される。  

特定のタスク番号だけ再実行する場合には、

```
qsub -t 5 job_dfast_vrl.sh
```
や
```
qsub -t 10:15 job_dfast_vrl.sh
```
などとする。