# NGS Bioinformatics Platform

This Docker Compose project stages paired-end FASTQ files, orchestrates a GRCh38 analysis with n8n, and provides web interfaces for submitting samples and reviewing variants.

| Service | Role |
| --- | --- |
| fqauto | R Shiny upload and analysis submission |
| varint | R Shiny variant review |
| tsvauto-api | R Plumber VCF-to-TSV conversion |
| ngs-tools | fastp, FastQC, BWA, SAMtools, GATK and Ensembl VEP |
| n8n | Workflow orchestration and SSH client |
| nginx | Routes browser requests to the Shiny services |

Compose supplies a shared network. The workflow checks files from n8n at `/files` and runs analysis commands as `root` over SSH at `ngs-tools:22`. The tools container sees the same files at `/data`. SSH uses a per-installation password and its port is available only on the Compose network. The VEP cache is also mounted at `/root/.vep` in the tools container.

## Requirements

Use Docker Engine with Compose v2. Allocate storage for the GRCh38 FASTA and BWA indexes, dbSNP, the VEP cache, and intermediate sample outputs. An internet connection is required for image builds and reference downloads.

## Setup

From the project root:

```bash
docker compose up -d --build
```

Compose prepares the shared data directories before starting the application services. The tools container generates an SSH password and stores it in a named volume so it survives container recreation. A local `.env` is optional. See `.env.example` for overrides. The default ports bind to loopback.

| Interface | Address |
| --- | --- |
| FASTQ submission | http://fqauto.localhost |
| Variant review | http://varint.localhost |
| n8n | http://localhost:5678 |
| TSV API | http://localhost:8000 |

If your browser does not resolve the Shiny hostnames, map both names to `127.0.0.1` in the operating system's hosts file.

## First launch in n8n

With a new n8n volume, Compose imports the workflow and its SSH credential, then publishes the workflow before starting n8n. Automatic publishing uses the n8n 2.x server CLI. The bootstrap records completion alongside the database and skips subsequent imports. It also skips databases from existing installations. If an import is interrupted, Compose can retry it with the same IDs before starting n8n.

Open fqauto and submit one paired-end sample. Use distinct R1 and R2 filenames, a GRCh38 BED file, and a unique sample name. Use ASCII letters, digits, dots, underscores, and hyphens in names, beginning with a letter or digit.

To open the n8n editor for troubleshooting or workflow changes, complete the local owner-account setup on first access.

For an existing n8n database without the workflow, import `n8n/workflows/projectauto.json` through the UI. Create an **SSH Password** credential using host `ngs-tools`, port `22`, username `root`, and the password shown by `docker compose exec -T ngs-tools cat /run/ngs-credentials/password`. Assign it to the 17 SSH nodes before publishing.

## Reference data and output

The workflow checks for GRCh38 FASTA files and indexes in `local_files/reference/bwa`, dbSNP138 in `local_files/reference/known-sites`, and Ensembl VEP release 116 merged GRCh38 cache in `local_files/reference/vep`. The first run can download and prepare missing references. Start with a single job while preparing shared references. Use matching contig names across FASTA, known sites, and BED files.

Check the n8n execution history and `local_files/logs/<sample>_terminal.log`. Inspect `reports/fastp`, `reports/fastqc`, `bam`, and `vcf` under `local_files` for stage outputs.

## Troubleshooting

- If the initial import fails, check `docker compose logs n8n` and restart n8n after correcting the reported error.

- If n8n cannot find Execute Command, verify that the running container has `NODES_EXCLUDE=[]` and that the selected n8n release supports the node.
- If SSH authentication fails, check `docker compose logs ngs-tools`, confirm the credential matches the active password in the tools container, and check that every SSH node selects it. After changing the password, recreate the tools container and update the n8n credential.
- If file writes fail, check the configured shared GID (default `1000`, overridable via `NGS_DATA_GID`) and the ownership and modes of shared directories and existing files. Start with an empty local data tree when validating a fresh install.
- If the webhook returns 404, verify that the workflow is active and that fqauto is using the production webhook path.
- For an initial smoke test, run `docker compose ps`, test the SSH credential in n8n, and verify a small paired-end run produces both trimmed reads and an annotated VCF.

## License

The project license has yet to be selected. Third-party tools and reference data retain their own terms.
