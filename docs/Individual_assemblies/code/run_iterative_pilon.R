
samples_files = read.table("sample_file_list.txt", header=T, comment.char="n", sep="\t")
samples_files = data.frame(rownames(samples_files), samples_files)

assembly_files = list.files("..", pattern=".fa$")#dir("..")
assembly_files = assembly_files[grep("lay", assembly_files)]

x = as.numeric(as.character(Sys.getenv("LSB_JOBINDEX")))
assembly_file = paste("../", assembly_files[grep(samples_files[x,1], assembly_files)], sep="")
fastqfile = as.character(samples_files[x,2])

out_dir = samples_files[x,1]
system(paste("mkdir ", out_dir, sep=""))

bam_file = paste(out_dir, "/", samples_files[x,1], "_polished", sep="")

command = paste("/nfs/software/birney/bwa/bwa index ", assembly_file, sep="")
system(command)


command = paste("./run_bwa.sh ", assembly_file, " ", fastqfile, " ", bam_file, "0.bam", sep="") 
system(command)

command = paste("/nfs/software/birney/samtools-1.3/samtools sort ", bam_file, "0.bam", ">", bam_file, "tmp_bam.bam", sep="")
system(command) 
command = paste("mv ", bam_file, "tmp_bam.bam ", bam_file, "0.bam", sep="")
system(command) 
command = paste("/nfs/software/birney/samtools-1.3/samtools index ", bam_file, "0.bam", sep="")
system(command) 


command = paste("java -Xmx120G -jar /nfs/software/birney/pilon/pilon-1.23.jar --genome ", assembly_file, " --bam ",  bam_file, "0.bam", " --tracks  --changes --output ", bam_file, "0", sep="")
system(command)

runs = 9
for(x in 1:runs) {
	
	command = paste("sed -i s'|_pilon||'g ", bam_file, x-1, ".fasta", sep="")
        print(command)
        system(command)

	command = paste("/nfs/software/birney/bwa/bwa index ", bam_file, x-1, ".fasta", sep="")
	system(command)

	command = paste("./run_bwa.sh ", bam_file,  x-1, ".fasta ", fastqfile, " ", bam_file, x, ".bam", sep="")
	system(command)

	command = paste("/nfs/software/birney/samtools-1.3/samtools sort ", bam_file, x, ".bam", ">", bam_file, "tmp_bam.bam", sep="")
	system(command) 
	command = paste("mv ", bam_file, "tmp_bam.bam ", bam_file, x, ".bam", sep="")
	system(command) 
	command = paste("/nfs/software/birney/samtools-1.3/samtools index ", bam_file, x, ".bam", sep="")
	system(command)

	command = paste("java -Xmx120G -jar /nfs/software/birney/pilon/pilon-1.23.jar --genome ", bam_file, x-1 ,".fasta --bam ", bam_file, x, ".bam", " --changes --output ", bam_file, x, sep="")
	print(command)
	system(command)
}

