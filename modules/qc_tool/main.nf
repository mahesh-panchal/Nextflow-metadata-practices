process QC_TOOL {
    input:
    tuple path(ext), val(args)

    script:
    // Evaluating closures doesn't work. It loses the context somehow and I don't know how to get it back.
    def task_args = args instanceof Closure ? args.call(): args.startsWith('{') ? new GroovyShell( this.binding ).evaluate(args) : args
    """
    echo "${task.process}: $task_args"
    """

    output:
    stdout
}
