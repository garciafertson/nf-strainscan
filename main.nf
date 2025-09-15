// main workflow assembly SRA using megahit

nextflow.enable.dsl=2
include { STRAIN_SCAN } from './workflows/run_strain_scan.nf'

//run assembly pipeline
workflow NF_STRAIN_SCAN {
    STRAIN_SCAN()
}

//WORKFLOW: Execute a single named workflow for the pipeline
workflow {
    NF_STRAIN_SCAN()
}
