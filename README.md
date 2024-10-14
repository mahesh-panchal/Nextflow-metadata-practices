# Nextflow metadata practices

A demonstration of how to work with metadata in Nextflow.

One of the strengths of Nextflow is to send arbitary objects
in a channel. In particular, this means you can store a
variety of properties/attributes about a file without
encoding this into the filename.

## Types of meta data to explore

### Files with additional annotations

Files often have various kinds of data associated with them

e.g., Bam file:

```yml
bam:
  path: str
  reference:
    path: str
    id: str
    gtf: str
  region:
    chr: str
    start: int
    end: int
  strand: enum( +, -, ? )
  endedness: enum( single, paired )
```

### Profiles

Profiles are another sort of data about data. Given a setting, 
we would like to initialize a batch of associated things.

```yml
profiles:
  standard:
    fastqc: true
    fastp: true
  quick:
    fastqc: false
    fastp: '-Q'
```