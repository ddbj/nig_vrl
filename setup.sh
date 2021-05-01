
NIGVRL_ROOT=`pwd`

echo $NIGVRL_ROOT

echo "git clone meta_vrl.."

git clone https://github.com/h-mori/meta_vrl.git
#git clone -b feature/sc-reference https://github.com/h-mori/meta_vrl.git
#git clone -b feature/sc-reference git@github.com:h-mori/meta_vrl.git


#mkdir META_VRL
#wget http://palaeo.nig.ac.jp/Resources/META_VRL/SRR10903401_1.fastq.gz -O META_VRL/SRR10903401_1.fastq.gz
#wget http://palaeo.nig.ac.jp/Resources/META_VRL/SRR10903401_2.fastq.gz -O META_VRL/SRR10903401_2.fastq.gz
#wget http://palaeo.nig.ac.jp/Resources/META_VRL/GRCh38.Wuhan.tar.gz -O META_VRL/GRCh38.Wuhan.tar.gz
#wget http://palaeo.nig.ac.jp/Resources/META_VRL/Wuhan-Hu-1.fasta -O META_VRL/Wuhan-Hu-1.fasta
#wget http://togows.dbcls.jp/entry/nucleotide/NC_045512.2.fasta -O META_VRL/NC_045512.2.fasta

echo "install miniconda/pangolin"

NIGVRL_MINICONDA=Miniconda3-py39_4.9.2-Linux-x86_64.sh

if [ ! -f $NIGVRL_MINICONDA ]; then
    wget https://repo.anaconda.com/miniconda/$NIGVRL_MINICONDA
    bash $NIGVRL_MINICONDA -b -p $NIGVRL_ROOT/miniconda3
fi

export PATH=$NIGVRL_ROOT/miniconda3/bin:$PATH
source $NIGVRL_ROOT/miniconda3/etc/profile.d/conda.sh

if [ ! -d pangolin ]; then
    git clone https://github.com/cov-lineages/pangolin.git
    #eval "$(/./miniconda3/bin/conda shell.bash hook)"
    cd pangolin
    conda env create -f environment.yml
    conda activate pangolin
    python setup.py install
    conda deactivate
fi

#git clone git@github.com:nigyta/dfast_vrl.git
