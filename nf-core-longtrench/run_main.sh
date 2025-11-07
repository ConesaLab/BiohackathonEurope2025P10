module load anaconda 
mamba activate nextflow
cd nf-core-longtrench/


## [detached from 3268082.pts-8.master]
# running the test dataset
srun --ntasks 2 --mem-per-cpu 4G --cpus-per-task 2 --qos short nextflow run main.nf  -profile singularity \
                    --input assets/samplesheet_test_PacBio.csv \
                    --outdir output_test_PacBio \
                    --fasta /home/julensan/references/Homo_sapiens-GRCh38/Homo_sapiens.GRCh38.dna.primary_assembly.fa \
                    --gtf /home/julensan/references/Homo_sapiens-GRCh38/Homo_sapiens.GRCh38.99.gtf \
                    --technology PacBio -resume -bg