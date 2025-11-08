/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { SUBREAD_FEATURECOUNTS  } from '../modules/nf-core/subread/featurecounts/main'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow FC {

    take:
    ch_samplesheet // channel: samplesheet read in from --input
    
    main:
    ch_versions = channel.empty()

    ch_fc_in = ch_samplesheet.map { meta, bam_path, gtf_path ->
        tuple(
            meta,
            file(bam_path, checkIfExists: true),
            file(gtf_path, checkIfExists: true)
        )
    }
    SUBREAD_FEATURECOUNTS(ch_fc_in)

    // versions del módulo → mezclar en ch_versions
    ch_versions = ch_versions.mix(SUBREAD_FEATURECOUNTS.out.versions)

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name:  'fc_software_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { _ch_collated_versions }


    emit:
    counts   = SUBREAD_FEATURECOUNTS.out.counts
    summary  = SUBREAD_FEATURECOUNTS.out.summary
    versions       = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
