module load anaconda 
mamba activate nextflow
cd nf-core-longtrench/
# running the test dataset
srun --ntasks 2 --mem-per-cpu 20G --cpus-per-task 13 --qos short nextflow run main.nf  -profile singularity \
                    --input assets/samplesheet_test.csv \
                    --outdir output_test \
                    --fasta /home/julensan/references/Homo_sapiens-GRCh38/Homo_sapiens.GRCh38.dna.primary_assembly.fa \
                    --gtf /home/julensan/references/Homo_sapiens-GRCh38/Homo_sapiens.GRCh38.99.gtf \
                    --technology ONT -resume -bg