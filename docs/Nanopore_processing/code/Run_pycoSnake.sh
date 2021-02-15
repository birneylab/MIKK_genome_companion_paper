#!/bin/bash

set -euo pipefail

rm -f bsub_err.txt bsub_out.txt

bsub \
      	-J pycoSnake_DNA_ONT_medaka \
        -eo bsub_err.txt \
        -oo bsub_out.txt \
        -n 5 \
	-M 10000 \
        -q dungeon-rh74 \
        pycoSnake DNA_ONT $@ \
                -g ftp://ftp.ensembl.org/pub/release-99/fasta/oryzias_latipes/dna/Oryzias_latipes.ASM223467v1.dna_sm.toplevel.fa.gz \
                -a ftp://ftp.ensembl.org/pub/release-99/gff3/oryzias_latipes/Oryzias_latipes.ASM223467v1.99.gff3.gz \
                -s sample_sheet.tsv \
                --cluster_config cluster_config.yaml \
                --restart_times 1 \
		--keepgoing \
		--conda_prefix /nfs/software/birney/adrien/miniconda3/envs/NanoSnake_wrappers
