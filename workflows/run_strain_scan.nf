/*
General workflow, assembly SRA-NCBI-id_samples included in text list
*/

//import modules
include {strain_scan} from  "../modules/strain_scan"
include {merge_results} from "../modules/strain_scan"
include {fastp} from "../modules/clean_reads"


workflow STRAIN_SCAN {
      Channel
      .fromFilePairs(params.input, size: params.single_end ? 1 : 2)
      .ifEmpty { exit 1, "Cannot find any reads matching: ${params.input}\nNB: Path needs to be enclosed in quotes!\nIf this is single-end data, please specify --single_end on the command line." }
      .map { row ->
                  def meta = [:]
                  meta.id           = row[0]
                  meta.group        = 0
                  meta.single_end   = params.single_end
                  return [ meta, row[1] ]
                }
      .set { ch_raw_short_reads }

    fastp{ch_raw_short_reads}
    clean_reads=fastp.out.reads

  // Define the database directory
    dbfolder = Channel.value(file("${params.database_dir}")) 
    strain_scan(clean_reads, dbfolder)
    strain_profile=strain_scan.out.strain_profile.collect()
    //merge_results(strain_profile)
    merge_results(strain_profile)

}

