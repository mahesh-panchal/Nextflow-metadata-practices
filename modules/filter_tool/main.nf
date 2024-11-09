process FILTER_TOOL {
    input:
    tuple path(ext), val(args)

    script:
    def task_args = task.ext.args ?: 'no args'
    // Look at nextflow.config
    """
    echo "${task.process}: ${task_args}"
    """

    output:
    stdout 

}
