# META_VRL_Long_Map
A viral genome reconstruction tool from metagenomic and metatranscriptomic sequencing data.
META_VRL_Long_Map is a pipeline for the analysis of Oxford Nanopore fastq reads.
This pipeline conducts a reference-based consensus sequence generation and a SNV calling analysis.

## Reference data
For MINIMAPREF, please download and use a RefSeq version of genome sequence data of Wuhan-Hu-1 (NC_045512.2)
https://www.ncbi.nlm.nih.gov/nuccore/1798174254?report=fasta
Since snpEff uses the RefSeq version of Wuhan-Hu-1 genome for the snpEff reference database, we use NC_045512.2 not MN908947.3 in the SNP reference.

You need to specify the places of MINIMAPREF in NIG supercomputer in the meta_vrl_long_map.sh file.

## Usage
```bash
mkdir Testdir3
qsub -l s_vmem=50G -l mem_req=50G /home/hoge/META_VRL/meta_vrl_long_map.sh /home/hoge/Nanopore_Sample1.fastq /home/hoge/Testdir3 samplename
```
Please replace hoge to your username in NIG supercomputer.
Also, please replace hoge in meta_vrl_long_map.sh to your username in NIG supercomputer.
The s_vmem and mem_req are depended on the complexity of the query fastq files. Usually, 50 GB is enough (medaka, bcftools, pangolin use more than 16 GB RAM).
You need to specify an input fastq file, an output directory, and a sample name that you want to add in the consensus FASTA file.

## Input and Output
The input files of META_VRL_Long_Map is an Oxford Nanopore fastq file.

The output files of META_VRL_Long_Map are 
1. consensus FASTA file with low depth regions are masked to Ns (hoge.fastq.sam.mapped.bam.sort.bam.filter.anno.vcf.masked.9.fasta)
2. pangolin lineage inference result CSV file (hoge.sam.mapped.bam.sort.bam.filter.anno.vcf.masked.fasta.9.csv)
3. SNV VCF file against Wuhan-Hu-1 geome (hoge.vcf.filter.vcf.ext.snv)
4. etc.

## Dependencies
META_VRL_Long_Map uses
### medaka
### Minimap2
### Cutadapt
### samtools
### bedtools
### ngsutils
### seqkit
### pyfaidx
### LoFreq
### snpEff
### bcftools
### Pangolin

Since the singularity containers of most of these tools exist in NIG supercomputer, you don't need to install and specify the file direction (already each container's file direction has coded in meta_vrl_long_map.sh). medaka and pangolin are exceptions.
