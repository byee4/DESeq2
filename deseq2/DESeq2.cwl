#!/usr/bin/env deseq2

cwlVersion: v1.0

class: CommandLineTool


baseCommand: [Rscript, /home/bay001/projects/codebase/DESeq2/deseq2/DESeq2.R]

inputs:
  counts:
    type: File
    inputBinding:
      position: 1
      prefix: --count
    doc: "counts table"
  conditions:
    type: File
    default: snps
    inputBinding:
      position: 2
      prefix: --conditions
    doc: "conditions file describing experiment factors"
  filter_avg:
    type: int
    default: 0
    inputBinding:
      position: 3
      prefix: --filterAvg
    doc: "filters out any gene below this number of summed counts across all samples."
  base_ref:
    type: string
    inputBinding:
      position: 4
      prefix: --ref
    doc: "determines the base (numerator) condition"
  alt:
    type: string
    inputBinding:
      position: 5
      prefix: --alt
    doc: "determines the treatment (denominator) condition"
  col_skip:
    type: int
    default: 6
    inputBinding:
      position: 6
      prefix: --colSkip
    doc: "skip the first N columns (useful for featureCounts file)"
  column:
    type: string
    inputBinding:
      position: 7
      prefix: --column
  additional_factor:
    type: string
    inputBinding:
      position: 8
      prefix: --additionalFactor
  beta_prior:
    type: boolean
    inputBinding:
      position: 9
      prefix: --betaPrior
    default: false
  plot_pca:
    type: boolean
    inputBinding:
      position: 10
      prefix: --plotPCA
    default: true
  plot_ma:
    type: boolean
    inputBinding:
      position: 11
      prefix: --plotMA
    default: true
arguments: [
  "--output",
  $(inputs.counts.nameroot).diffexp.txt
  ]

outputs:

  output_de:
    type: File
    outputBinding:
      glob: $(inputs.counts.nameroot).diffexp.txt
  output_norm_counts:
    type: File
    outputBinding:
      glob: $(inputs.counts.nameroot).diffexp.txt.norm_counts
  output_pca:
    type: File
    outputBinding:
      glob: $(inputs.counts.nameroot).diffexp.txt.pca.png
  output_ma:
    type: File
    outputBinding:
      glob: $(inputs.counts.nameroot).diffexp.txt.ma.png