REFFILE=$1
ALIGNFILE=$2
OUTFILE=$3
BWA="/nfs/software/birney/bwa/bwa mem -p -M -t 1 $REFFILE "
FILES=($(ls $DIRECT ))
f=${FILES[$LSB_JOBINDEX-1]}
fbname=$(basename "$f" .fastq)
COMMAND="$BWA $ALIGNFILE > $OUTFILE"

eval "$COMMAND"


