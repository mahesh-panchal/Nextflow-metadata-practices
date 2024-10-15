# Nextflow metadata practices

A demonstration of how to work with metadata in Nextflow.

One of the strengths of Nextflow is to send arbitary objects
in a channel. In particular, this means you can store a
variety of properties/attributes about a file without
encoding this into the filename.

## The practice

Nextflow is based on the principle of streaming data through
channels. However passing everything as input to a process
can cause caching issues as any items storing meta data will
inevitiably change the objects passed to processes. The way to
resolve this is to only pass the information you require into
your process using the `map` operator. Similarly you need to
transform any information produced by a process back into the
objects passing through the workflow streams ( `Channel`s ).

```nextflow
workflow {
    ...

    ch_task_input = ch_upstream.filter { meta, files -> files.every{ fn -> fn.endsWith('.gz') } }
        .map { meta, files -> tuple( meta.subMap(['id', 'group', 'cohort']), files, meta.reference ) }

    TASK( ch_task_input ) 

    ch_scatter = TASK.out.split_files
        .flatMap { meta, files, regions -> 
            regions.tokenize(',')
                .withIndex()
                .collect{ range, index -> 
                    def (start, stop) = range.split("-")
                    tuple( meta + [start: start, stop: stop], files[index] )
                }
        }
}
```

These manipulations though can make the code difficult to read and see the overall
picture. Complex operations can be tucked away under a descriptive function name
to help reduce code duplication and help with readability.

```nextflow
// Restructures input stream suitable for the process TASK
def to_task_input( ch_input_stream ){
    ch_input_stream.filter { meta, files -> files.every{ fn -> fn.endsWith('.gz') } }
        .map { meta, files -> tuple( meta.subMap(['id', 'group', 'cohort']), files, meta.reference ) }
}

// Restructures output stream for downstream tasks
def scatter_split_files ( ch_output_stream ) {
    ch_output_stream
        .flatMap { meta, files, regions -> 
            regions.tokenize(',')
                .withIndex()
                .collect{ range, index -> 
                    def (start, stop) = range.split("-")
                    tuple( meta + [start: start, stop: stop], files[index] )
                }
        }
}
```

So your code looks more like:

```nextflow
include { to_task_input } from "./modules/local/task"
include { scatter_split_files } from "./modules/local/task"
include { TASK } from "./modules/local/task"

workflow {
    ...
    TASK ( to_task_input( ch_upstream ) )

    ch_scatter = scatter_split_files( TASK.out.split_files )
}
```

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