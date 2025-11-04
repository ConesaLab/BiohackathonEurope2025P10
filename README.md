# BiohackathonEurope2025P10

Scripts developed for Biohackathon Europe 2025 Project 10

# Important links

* LRGASP online benchmarking platform
  
    URL: http://longbench.uv.es/
  
    Code: https://github.com/ConesaLab/LongTREC_LRGASP_Platform

# Datasets



# Tools


## Using Reference Annotation

* [IsoSeq](https://github.com/PacificBiosciences/IsoSeq)

Long-read data: Pacbio

Container: NA

Conda installation: https://anaconda.org/bioconda/isoseq

Notes: The utilization of the reference annotation is at the last step, to call different isoforms of the same gene.


* [Isosceles](https://github.com/Genentech/Isosceles)

Long-read data: Pacbio and ONT

Container: Singularity image https://zenodo.org/records/10951160

Conda installation: NA

Notes: This is an R package.



* [ESPRESSO](https://github.com/Xinglab/espresso)

Long-read data: Pacbio and ONT

Container: https://hub.docker.com/r/xinglab/espresso

Conda installation: https://anaconda.org/bioconda/espresso

Notes: Snakemake pipeline also avalable.



* [RATTLE](https://github.com/comprna/RATTLE)

Long-read data: ONT

Container: NA

Conda installation: NA

Notes: Snakemake pipeline available. Binary compiled on Ubuntu 18.04.1 on an i7-7500U processor available at https://zenodo.org/records/6578778



## Not Using Reference Annotation

* [isONclust3](https://github.com/aljpetri/isONclust3)

Long-read data: Pacbio and ONT

Container: NA

Conda installation: https://anaconda.org/hcc/isonclust3

Notes: The installation of isONclust3 requires users to install the Rust programming language onto their system.


* [Freddie](https://github.com/vpc-ccg/freddie)

Long-read data: ONT

Container: NA

Conda installation: https://anaconda.org/bioconda/freddie

Notes: Snakemake pipeline also available. Freddie's clustering stage uses Gurobi Solver, which requires a license to use. For academics, a cost-free license is available upon registration: https://www.gurobi.com/downloads/end-user-license-agreement-academic/


## Optional Use of Reference Annotation


* [IsoQuant](https://github.com/ablab/IsoQuant)

Long-read data: Pacbio and ONT

Container: NA

Conda installation: https://anaconda.org/bioconda/isoquant

Notes:


* [Bambu](https://github.com/GoekeLab/bambu)

Long-read data: Pacbio and ONT

Container: NA

Conda installation: https://anaconda.org/bioconda/bioconductor-bambu

Notes: This is an R package, installation from Bioconductor. Beta for sc/spatial RNA-seq here: https://github.com/GoekeLab/bambu-singlecell-spatial



* [FLAIR2](https://github.com/BrooksLabUCSC/flair)

Container: https://hub.docker.com/r/brookslab/flair

Conda installation: https://anaconda.org/bioconda/flair

Notes: 


* [StringTie3](https://github.com/gpertea/stringtie)

Container: https://depot.galaxyproject.org/singularity/stringtie%3A3.0.1--h00789bb_0

Conda installation: https://anaconda.org/bioconda/stringtie

Notes:







