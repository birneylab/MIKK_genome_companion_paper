#!/usr/bin/env Rscript

#############################
# Libraries
#############################

library(tidyverse)
library(scales)
library(viridis)
library(cowplot)
library(circlize)
library(karyoploteR)
library(magick)
library(plotly)
library(fishualize)
library(GenomicRanges)
library(biomaRt)


#############################
# Functions
#############################

round.choose <- function(x, roundTo, dir = 1) {
  if(dir == 1) {  ##ROUND UP
    x + (roundTo - x %% roundTo)
  } else {
    if(dir == 0) {  ##ROUND DOWN
      x - (x %% roundTo)
    }
  }
}

LOD <- function(HI = c(0.9, 0.2, 0.3, 0.5, 0.1)) {
  lod = NA
  HI[HI==1] = 0.999
  HS = 1-HI
  if(length(HI)==1) {
    return(log( HI/ HS))
  } else {    
    h = (1-prod(HS))/(prod(HS))
    return(log(h))
  }
  return(lod)
}

#############################
# Variables
#############################

# HdrR chromosome lengths

chroms = read.table(here::here(working_directory, "data/Oryzias_latipes.ASM223467v1.dna.toplevel.fa_chr_counts.txt")) %>% 
  dplyr::select(chr = V1, end = V2) %>% 
  dplyr::filter(chr != "MT") %>% 
  dplyr::mutate(chr = paste("chr", chr, sep = ""),
                start = 0,
                end = as.numeric(end)) %>% 
  dplyr::select(chr, start, end)

# HdrR chromosome lengths with MT

chroms_with_mt = read.table(here::here(working_directory, "data/Oryzias_latipes.ASM223467v1.dna.toplevel.fa_chr_counts.txt")) %>% 
  dplyr::select(chr = V1, end = V2) %>% 
  dplyr::mutate(chr = paste("chr", chr, sep = ""),
                start = 0,
                end = as.numeric(end)) %>% 
  dplyr::select(chr, start, end)


# HNI chromosome lengths

chroms_hni = read.table(here::here(working_directory, "data/Oryzias_latipes_hni.ASM223471v1.dna.toplevel.fa_chr_counts.txt")) %>% 
  dplyr::select(chr = V1, end = V2) %>% 
  dplyr::mutate(chr = paste("chr", chr, sep = ""),
                start = 0,
                end = as.numeric(end)) %>% 
  dplyr::select(chr, start, end)



#############################
# Plotting
#############################

## Plots directory
plots_dir = here::here(working_directory, "plots", "sv_analysis")

## Sample order

ont_samples = c("4-1", "4-2", "7-1", "7-2", "11-1", "69-1", "79-2", "80-1", "117-2", "131-1", "134-1", "134-2")
ont_samples_pol = c("4-1", "7-1", "11-1", "69-1", "79-2", "80-1", "117-2", "134-1", "134-2")

## Recode vector for FILTER
filter_recode = c("The fasta index has no entry for\nthe given reference name of the variant",
                  "No long reads\nin variant region",
                  "No long reads\nsupport the variant",
                  "The long read\nregions do not fit",
                  "Not enough\nshort reads",
                  "The variant\nwas polished away",
                  "The variant reference name\ndoes not exist in the\nshort read BAM file",
                  "The variant reference name\ndoes not exist in the\nlong read BAM file",
                  "Skipped",
                  "All filters\npassed")
names(filter_recode) = c("FAIL0",
                         "FAIL1",
                         "FAIL2",
                         "FAIL3",
                         "FAIL4",
                         "FAIL5",
                         "FAIL6",
                         "FAIL7",
                         "SKIP",
                         "PASS")

## Palettes

pal_paddle = c("#9b5de5","#f15bb5","#fee440","#00bbf9","#00f5d4")
pal_brainbow = c("#264653","#2a9d8f","#e9c46a","#f4a261","#e76f51")
pal_riviera = c("#05668d","#028090","#00a896","#02c39a","#f0f3bd")
pal_lavender = c("#f2d7ee","#d3bcc0","#a5668b","#69306d","#0e103d")
pal_smrarvo = c("#54478c","#2c699a","#048ba8","#0db39e","#16db93","#83e377","#b9e769","#efea5a","#f1c453","#f29e4c")
pal_warmror = c("#5f0f40","#9a031e","#fb8b24","#e36414","#0f4c5c")
pal_pastels = c("#ffadad","#ffd6a5","#fdffb6","#caffbf","#9bf6ff","#a0c4ff","#bdb2ff","#ffc6ff","#fffffc")


svtype_hist_pal = colorRampPalette(pal_paddle)(5)[c(1:2, 4:5)]
names(svtype_hist_pal) = c("DEL", "INS", "DUP", "INV")

pal_abba <- c("#F3B61F", "#631E68", "#F6673A", "#F33A56", "#55B6B0", "#621B00")
names(pal_abba) <- c("HdrR", "HSOK", "HNI", "melastigma", "javanicus", "Kaga")
