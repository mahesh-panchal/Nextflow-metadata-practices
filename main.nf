workflow {
    // Read in meta data
    settings = Channel.fromPath( params.pipeline_profiles, checkIfExists: true )
        .map { yml_file -> new groovy.yaml.YamlSlurper()
            .parse( yml_file )
            .profiles[ params.profile ] // Select profile
        }
        // .view()
    // Read in data files
    data = Channel.fromPath( params.data, checkIfExists: true )
    // Outer join data with settings 
    input = data.combine(settings) // tuple( data, settings ) 

    QC_TOOL( 
        input.filter{ _ext, opts -> opts.qc_tool } // Keep inputs where true or "--opts ..."
            .map { ext, opts ->
                // Use ternary operator to check if tool is run with defaults, or specific options are given
                opts.qc_tool instanceof Boolean? tuple(ext, '-'): tuple(ext, opts.qc_tool) 
            }
    )
    .view()
    FILTER_TOOL( 
        input.filter{ _ext, opts -> opts.filter_tool } // Keep inputs where true or "--opts ..."
            .map { ext, opts ->
                // Use ternary operator to check if tool is run with defaults, or specific options are given
                opts.filter_tool instanceof Boolean? tuple(ext, '-'): tuple(ext, opts.filter_tool)
            }
    )
    .view()
        
}

process QC_TOOL {
    input:
    tuple path(ext), val(args)

    script:
    """
    echo "QC TOOL: $args"
    """

    output:
    stdout
}

process FILTER_TOOL {
    input:
    tuple path(ext), val(args)

    script:
    def task_args = task.ext.args ?: 'no args' // Look at nextflow.config
    """
    echo "FILTER TOOL: $task_args"
    """

    output:
    stdout
}