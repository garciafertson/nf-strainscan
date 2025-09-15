
process metaphlan_align{
  //set directives to control
  //scratch true
  cpus '1'
  time '8h'
  maxForks 40
  container "sysbiojfgg/strainscan:v1.0.14" 
  publishDir "strainscan_out", mode: "copy"
  errorStrategy { sleep(Math.pow(2, task.attempt) * 60 as long); return 'retry' }
  maxRetries 3
  
  input:
    tuple val(x), path(fastq)
    path(database_dir)
  output:
    path ("${x.id}") , emit: strain_profile
  script:

  if(params.single_end){
  """
  strainscan -i ${fastq[0]} \\
          -d ${database_dir} \\
          -o ${x.id} \\
  """

  }else{
  """
  strainscan -i ${fastq[0]} \\
            -j ${fastq[1]} \\
           -d ${database_dir} \\
           -o "strain_${x.id}" \\
  """
  }
}


////////////
// Extract db markers
process build_db{
   //set directives
  cpus '1'
  time '4h'
  container "biobakery/metaphlan:4.0.2" 

  input:
  val(x) //sgb
  output:
  tuple val(x), path("*.fna"), emit: sgb_markers
  script:
    """
    extract_markers.py -c ${x} -o . \\
    --bowtie2db ${params.bowtie2db} 
    """
}
