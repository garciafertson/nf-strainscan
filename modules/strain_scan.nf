
process strain_scan{
  //set directives to control
  //scratch true
  cpus '1'
  time '8h'
  maxForks 40
  container "sysbiojfgg/strainscan:v1.0.14" 
  //publishDir "strainscan_out", mode: "copy"
  errorStrategy { sleep(Math.pow(2, task.attempt) * 60 as long); return 'retry' }
  maxRetries 3
  
  input:
    tuple val(x), path(fastq)
    path(database_dir)
  output:
    tuple val(x), path ("${x.id}.txt") , emit: strain_profile
  script:

  if(params.single_end){
  """
  strainscan -i ${fastq[0]} \\
          -d ${database_dir} \\
          -o strain_${x.id} 
  mv strain_${x.id}/final_report.txt ${x.id}.txt
  """

  }else{
  """
  strainscan -i ${fastq[0]} \\
            -j ${fastq[1]} \\
           -d ${database_dir} \\
           -o "strain_${x.id}" 
  mv strain_${x.id}/final_report.txt ${x.id}.txt  
  """
  }
}


////////////
// Extract db markers
process merge_results{
   //set directives
  cpus '1'
  time '4h'
  container "sysbiojfgg/strainscan:v1.0.14" 
  publishDir "strainscan_out", mode: "copy"

  input:
  path(strain_profile)
  output:
  path("strainscan_merged.tsv"), emit: merged

  script:
    """
    merge_results.py -i ${strain_profile} -o strainscan_merged.tsv \\
    """
}
