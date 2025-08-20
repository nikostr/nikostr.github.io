---
layout: post
title:  "ESEB poster 2025"
date:   2025-08-10 20:00:00 +0200
categories: posters
---


I chose to focus on the status of the Thymelaeaceae annotations as I'm currently trying to annotate a bunch of _Wikstroemia_ species, and I wanted to get a better idea about the status of the published annotations.

A link to the full poster is available [here](/assets/eseb2025/poster.pdf).

## TL;DR
All the Thymelaeaceae annotations I found have some issues with methods or the generated files themselves. The _Aquilaria sinensis_ and _A. yunnanensis_ annotations are based on transcript evidence and seem pretty okay, and can probably be used as-is, after correcting for files being badly formatted. The _Stellera chamaejasme_ annotation is not based on transcript data and has some pretty clear methods issues, and seems to suffer from over-prediction. If using the _Stellera_ annotation you probably want to account for this in some way.

## Methods

### Identifying annotations

I have attempted to identify the annotations that are out there, but I might very well have missed something. If you know of an annotation that I should be interested in, let me know! :) Apart from the annotations I had stumbled across and the papers they reference, I also looked at Thymelaeaceae genomes in EBI and did some basic Google Scholar searches, including searching within citing papers etc.

#### Annotations used

The following table provides an overview of the annotations used.

|Species|Annotation version|Publication doi|OrthoFinder|Exons per gene|OMArk|Expression analysis|Annotation GFF file used|Protein fasta file used|Where the data was accessed|
|-------|------------------|---------------|-----------|--------------|-----|-------------------|------------------------|-----------------------|---------------------------|
|_Aquilaria sinensis_|Ding et al. 2020|10.1093/gigascience/giaa013|Yes|Yes|Yes|Yes|coding_gene.annotation.gff|pep.fasta|https://gigadb.org/dataset/100702|
|_Aquilaria yunnanensis_|Li et al. 2024|10.1038/s41597-024-03635-z|Yes|Yes|Yes|Yes|A.yunnanensis.gff3.gz|A.yunnanensis.pep.fasta.gz|https://figshare.com/articles/dataset/The_genome_annotation_file_of_i_Aquilaria_yunnanensis_i_/24031866/4|
|_Stellera chamaejasme_|Hu et al. 2022|10.1111/mec.16622|Yes|Yes|Yes|Yes|langdu.chr.rename.gff.gz|langdu.pep.fa.gz|https://github.com/hhy18/Annotation-files-of-Stellera-chamaejasme|
|_Arabidopsis thaliana_|Araport11|10.1111/tpj.13415|Yes|Yes|Yes|No|Araport11_GFF3_genes_transposons.current.gff.gz|Araport11_pep_20250411_representative_gene_model.gz|https://www.arabidopsis.org/download/list?dir=Proteins%2FAraport11_protein_lists|
|_Theobroma cacao_|Cocoa Criollo B97-61/B2 version 2|10.1186/s12864-017-4120-9|Yes|Yes|No|No|Theobroma_cacaoV2_annot_annoted_clean.gff3.tar.gz|Theobroma_cacaoV2_annot_protein.faa.tar.gz|https://cocoa-genome-hub.southgreen.fr/download|
|_Gossypium hirsutum_|GCF_007990345.1|10.1038/s41588-020-0614-5|Yes|Yes|No|No|genomic.gff|protein.faa|Downloaded from NCBI using their tool as follows: datasets download genome accession PRJNA515894 --filename PRJNA515894-protein-gff3.zip --include protein,gff3|

The _Aquilaria_ and _Stellera_ species are Thymelaeaceae. The remaining annotations were used in annotating the _A. yunnanensis_ genome.


### OMArk

OMArk (v0.3.1, Nevers et al., 2024) was run using the LUCA database as recommended by the OMArk documentation. It was run as follows:

```
omamer search --db $LUCA --query $query --out results/${query_name}.omamer
omark -f results/${query_name}.omamer -d $LUCA --og_fasta $query --taxid $taxids -o results/${query_name} 
```

This was done for _Aquilaria sinensis_, _Stellera chamaejasme_, _A. yunnanensis_, and _Arabidopsis thaliana_. For each species, the protein fasta file from the above table above was used as is.

### Mono:multi-exonic genes
![The linked script](/assets/eseb2025/count-exons.sh) was used to calculate the proportion of mono-exonic to multi-exonic genes.

> [!note]
> It turns out that how this ratio is calculated differs in the literature. Jain et al. (2008) is sometimes cited, saying that intronless genes account for appproximately 20% of total genes in rice and _Arabidopsis_. Vuruputoor et al. (2023) cite Jain et al. for a ratio of 20%, but seem to instead calculate the ratio as mono-exonic:multi-exonic genes. As is seen in the attached script, I have opted for the mono-exonic:multi-exonic ratio instead of the mono-exonic:total genes.


### Orthofinder

OrthoFinder (v3.1.0, Emms et al., 2025) was run on proteins from _Arabidopsis_, _Stellera_, _A. sinensis_, _A. yunnanensis_, cotton, and cacao, i.e., the species used for the annotation of _A. yunnanensis_. The protein fastas used are listed in the table above. For _Arabidopsis_, _A. sinensis_, and _A. yunnanensis_ the files were used as-is. For cotton and cacao the OrthoFinder `primary_transcripts.py` script was used with [minor modifications](https://github.com/nikostr/OrthoFinder/commit/89d8e1ad16e7403d573ea125329bd20ecfecf1de). For cacao, `primary_transcripts.py` was invoked as:

```
python primary_transcript.py Theobroma_cacaoV2_annot_protein.faa last_dot_after_space
```

For _Stellera_ dots were replaced with asterisks as follows:

```
cat langdu.pep.fa|sed '/>/!s/\./*/g' > langdu.pep.no-dot.fa
```
OrthoFinder was run without additional parameters.

### Expression of _A. sinensis_ in orthogroups

#### _A. sinensis_ expression analysis
This was a quick-and-dirty analysis of expression in _A. sinensis_, a side-thing that I had done for some other purpose. It was generated as follows using Nextflow (v24.04.4, Di Tommaso et al., 2017) and the `nf-core/rnaseq` workflow (v3.18.0, Patel et al., 2024):

```
nextflow run \
    nf-core/rnaseq \
    -r 3.18.0 \
    --input ${samples_csv} \
    --outdir $outdir \
    --gtf ${clean_gtf} \
    --fasta ${genome_fasta} \
    --stringtie_ignore_gtf
```

The genome used was the _A. sinensis_ `chr_genome_assembly.fasta` accessible through the link in the table above. ![The samples](/assets/eseb2025/a.sinensis.samples.txt) were _A. sinensis_ illumina transcriptomics samples available at ENA (European Nucleotide Archive) on 2025-02-12. As `coding_gene.annotation.gff` has some issues (e.g., transcripts split across different chromosomes) and was not in line with what the `nf-core/rnaseq` pipeline required, it had to be cleaned up. The cleaned GTF file was generated as follows:
```
cat coding_gene.annotation.gff \
    | sed 's/\tCDS\t/\texon\t/' \
    > coding_gene.annotation.exons.gff
gffread -E coding_gene.annotation.exons.gff -T -o coding_gene.annotation.exons.gtf
cat coding_gene.annotation.exons.gtf \
    |sed 's+\(transcript_id \)\([^;]*\);$+gene_id \2; \1\2;+' \
    > coding_gene.annotation.exons.gene_ids.gtf
cat coding_gene.annotation.exons.gene_ids.gtf \
    | grep -v '"evm.model.Scaffold103.22"' \
    | grep -v '"evm.model.Scaffold11.131"' \
    | grep -v '"evm.model.Scaffold149.17"' \
    | grep -v '"evm.model.Scaffold205.2"' \
    | grep -v '"evm.model.Scaffold45.122"' \
    | grep -v '"evm.model.Scaffold49.5"' \
    | grep -v '"evm.model.Scaffold70.88"' \
    | grep -v '"evm.model.Scaffold95.19"' \
    > coding_gene.annotation.clean.gtf
```
#### Expression in orthogroups

![The linked script](/assets/eseb2025/minimal-expression-analysis.R) was used to identify the proportion of proteins for each species that are assigned to an orthogroup containing an _A. sinensis_ protein with transcript evidence.

> [!Note]
> This is obviously a hacky solution. A low percentage of proteins in orthogroups with _A. sinensis_ protein with transcript evidence does not necessarily mean that an annotation is unreliable. Potential explanations for this could in fact be that the _A. sinensis_ annotation is missing stuff.  


## Results

### Identified annotations
Among the Thymelaeaceae I have found published annotations for _Aquilaria sinensis_ (Ding et al., 2020), _Stellera chamaejasme_ (Hu et al., 2022), and _Aquilaria yunnanensis_ (Li et al., 2024). There are additional publications on Thymelaeaceae that do annotations, but these do not seem to be publicly available (Chen et al., 2014; Nong et al., 2020; Das et al., 2021).

#### Overview of the annotations and their issues
The following provides a brief summary of the published annotations, something about how they are generated and some of the issues I've identified. 

> [!Note]
> I am thankful to the authors for making these annotations available. I appreciate the work that they have put in. I hope that the comments below are constructive, and serve to help others make the best possible use of these annotations and the work that has gone into them. If you feel that I am doing any of these annotation an injustice, please reach out so that I can represent them in a fair way.

##### _A. sinensis_ (Ding et al. 2020 doi:10.1093/gigascience/giaa013)
This annotation is built RNA-seq and IsoSeq data, and combines this with homology information and _ab initio_ predictions. Genome versions are provided for the genomes used in the homology analyses, but annotation versions are lacking. There is no information given on which EVM weights are used. A significant issue with this annotation is that the gff file cannot be used as is, as some gene models are split in nonsensical ways across chromosomes. A potential explanation for this is that genome annotation was performed prior to scaffolding, and then transferred.

##### Stellera chamaejasme (Hu et al. 2022 doi:10.1111/mec.16622)

This annotation combines homology data with _ab initio_ predictions. _Ab initio_ predictions were based on _Arabidopsis_ parameters for two out of three methods. This annotation is not built on any transcript data. The publication itself does not specify which exact annotation versions were used from other species, though the author has clarified this in the [GitHub repo](https://github.com/hhy18/Annotation-files-of-Stellera-chamaejasme/issues/1).

The major issue with this annotation is the lack of transcript evidence, combined with EVidenceModeler being used to combine homology and _ab initio_ predictions with equal weights. Using EVM in this way means that it is possible that _ab initio_ predictions overrule homology evidence.

##### A. yunnanensis (Li et al. 2024 doi:10.1038/s41597-024-03635-z)

This annotation combines IsoSeq data with homology information and _ab initio_ predictions. For some species it is not clear which exact annotations were used as inputs as annotation versions are not given. A minor issue is that the gff file and the genome fasta file have different identifiers for the chromosomes.

### OMArk

The following figures show the OMArk result for _A. sinensis_, _Stellera_, _A. yunnanensis_ and _Arabidopsis_.

![_A. sinensis_ OMArk results](/assets/eseb2025/A.sinensis.png)

![_Stellera_ OMArk results](/assets/eseb2025/langdu.png)

![_A. yunnanensis_ OMArk results](/assets/eseb2025/A.yunnanensis.png)

![_Arabidopsis_ OMArk results](/assets/eseb2025/Araport11.png)

The following tables provide more detailed results:

__Clade used by OMArk__

||_A. sinensis_|_Stellera_|_A. yunnanensis_|_Arabidopsis_|
|-:|------------:|---------:|---------------:|------------:|
|Clade used|malvids|malvids|malvids|Brassicaceae|
|Number of conserved HOGs in clade|11704|11704|11704|17996|
			
__Results on conserved HOGs__

||_A. sinensis_|_Stellera_|_A. yunnanensis_|_Arabidopsis_|
|-:|------------:|---------:|---------------:|------------:|
|Single|8959 (76.55%)|9550 (81.60%)|9515 (81.30%)|16601 (92.25%)|
|Duplicated|1836 (15.69%)|1034 (8.83%)|1441 (12.31%)|1313 (7.30%)|
|Duplicated, Unexpected|1825 (15.59%)|1027 (8.77%)|1428 (12.20%)|236 (1.31%)|
|Duplicated, Expected|11 (0.09%)|7 (0.06%)|13 (0.11%)|1077 (5.98%)|
|Missing|909 (7.77%)|1120 (9.57%)|748 (6.39%)|82 (0.46%)|


__OMArk consistensy assessment__
			
||_A. sinensis_|_Stellera_|_A. yunnanensis_|_Arabidopsis_|
|-:|------------:|---------:|---------------:|------------:|
|Number of proteins in the whole proteome|29203|30933|27955|27644|

||_A. sinensis_|_Stellera_|_A. yunnanensis_|_Arabidopsis_|
|-:|------------:|---------:|---------------:|------------:|
|Total Consistent|21686 (74.26%)|19090 (61.71%)|21966 (78.58%)|26002 (94.06%)|
|Consistent, partial hits|3301 (11.30%)|4069 (13.15%)|3419 (12.23%)|685 (2.48%)|
|Consistent, fragmented|984 (3.37%)|677 (2.19%)|1182 (4.23%)|228 (0.82%)|
|Total Inconsistent|1513 (5.18%)|1497 (4.84%)|1619 (5.79%)|155 (0.56%)|
|Inconsistent, partial hits|550 (1.88%)|745 (2.41%)|598 (2.14%)|79 (0.29%)|
|Inconsistent, fragmented|170 (0.58%)|182 (0.59%)|202 (0.72%)|38 (0.14%)|
|Total Contaminants|0 (0.00%)|0 (0.00%)|0 (0.00%)|0 (0.00%)|
|Contaminants, partial hits|0 (0.00%)|0 (0.00%)|0 (0.00%)|0 (0.00%)|
|Contaminants, fragmented|0 (0.00%)|0 (0.00%)|0 (0.00%)|0 (0.00%)|
|Total Unknown|6004 (20.56%)|10346 (33.45%)|4370 (15.63%)|1487 (5.38%)|

### Mono:multi-exonic genes

The following table shows the number of mono- and multi-exonic protein coding genes per species, as well as the ratio between them.


|Species|Mono-exonic|Multi-exonic|Total genes|Mono:multi-ratio|
|------:|----------:|-----------:|----------:|---------------:|
|_A. sinensis_|6815|22388|29203|0.304404|
|_Stellera_|9138|21795|30933|0.41927|
|_A. yunnanensis_|7710|20245|27955|0.380835|
|_Arabidopsis_|5272|22261|27533|0.236827|

### Orthofinder

OrthoFinder generates a total of 38,717 orthogroups, with 16,219 of these containing only a single protein. The distribution of the numbers of proteins per orthogroup looks as follows:

![Number of proteins per orthogroup](/assets/eseb2025/n-proteins-in-orthogroup.png)

For each species, the number of proteins, and whether the protein belongs to a single-protein or multi-protein orthogroup is illustrated below:

![Number of proteins per species, and whether these belong to a single- or multi-protein orthogroup](/assets/eseb2025/single-n-orthogroups.png)

Among the orthogroups, the species co-occur as follows:

![Co-occurrence of species in orthogroups](/assets/eseb2025/orthogroup-upset.png)

Adding in the OMArk categories for the species analyzed using that tool to the above, the distribution looks as follows:


![Co-occurrence of species and OMArk categories in orthogroups](/assets/eseb2025/orthogroup-category-upset.png)

### _A. sinensis_ expression analysis

The following table shows the number of proteins per species that belong to an orthogroup containing a protein with RNA-seq evidence from _A. sinensis_.

|Species        | Not expressed| Expressed| Total| Expressed out of total|
|--------------:|-------------:|---------:|-----:|----------------------:|
|_A. sinensis_    |          2475|     26728| 29203|              0.9152484|
|_Stellera_       |          9172|     21761| 30933|              0.7034882|
|_A. yunnanensis_ |          3206|     24749| 27955|              0.8853157|
|_Arabidopsis_    |          8139|     19511| 27650|              0.7056420|
|Cacao          |          2861|     18469| 21330|              0.8658697|
|Cotton         |         21511|     58628| 80139|              0.7315789|

## Discussion

The above analysis attempts to provide an overview of the state of Thymelaeaceae annotations. In short, all the published annotations have various problems, but both the _Aquilaria_ annotations are based in part on transcriptome data, and it it clear that a large proportion of the published proteins, including a number of those that OMArk classifies as `Unknown`, are plausibly expressed.

Among the published annotations I am most skeptical of the _Stellera_ annotation. It is not based on any _Stellera_ transcript data, and I think that the way it uses EVM to combine evidence is bad. The authors themselves acknowledge that 28% of their predicted genes do not match anything present in the databases they check against. It has a high proportion of OMArk `Unknown`s and a high proportion of mono-exonic genes. More than a thousand orthogroups contain proteins from both the _Aquilaria_ species, where all proteins are also classified as `Unknown` by OMArk, while close to four thousand orthogroups contain only `Unknown` _Stellera_ proteins. This means that it is unclear whether these _Stellera_ proteins being classified as `Unknown`s is a result of the proteins not being real, or is caused by a lack of coverage in the database used by OMArk.

The methods I'm using here come with very clear limitations. The small number of Thymelaeaceae annotations means that e.g. the OMArk database has gaps for these species, which means that the results reflect both the quality of the annotations, but to some extent also the quality of the database. As my focus has been on the Thymelaeaceae, there may be nuances in the cacao, cotton or _Arabidopsis_ annotations that could potentially shift some results slightly.

As I point out in the methods, counting proteins present in orthogroups where _A. sinensis_ has a protein backed by transcript evidence is a very hacky solution born out of convenience. Those results does say something about the *Aquilaria*s and cacoa, i.e., that a large proportion of their proteins end up in similar orthogroups and that these orthogroup contains _A. sinensis_ proteins with transcript evidence. What we can say is that the *Stellera*'s OMArk `Unknown`s can't be easily explained as only a result of bad database coverage -- this is yet another thing pointing to a lot of these proteins potentially being artifacts.


## References

Argout, X. et al. (2017) ‘The cacao Criollo genome v2.0: an improved version of the genome for genetic and functional genomic studies’, BMC Genomics, 18(1), pp. 1–9. Available at: https://doi.org/10.1186/s12864-017-4120-9.

Chen, C.-H. et al. (2014) ‘Identification of cucurbitacins and assembly of a draft genome for Aquilaria agallocha’, BMC genomics, 15(1), p. 578. Available at: https://doi.org/10.1186/1471-2164-15-578.

Chen, Z.J. et al. (2020) ‘Genomic diversifications of five Gossypium allopolyploid species and their impact on cotton improvement’, Nature Genetics, 52(5), pp. 525–533. Available at: https://doi.org/10.1038/s41588-020-0614-5.

Cheng, C.-Y. et al. (2017) ‘Araport11: a complete reannotation of the Arabidopsis thaliana reference genome’, The Plant Journal, 89(4), pp. 789–804. Available at: https://doi.org/10.1111/tpj.13415.

Das, A. et al. (2021) ‘Genome-wide detection and classification of terpene synthase genes in Aquilaria agallochum’, Physiology and Molecular Biology of Plants, 27(8), pp. 1711–1729. Available at: https://doi.org/10.1007/s12298-021-01040-z.

Di Tommaso, P. et al. (2017) ‘Nextflow enables reproducible computational workflows’, Nature Biotechnology, 35(4), pp. 316–319. Available at: https://doi.org/10.1038/nbt.3820.

Ding, X. et al. (2020) ‘Genome sequence of the agarwood tree Aquilaria sinensis (Lour.) Spreng: the first chromosome-level draft genome in the Thymelaeceae family’, GigaScience, 9(3), p. giaa013. Available at: https://doi.org/10.1093/gigascience/giaa013.

Emms, D.M. et al. (2025) ‘OrthoFinder: scalable phylogenetic orthology inference for comparative genomics’. Available at: https://doi.org/10.1101/2025.07.15.664860.

Hu, H. et al. (2022) ‘Genomic divergence of Stellera chamaejasme through local selection across the Qinghai–Tibet plateau and northern China’, Molecular Ecology, 31(18), pp. 4782–4796. Available at: https://doi.org/10.1111/mec.16622.

Jain, M. et al. (2008) ‘Genome-wide analysis of intronless genes in rice and Arabidopsis’, Functional & Integrative Genomics, 8(1), pp. 69–78. Available at: https://doi.org/10.1007/s10142-007-0052-9.

Li, M. et al. (2024) ‘Chromosome-level genome assembly of Aquilaria yunnanensis’, Scientific Data, 11(1), p. 790. Available at: https://doi.org/10.1038/s41597-024-03635-z.

Nevers, Y. et al. (2024) ‘Quality assessment of gene repertoire annotations with OMArk’, Nature Biotechnology, pp. 1–10. Available at: https://doi.org/10.1038/s41587-024-02147-w.

Nong, W. et al. (2020) ‘Chromosomal-level reference genome of the incense tree Aquilaria sinensis’, Molecular Ecology Resources, 20(4), pp. 971–979. Available at: https://doi.org/10.1111/1755-0998.13154.

Patel et al. (2024) ‘nf-core/rnaseq: nf-core/rnaseq v3.18.0 - Lithium Lynx’. Zenodo. Available at: https://doi.org/10.5281/ZENODO.14537300.

Pertea, G. and Pertea, M. (2020) ‘GFF Utilities: GffRead and GffCompare’, F1000Research, 9, p. 304. Available at: https://doi.org/10.12688/f1000research.23297.1.

Vuruputoor, V.S. et al. (2023) ‘Welcome to the big leaves: Best practices for improving genome annotation in non-model plant genomes’, Applications in Plant Sciences, 11(4), p. e11533. Available at: https://doi.org/10.1002/aps3.11533.

## Image attributions

The following images have been used for the poster:
- [Photo of _A. malaccensis_](https://en.wikipedia.org/wiki/File:Aqualaria_malaccensis.jpg) by Muhd Amirul Rasdey Abdullah, [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/deed.en)
- [Photo of _A. sinensis_](https://species.wikimedia.org/wiki/File:HK_Aquilaria_sinensis.JPG) by Chong Fat, [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/deed.en)
- [Photos of Stellera chamaejasme](https://www.inaturalist.org/observations/298060527) by Urgamal Magsar, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- Photos of _Wikstroemia_ by Ruben Cousins Westerberg

