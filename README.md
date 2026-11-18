# 🧬 NGS Analysis Platform

### Automated, Dockerized & Offline-Capable NGS Bioinformatics Analysis

**NGS Analysis Platform** is a Docker-based bioinformatics platform designed to automate next-generation sequencing (NGS) analysis workflows, from paired-end FASTQ files to Ensembl VEP-annotated VCF files.

The platform integrates bioinformatics tools, workflow automation, interactive R Shiny dashboards, REST API services, and containerized infrastructure into a unified analysis environment.

It is designed for local research and development environments, with the goal of simplifying complex bioinformatics workflows and improving analysis reproducibility.

## ✨ Key Features

- **Automated NGS analysis:** Process paired-end FASTQ files through an n8n-orchestrated bioinformatics workflow.
- **FASTQ quality control:** Perform quality assessment and preprocessing using FastQC and fastp.
- **Read alignment:** Align sequencing reads to the GRCh38 reference genome using BWA.
- **BAM processing:** Process aligned reads using SAMtools, Picard and GATK.
- **Variant calling:** Generate variant calls using GATK.
- **Variant annotation:** Annotate detected variants using Ensembl VEP.
- **Interactive dashboards:** Submit samples and explore variants through R ShinyDashboard interfaces.
- **REST API integration:** Convert annotated VCF files into TSV format using R Plumber.
- **Workflow automation:** Coordinate analysis processes using n8n.
- **Containerized deployment:** Run the platform using Docker and Docker Compose.
- **Offline-capable analysis:** Execute workflows without an active internet connection once the required container images, reference data and software dependencies are available locally.

## 🏗️ System Architecture

The platform consists of several interconnected Docker services.

| Service | Technology | Function |
|---|---|---|
| fqauto | R ShinyDashboard | FASTQ submission and analysis initiation |
| varint | R ShinyDashboard | Interactive variant exploration and filtering |
| tsvauto-api | R Plumber | REST API for VCF-to-TSV conversion |
| ngs-tools | Bioinformatics tools | Sequence analysis, variant calling and annotation |
| n8n | Workflow automation | Pipeline orchestration |
| nginx | Reverse proxy | Local web application routing |

The containers communicate over a Docker Compose network. n8n uses SSH to execute analysis commands in the `ngs-tools` container.

Shared analysis data is accessible at `/files` inside n8n and `/data` inside `ngs-tools`.

## 🔬 Bioinformatics Workflow

The analysis workflow includes the following stages:

1. **FASTQ Input:** Submit paired-end sequencing files.
2. **Quality Control:** Assess raw sequencing read quality.
3. **Read Preprocessing:** Perform quality filtering and trimming.
4. **Read Alignment:** Align reads against the GRCh38 reference genome.
5. **BAM Processing:** Sort, index and process alignment files.
6. **Variant Calling:** Identify genomic variants using GATK.
7. **Variant Annotation:** Annotate detected variants using Ensembl VEP.
8. **Result Processing:** Generate annotated VCF files and convert them into TSV format.
9. **Variant Exploration:** Filter and review variants through the interactive dashboard.

## 🛠️ Technology Stack

**Bioinformatics**

- FastQC
- fastp
- BWA
- SAMtools
- Picard
- GATK
- BCFtools
- Ensembl VEP
- snpEff (installed in the tools image)

**Software and Infrastructure**

- Docker / Docker Compose
- n8n
- R
- Shiny / ShinyDashboard
- R Plumber
- Nginx
- OpenSSH
- Bash
- JavaScript

## 💻 Requirements

- Docker Engine
- Docker Compose v2
- Sufficient CPU, RAM and storage for NGS analysis
- GRCh38 reference genome and required indexes
- Compatible known-sites and annotation reference data

An internet connection is required to build or download container images and obtain missing reference resources.

Resource requirements depend on the sequencing data size and analysis workload.

## 🚀 Installation

### 1. Clone the repository

```bash
git clone https://github.com/mkenankinaci/ngs-analysis-platform.git
cd ngs-analysis-platform
```

### 2. Configure the environment

If an `.env.example` file is provided, copy it to create your local configuration:

```bash
cp .env.example .env
```

Review the environment variables before starting the platform.

### 3. Start the services

```bash
docker compose up -d --build
```

Docker Compose initializes the shared data directories and starts the required application services.

On a new installation, the n8n bootstrap process prepares the SSH credential and imports the NGS analysis workflow.

### 4. Access the applications

| Application | URL |
|---|---|
| FASTQ Submission | http://fqauto.localhost |
| Variant Interpreter | http://varint.localhost |
| n8n Workflow Editor | http://localhost:5678 |
| TSV Conversion API | http://localhost:8000 |

The default published ports are bound to the local machine.

If the `.localhost` hostnames do not resolve, configure the operating system's hosts file to map them to `127.0.0.1`.

## 🧬 Reference Data

The analysis workflow uses GRCh38 reference resources.

The expected reference locations include:

```text
local_files/reference/
├── bwa/
├── known-sites/
└── vep/
```

The workflow checks for required reference resources and can download and prepare missing files during its initial execution.

Reference requirements include:

- GRCh38 reference FASTA and alignment indexes
- Compatible dbSNP known-sites data
- Ensembl VEP release 116 merged GRCh38 cache
- A compatible target BED file for interval-based analysis

Reference genome, known-sites and BED files must use compatible chromosome naming conventions.

## 📊 Output Files

Analysis results are stored in the shared `local_files` directory.

| Directory | Contents |
|---|---|
| `fastqs/` | Input sequencing files |
| `trimfastq/` | Preprocessed sequencing reads |
| `bam/` | Alignment and processed BAM files |
| `vcf/` | Variant calling and annotation outputs |
| `reports/fastqc/` | FASTQ quality reports |
| `reports/fastp/` | Read preprocessing reports |
| `logs/` | Analysis execution logs |

The n8n execution history can also be used to review workflow execution status.

## 🔄 n8n Workflow Automation

On a new installation, the bootstrap mechanism imports the workflow and its SSH credential automatically.

The existing workflow contains 17 SSH nodes used to execute bioinformatics commands in the `ngs-tools` container.

The workflow is designed to coordinate analysis tasks and manage the processing of sequencing files.

For an existing n8n installation, the workflow may be imported manually from:

`n8n/workflows/projectauto.json`

An SSH Password credential must then be configured for the `ngs-tools` service and assigned to the workflow's SSH nodes.

## 🔒 Local Deployment and Security

The platform is designed primarily for local, trusted research environments.

- Services communicate through an internal Docker Compose network.
- SSH uses an automatically generated installation-specific password.
- The SSH port is not published to the host.
- Web service ports are bound to the local loopback interface by default.
- Local environment configuration and private SSH files are excluded from Git tracking.

The current implementation uses root inside the analysis container and password-based SSH authentication. It should not be exposed to untrusted networks without additional security hardening.

## 🧰 Troubleshooting

**Containers fail to start**

```bash
docker compose ps
docker compose logs
```

**n8n workflow import fails**

```bash
docker compose logs n8n
```

Check the bootstrap output and verify that the configured n8n version supports the required CLI commands.

**SSH authentication fails**

Verify that the n8n SSH credential matches the password generated by `ngs-tools`.

**File permission errors**

Check the shared directory ownership and the configured `NGS_DATA_GID`.

**Workflow webhook returns 404**

Verify that the workflow is active and that the application uses the production webhook endpoint.

**Analysis does not complete**

Review the n8n execution history and the sample-specific terminal log in `local_files/logs/`.

## ⚠️ Intended Use

This project is intended for research, education and bioinformatics workflow development.

It has not been validated for clinical diagnostic use.

## 📄 License

A project license has not yet been selected.

Third-party bioinformatics tools, software dependencies and reference datasets remain subject to their respective licenses and usage terms.

---

**NGS Analysis Platform — Integrating bioinformatics, workflow automation and containerized software infrastructure.**
