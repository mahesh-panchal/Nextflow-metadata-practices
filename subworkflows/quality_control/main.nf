include { QC_TOOL } from '../../modules/qc_tool/main'
include { FILTER_TOOL } from '../../modules/filter_tool/main'

workflow QUALITY_CONTROL {

    take:
    input // data (*.ext) 
    settings

    main:
    println(settings)
    QC_TOOL( 
        input.map { ext -> tuple(ext, settings."QC_TOOL") }
    )
    .view()
    FILTER_TOOL( 
        input.map { ext -> tuple(ext, settings."FILTER_TOOL") }
    )
    .view()
        
}
