
#!/bin/sh
#$ -S /bin/sh
#$ -cwd
# USAGE: this_shell_script input_R1 input_R2 output_dir
# input_R1=$1
# input_R2=$2
# output_dir=$3
BWAREF=/home/nig-vrl/NC_045512.2.fasta
ILLUMINA=/home/nig-vrl/IlluminaAdapter.fasta
LOGFILE="$3/meta_vrl.smap.log"
if [ $# -ne 3 ]; then
  echo "you specified $# arguments." 1>&2
  echo "But this program can only use 3 arguments." 1>&2
  exit 1
fi
if [ ! -f $1 ]; then
	echo "No $1 file exist." 1>&2
	exit 1
fi
if [ ! -f $2 ]; then
	echo "No $2 file exist." 1>&2
	exit 1
fi
if [ ! -d $3 ]; then
	echo "$3 directory does not exist. please mkdir" 1>&2
	exit 1
fi
touch $LOGFILE
 if [ ! -f $LOGFILE ]; then
  echo "Error cannot create $LOGFILE."
  exit 1;
fi
{
DE0=`basename "$1"`
DE1=`basename "$2"`
cp "$1" "$3/$DE0"
cp "$2" "$3/$DE1"

singularity exec /usr/local/biotools/c/cutadapt\:3.2--py38h0213d0e_0 cutadapt -a file:$ILLUMINA -o $3/$DE0.trim1.fastq -O 15 -e 0.1 -m 80 -q 1 $3/$DE0
singularity exec /usr/local/biotools/c/cutadapt\:3.2--py38h0213d0e_0 cutadapt -g file:$ILLUMINA -o $3/$DE0.trim2.fastq -O 15 -e 0.1 -m 80 -q 1 $3/$DE0.trim1.fastq
singularity exec /usr/local/biotools/c/cutadapt\:3.2--py38h0213d0e_0 cutadapt -g ^AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA -o $3/$DE0.trim3.fastq -O 50 -e 0.1 -m 30 -q 17 -u 35 $3/$DE0.trim2.fastq
singularity exec /usr/local/biotools/c/cutadapt\:3.2--py38h0213d0e_0 cutadapt -a file:$ILLUMINA -o $3/$DE1.trim1.fastq -O 15 -e 0.1 -m 80 -q 1 $3/$DE1
singularity exec /usr/local/biotools/c/cutadapt\:3.2--py38h0213d0e_0 cutadapt -g file:$ILLUMINA -o $3/$DE1.trim2.fastq -O 15 -e 0.1 -m 80 -q 1 $3/$DE1.trim1.fastq
singularity exec /usr/local/biotools/c/cutadapt\:3.2--py38h0213d0e_0 cutadapt -g ^AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA -o $3/$DE1.trim3.fastq -O 50 -e 0.1 -m 30 -q 17 -u 35 $3/$DE1.trim2.fastq
mkdir $3/pair
singularity exec --no-mount tmp /usr/local/biotools/s/seqkit\:0.15.0--0 seqkit pair -1 $3/$DE0.trim3.fastq -2 $3/$DE1.trim3.fastq -O $3/pair

singularity exec /usr/local/biotools/b/bwa\:0.7.17--pl5.22.0_2 bwa index -a bwtsw $BWAREF
singularity exec /usr/local/biotools/b/bwa\:0.7.17--pl5.22.0_2 bwa mem $BWAREF $3/pair/$DE0.trim3.fastq $3/pair/$DE1.trim3.fastq > $3/$DE0.qf.fastq.sam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools view -Sbq 10 -F 0x04 $3/$DE0.qf.fastq.sam > $3/$DE0.qf.fastq.sam.mapped.bam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools sort $3/$DE0.qf.fastq.sam.mapped.bam > $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools index $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam
export MALLOC_ARENA_MAX=2
singularity exec /usr/local/biotools/l/lofreq\:2.1.5--py38h1bd3507_3 lofreq indelqual --dindel $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam -f $BWAREF -o $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.fixed.bam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools index $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.fixed.bam
singularity exec /usr/local/biotools/l/lofreq\:2.1.5--py38h1bd3507_3 lofreq call --no-default-filter --call-indels $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.fixed.bam -f $BWAREF -o $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.vcf
singularity exec /usr/local/biotools/l/lofreq\:2.1.5--py38h1bd3507_3 lofreq filter -i $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.vcf -a 0.5 -v 10 -Q 20 --no-defaults -o $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.0.5.vcf
mkdir $3/tmp $3/data
cp /etc/resolv.conf $3/tmp
singularity exec -B $3/tmp:/tmp -B $3/data:/usr/local/share/snpeff-5.0-0/data /usr/local/biotools/s/snpeff\:5.0--0 snpEff -no-downstream -no-upstream -no-utr -classic -formatEff NC_045512.2 $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.0.5.vcf > $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.0.5.anno.vcf
perl /home/nig-vrl/RemoveArtifactVCF.pl $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.0.5.anno.vcf
perl /home/nig-vrl/ExtractSNVFromVCF.pl $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.0.5.anno.vcf.filter.vcf
perl /home/nig-vrl/CreateSNVTableIllumina.pl $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.0.5.anno.vcf.filter.vcf.ext
perl /home/nig-vrl/FilterLoFreqVCF.pl $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.0.5.anno.vcf.filter.vcf.ext.snv

singularity exec /usr/local/biotools/b/bcftools\:1.10.2--hd2cd319_0 bcftools view $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.0.5.anno.vcf.filter.vcf -Oz -o $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.0.5.anno.vcf.filter.vcf.gz
singularity exec /usr/local/biotools/b/bcftools\:1.10.2--hd2cd319_0 bcftools index $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.0.5.anno.vcf.filter.vcf.gz
singularity exec /usr/local/biotools/b/bcftools\:1.10.2--hd2cd319_0 bcftools consensus -f $BWAREF $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.0.5.anno.vcf.filter.vcf.gz -o $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.0.5.anno.vcf.filter.vcf.fasta
source /lustre6/public/vrl/activate_pangolin.sh
pangolin $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.0.5.anno.vcf.filter.vcf.fasta --outfile $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.0.5.anno.vcf.filter.vcf.fasta.csv

# calculate depth/breadth of coverage 
# Format: total_length, mapped_length, sum_depth, mean_depth1(sum_depth/total_length), mean_depth2(sum_depth/mapped_length) coverage(mapped_length/total_length)
singularity exec --no-mount tmp /usr/local/biotools/p/pyfaidx\:0.5.9.5--pyh3252c3a_0 faidx --transform bed $BWAREF > $3/reference.size.bed
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 coverageBed -d -a $3/reference.size.bed -b $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam | awk '$5>0{mapped++;sum += $5}END{print NR"\t"mapped"\t"sum"\t"sum/NR"\t"sum/mapped"\t"mapped/NR}' > $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.coverage.txt
CONSENSUS=$3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.0.5.anno.vcf.filter.vcf.fasta
DIR_MAP2CONSENSUS=$3/map2consensus
mkdir -p $DIR_MAP2CONSENSUS
singularity exec /usr/local/biotools/b/bwa\:0.7.17--pl5.22.0_2 bwa index -a bwtsw $CONSENSUS
singularity exec /usr/local/biotools/b/bwa\:0.7.17--pl5.22.0_2 bwa mem $CONSENSUS $3/pair/$DE0.trim3.fastq $3/pair/$DE1.trim3.fastq > $DIR_MAP2CONSENSUS/$DE0.sam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools view -Sbq 10 -F 0x04 $DIR_MAP2CONSENSUS/$DE0.sam > $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools sort $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam > $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools index $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam
# make consensus FASTA for mapped region
singularity exec --no-mount tmp /usr/local/biotools/n/ngsutils\:0.5.9--py27h516909a_2 bamutils expressed -ns $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam > $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam.bed
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 bedtools getfasta -fi $CONSENSUS -bed $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam.bed > $3/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.mapped.fasta
# make consensus FASTA with unmapped region masked
singularity exec --no-mount tmp /usr/local/biotools/p/pyfaidx\:0.5.9.5--pyh3252c3a_0 faidx --transform chromsizes $CONSENSUS > $DIR_MAP2CONSENSUS/consensus.size
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 bedtools complement -i $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam.bed -g $DIR_MAP2CONSENSUS/consensus.size > $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam.bed.unmapped.bed
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 bedtools maskfasta -fi $CONSENSUS -bed $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam.bed.unmapped.bed -fo $3/tmp.masked.fasta
singularity exec --no-mount tmp /usr/local/biotools/s/seqkit\:0.15.0--0 seqkit replace -is -p "^n+|n+$" -r "" $3/tmp.masked.fasta > $3/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.filter.vcf.masked.fasta
rm -f $3/tmp.masked.fasta
pangolin $3/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.masked.fasta --outfile $3/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.filter.vcf.masked.fasta.csv
} >> "$LOGFILE" 2>&1
