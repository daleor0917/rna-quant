//
// Check input samplesheet and get BAM/GTF channels
//

workflow INPUT_CHECK {
    take:
    samplesheet // channel: path to samplesheet file

    main:
    
    parsed_samplesheet = samplesheet
        .splitCsv(header: true, strip: true)
        .map { row -> validate_and_transform_row(row) }
        .groupTuple(by: 0)
        .map { sample, bams, gtfs ->
            def meta = [
                id: sample,
                single_end: true
            ]

            if (bams.size() > 1) {
                error "More than one row has sample ID '${sample}'. Sample IDs must be unique."
            }

            return [meta, file(bams[0], checkIfExists: true), file(gtfs[0], checkIfExists: true)]
        }

    emit:
    reads     = parsed_samplesheet      // channel: [ val(meta), path(bam), path(gtf) ]
    versions  = channel.empty()         // channel: [ versions.yml ]
}

// Function to validate each row
def validate_and_transform_row(LinkedHashMap row) {
    // Validate sample field
    if (!row.sample) {
        error "Missing 'sample' field in samplesheet. All rows must have a valid 'sample' value."
    }
    def sample_id = row.sample.replaceAll(' ', '_')
    
    // Validate BAM field
    if (!row.bam) {
        error "Sample '${row.sample}' is missing the BAM file."
    }
    
    // Validate GTF field
    if (!row.gtf) {
        error "Sample '${row.sample}' is missing the GTF file."
    }

    return [sample_id, row.bam, row.gtf]
}