include { QC_TOOL } from './modules/qc_tool/main'
include { QUALITY_CONTROL } from './subworkflows/quality_control/main'

/* AIMS
- Params defined through a single file (-params-file) rather than (-params-file and config)
- Params come in through input:
- Allow closures
- Support multi-tool args
- Support prefix - effectively closures - naming based on input: variables
Extra:
- Simplify full name vs simple name priority
- Avoid nested params
- Validate process names
*/

workflow {
    // Read in tool specific settings
    def settings = getToolSettings(params)
    // Read in data files
    data = Channel.fromPath( params.data, checkIfExists: true )
    // Outer join data with settings 
    input = data // data.combine(settings) // tuple( data, settings ) 

    println(settings)
    QC_TOOL( 
        input.map { ext_files ->
            tuple(ext_files, settings."QC_TOOL") // Simple case with no pattern match, so likely function needed.
        }
    )
    .view()

    QUALITY_CONTROL(
        input,
        getToolSettings(settings,'QUALITY_CONTROL')
    )

}

def getToolSettings(Map param_map, String wf_name = ""){
    param_map.findAll{ key, _value -> key.startsWith("withName:") || key.startsWith("${wf_name}:") }
        .collectEntries { key, value -> 
            def process_name = (key - 'withName:').replaceAll("['\"]","")
            process_name = wf_name ? process_name - "${wf_name}:" : process_name
            [(process_name): value ]
        }
}