/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { SUBREAD_FEATURECOUNTS  } from '../modules/nf-core/subread/featurecounts/main'
include { SAMTOOLS_INDEX         } from '../modules/nf-core/samtools/index/main'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { INPUT_CHECK            } from '../subworkflows/local/inputcheck'

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
    ch_multiqc_files = channel.empty()

    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    INPUT_CHECK(ch_samplesheet)
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)

    //
    // MODULE: Index BAM files with samtools
    //
    INPUT_CHECK.out.reads
        .map { meta, bam, _gtf_file -> tuple(meta, bam) }
        .set { ch_bam_for_index }
    
    SAMTOOLS_INDEX(ch_bam_for_index)
    ch_versions = ch_versions.mix(SAMTOOLS_INDEX.out.versions.first())

    //
    // MODULE: Run featureCounts
    //
    INPUT_CHECK.out.reads
        .set { ch_fc_in }
    
    SUBREAD_FEATURECOUNTS(ch_fc_in)
    ch_versions = ch_versions.mix(SUBREAD_FEATURECOUNTS.out.versions.first())
    ch_multiqc_files = ch_multiqc_files.mix(SUBREAD_FEATURECOUNTS.out.summary.collect{ _meta, file -> file }.ifEmpty([]))

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name:  'fc_software_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }

    //
    // MODULE: MultiQC
    //
    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    
    MULTIQC(
        ch_multiqc_files.collect(),
        channel.of([]),                    // config
        channel.of([]),                    // extra_multiqc_config  
        channel.of([]),                    // logo
        channel.of([]),                    // methods_description
        channel.of([])                     // software_versions
    )

    emit:
    counts      = SUBREAD_FEATURECOUNTS.out.counts
    summary     = SUBREAD_FEATURECOUNTS.out.summary
    bam_index   = SAMTOOLS_INDEX.out.bai
    multiqc     = MULTIQC.out.report.toList()
    versions    = ch_versions

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/