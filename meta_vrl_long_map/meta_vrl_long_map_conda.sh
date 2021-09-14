#!/bin/bash

# USAGE: this_shell_script inputfastq output_dir sample_name
# inputfastq=$1
# output_dir=$2
# sample_name=$3

DIRPATH=`echo $(cd $(dirname $0) && pwd)`

MINIMAPREF=${DIRPATH}/../refs/NC_045512.2.fasta
LOGFILE="$2/meta_vrl.lmap.log"

if [ $# -ne 3 ]; then
  echo "you specified $# arguments." 1>&2
  echo "But this program can only use 3 arguments." 1>&2
  exit 1
fi
if [ ! -f $1 ]; then
        echo "No $1 file exist." 1>&2
        exit 1
fi
if [ ! -d $2 ]; then
        echo "$2 directory does not exist. please mkdir" 1>&2
        exit 1
fi
touch $LOGFILE
 if [ ! -f $LOGFILE ]; then
  echo "Error cannot create $LOGFILE."
  exit 1;
fi
{
DE0=`basename "$1"`
SAMPLENAME=$3
cp "$1" "$2/$DE0"

# read preprocessing
cutadapt -g ^ATTGTACTTCGTTCAGTTACGTATTGCTAANNNNNNNNNNNNNNNNNNNNNNNNNNNNNNCAGCACCT -o $2/$DE0.trim1.fastq -O 30 -e 0.3 -m 100 -M 1000 -q 1 --discard-untrimmed $2/$DE0
cutadapt -a AGGTGCTGNNNNNNNNNNNNNNNNNNNNNNNNTTAACCTTAGCAATACGTAACTTA -o $2/$DE0.trim2.fastq -O 20 -e 0.3 -m 100 -q 1 --discard-untrimmed $2/$DE0.trim1.fastq
cutadapt -g ^CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC -o $2/$DE0.trim3.fastq -O 50 -e 0.1 -m 100 -q 1 -u 33 $2/$DE0.trim2.fastq
cutadapt -g ^CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC -o $2/$DE0.trim4.fastq -O 50 -e 0.1 -m 100 -q 1 -u -33 $2/$DE0.trim3.fastq

# mapping
minimap2 -ax map-ont $MINIMAPREF $2/$DE0.trim4.fastq -o $2/$DE0.sam
samtools view -Sbq 10 -F 0x04 $2/$DE0.sam > $2/$DE0.sam.mapped.bam
samtools sort $2/$DE0.sam.mapped.bam > $2/$DE0.sam.mapped.bam.sort.bam
samtools index $2/$DE0.sam.mapped.bam.sort.bam

# variant call
medaka_variant -s r941_min_high_g360 -i $2/$DE0.sam.mapped.bam.sort.bam -f $MINIMAPREF -o $2/$DE0.medaka -t 1 -m r941_min_high_g360
medaka tools annotate $2/$DE0.medaka/round_1.vcf $MINIMAPREF $2/$DE0.sam.mapped.bam.sort.bam $2/$DE0.sam.mapped.bam.sort.bam.vcf
lofreq filter -i $2/$DE0.sam.mapped.bam.sort.bam.vcf -v 1 -o $2/$DE0.sam.mapped.bam.sort.bam.filter.vcf

# variant annotation
snpEff -no-downstream -no-upstream -no-utr -classic -formatEff NC_045512.2 $2/$DE0.sam.mapped.bam.sort.bam.filter.vcf > $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf
perl $DIRPATH/RemoveArtifactVCFNanopore.pl $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf
perl $DIRPATH/ExtractSNVFromVCF.pl $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.filter.vcf
perl $DIRPATH/CreateSNVTable.pl $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.filter.vcf.ext
perl $DIRPATH/ReplaceLowDepthSNV.pl $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.filter.vcf

# make consensus sequence from VCF
bcftools view $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.filter.vcf.Low.vcf -Oz -o $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.filter.vcf.Low.vcf.gz
bcftools index $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.filter.vcf.Low.vcf.gz
bcftools consensus -f $MINIMAPREF $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.filter.vcf.Low.vcf.gz -o $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.fasta

# calculate depth/breadth (from BAM file of the reference sequence)
# Format: total_length, mapped_length, sum_depth, mean_depth1(sum_depth/total_length), mean_depth2(sum_depth/mapped_length) coverage(mapped_length/total_length)
faidx --transform bed $MINIMAPREF > $2/reference.size.bed
coverageBed -d -a $2/reference.size.bed -b $2/$DE0.sam.mapped.bam.sort.bam | awk '$5>0{mapped++;sum += $5}END{print NR"\t"mapped"\t"sum"\t"sum/NR"\t"sum/mapped"\t"mapped/NR}' > $2/$DE0.sam.mapped.bam.sort.bam.coverage.txt

# read re-mapping to the consensus sequence
CONSENSUS=$2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.fasta
DIR_MAP2CONSENSUS=$2/map2consensus
mkdir -p $DIR_MAP2CONSENSUS
minimap2 -ax map-ont $CONSENSUS $2/$DE0.trim4.fastq -o $DIR_MAP2CONSENSUS/$DE0.sam
samtools view -Sbq 10 -F 0x04 $DIR_MAP2CONSENSUS/$DE0.sam > $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam
samtools sort $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam > $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam
samtools index $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam

# make consensus FASTA for mapped region
# bamutils is only available in Python2.7 env. Use in-house awk script to make BED for mapped region
# singularity exec --no-mount tmp /usr/local/biotools/n/ngsutils\:0.5.9--py27h516909a_2 bamutils expressed -ns $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam > $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam.bed
faidx --transform bed $CONSENSUS > $DIR_MAP2CONSENSUS/consensus.size.bed
coverageBed -d -a $DIR_MAP2CONSENSUS/consensus.size.bed -b $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam > $DIR_MAP2CONSENSUS/consensus.cov.tsv
awk 'BEGIN{flag_mapped=0;threshold=1;start=0}{if(!flag_mapped && $5>=threshold){flag_mapped=1;start=NR-1}else if(flag_mapped && $5<threshold){flag_mapped=0;print($1"\t"start"\t"NR-1)}}END{if(flag_mapped){print($1"\t"start"\t"NR)}}' $DIR_MAP2CONSENSUS/consensus.cov.tsv > $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam.bed
bedtools getfasta -fi $CONSENSUS -bed $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam.bed > $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.mapped.fasta

# make consensus FASTA with unmapped region masked
faidx --transform chromsizes $CONSENSUS > $DIR_MAP2CONSENSUS/consensus.size
bedtools complement -i $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam.bed -g $DIR_MAP2CONSENSUS/consensus.size > $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam.bed.unmapped.bed
bedtools maskfasta -fi $CONSENSUS -bed $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam.bed.unmapped.bed -fo $2/tmp.masked.fasta
seqkit replace -is -p "^n+|n+$" -r "" $2/tmp.masked.fasta > $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.masked.fasta
rm -f $2/tmp.masked.fasta

# make consensus FASTA with low depth region masked
# Here, 'low depth' region is defined as "DP<10"
awk 'BEGIN{flag_mapped=0;threshold=10;start=0}{if(!flag_mapped && $5>=threshold){flag_mapped=1;start=NR-1}else if(flag_mapped && $5<threshold){flag_mapped=0;print($1"\t"start"\t"NR-1)}}END{if(flag_mapped){print($1"\t"start"\t"NR)}}' $DIR_MAP2CONSENSUS/consensus.cov.tsv > $DIR_MAP2CONSENSUS/consensus.mapped.9.bed
bedtools complement -i $DIR_MAP2CONSENSUS/consensus.mapped.9.bed -g $DIR_MAP2CONSENSUS/consensus.size > $DIR_MAP2CONSENSUS/$DE0.fastq.sam.mapped.bam.sort.bam.bed.unmapped.9.bed
bedtools maskfasta -fi $CONSENSUS -bed $DIR_MAP2CONSENSUS/$DE0.fastq.sam.mapped.bam.sort.bam.bed.unmapped.9.bed -fo $2/tmp.masked.fasta
seqkit replace -is -p "^n+|n+$" -r "" $2/tmp.masked.fasta > $2/$DE0.fastq.sam.mapped.bam.sort.bam.filter.anno.vcf.masked.9.fasta
rm -f $2/tmp.masked.fasta


# source ~/activate_conda.sh
# conda activate pangolin
# pangolin $2/$DE0.fastq.sam.mapped.bam.sort.bam.filter.anno.vcf.masked.9.fasta --outfile $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.masked.fasta.9.csv

cat $2/$DE0.fastq.sam.mapped.bam.sort.bam.filter.anno.vcf.masked.9.fasta | sed -e "s/^>NC_045512\.2/>$SAMPLENAME/g" > $2/$DE0.fastq.sam.mapped.bam.sort.bam.filter.anno.vcf.masked.9.rename.fasta
} >> "$LOGFILE" 2>&1
