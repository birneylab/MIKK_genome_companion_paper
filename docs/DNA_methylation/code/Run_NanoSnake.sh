#!/bin/bash

set -euo pipefail

rm -f bsub_err.txt bsub_out.txt

bsub \
      	-J NanoSnake_DNA_ONT_medaka \
        -eo bsub_err.txt \
        -oo bsub_out.txt \
        -n 3 \
	-M 5000 \
        -q dungeon-rh74 \
        NanoSnake DNA_ONT $@ \
                -g ftp://ftp.ensembl.org/pub/release-99/fasta/oryzias_latipes/dna/Oryzias_latipes.ASM223467v1.dna_sm.toplevel.fa.gz \
                -a ftp://ftp.ensembl.org/pub/release-99/gff3/oryzias_latipes/Oryzias_latipes.ASM223467v1.99.gff3.gz \
                -s sample_sheet.tsv \
                --cluster_config cluster_config.yaml \
                --restart_times 1 \
                --conda_prefix /nfs/software/birney/adrien/miniconda3/envs/NanoSnake_wrappers
