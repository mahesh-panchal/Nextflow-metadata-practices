workflow {
    // Read in meta data
    settings = Channel.fromPath( params.pipeline_profiles, checkIfExists: true )
        .map { yml_file -> new groovy.yaml.YamlSlurper()
            .parse( yml_file )
            .profiles[ params.profile ] // Select profile
        }
        // .view()
    data = Channel.fromPath( params.data, checkIfExists: true )
    input = data.combine(settings)

    QC_TOOL( 
        input.filter{ ext, settings -> settings.qc_tool } 
            .map { ext, settings ->
                settings.qc_tool instanceof Boolean? tuple(ext, '-'): tuple(ext, settings.qc_tool) 
            }
    )
    .view()
    FILTER_TOOL( 
        input.filter{ ext, settings -> settings.filter_tool } 
            .map { ext, settings ->
                settings.filter_tool instanceof Boolean? tuple(ext, '-'): tuple(ext, settings.filter_tool)
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
    """
    echo "FILTER TOOL: $args"
    """

    output:
    stdout
}