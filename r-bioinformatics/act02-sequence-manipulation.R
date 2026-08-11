# ============================================================
# Act2. Manipulation of Biological Sequences in R
# ============================================================

# ----------------------------------------------------------
# 1. Generate a random DNA sequence of size n
# ----------------------------------------------------------
generate_dna <- function(n) {
  bases <- c("A", "T", "G", "C")
  seq <- paste(sample(bases, n, replace = TRUE), collapse = "")
  return(seq)
}

# ----------------------------------------------------------
# 2. Calculate the size of a DNA sequence
# ----------------------------------------------------------
dna_size <- function(dna) {
  return(nchar(dna))
}

# ----------------------------------------------------------
# 3. Print percentage of each base in the sequence
# ----------------------------------------------------------
base_percentage <- function(dna) {
  dna <- toupper(dna)
  total <- nchar(dna)
  bases <- c("A", "T", "G", "C")
  for (base in bases) {
    count <- nchar(gsub(paste0("[^", base, "]"), "", dna))
    pct <- round((count / total) * 100, 2)
    cat(base, ":", pct, "%\n")
  }
}

# ----------------------------------------------------------
# 4. Transcribe DNA to RNA (T -> U)
# ----------------------------------------------------------
dna_to_rna <- function(dna) {
  rna <- gsub("T", "U", toupper(dna))
  return(rna)
}

# ----------------------------------------------------------
# 5. Translate RNA to protein sequence (genetic code table)
# ----------------------------------------------------------
genetic_code <- c(
  UUU="F", UUC="F", UUA="L", UUG="L",
  CUU="L", CUC="L", CUA="L", CUG="L",
  AUU="I", AUC="I", AUA="I", AUG="M",
  GUU="V", GUC="V", GUA="V", GUG="V",
  UCU="S", UCC="S", UCA="S", UCG="S",
  CCU="P", CCC="P", CCA="P", CCG="P",
  ACU="T", ACC="T", ACA="T", ACG="T",
  GCU="A", GCC="A", GCA="A", GCG="A",
  UAU="Y", UAC="Y", UAA="*", UAG="*",
  CAU="H", CAC="H", CAA="Q", CAG="Q",
  AAU="N", AAC="N", AAA="K", AAG="K",
  GAU="D", GAC="D", GAA="E", GAG="E",
  UGU="C", UGC="C", UGA="*", UGG="W",
  CGU="R", CGC="R", CGA="R", CGG="R",
  AGU="S", AGC="S", AGA="R", AGG="R",
  GGU="G", GGC="G", GGA="G", GGG="G"
)

rna_to_protein <- function(rna) {
  rna <- toupper(rna)
  protein <- c()
  for (i in seq(1, nchar(rna) - 2, by = 3)) {
    codon <- substr(rna, i, i + 2)
    aa <- genetic_code[codon]
    if (!is.na(aa) && aa == "*") break  # stop codon
    if (!is.na(aa)) protein <- c(protein, aa)
  }
  return(paste(protein, collapse = ""))
}

# ----------------------------------------------------------
# 6. Forward strand -> Reverse strand
# ----------------------------------------------------------
reverse_strand <- function(forward) {
  rev_seq <- paste(rev(strsplit(toupper(forward), "")[[1]]), collapse = "")
  return(rev_seq)
}

# ----------------------------------------------------------
# 7. Forward strand -> Complementary strand
# ----------------------------------------------------------
complementary_strand <- function(forward) {
  forward <- toupper(forward)
  comp_map <- c(A="T", T="A", G="C", C="G")
  bases <- strsplit(forward, "")[[1]]
  comp <- paste(comp_map[bases], collapse = "")
  return(comp)
}

# ----------------------------------------------------------
# 8. Complementary strand -> Reverse complementary strand
# ----------------------------------------------------------
reverse_complement <- function(comp) {
  rev_comp <- paste(rev(strsplit(toupper(comp), "")[[1]]), collapse = "")
  return(rev_comp)
}

# ============================================================
# 9. TEST with given sequences
# ============================================================

seqs <- list(
  a = "GCGTCCACACACCATGGCACCATCGTTAGG",
  b = "TAGATAATCGCAACCTAATAACCCCCTAGTATTCCTGGACCGAGGCTGGTTCGCCCGGTA",
  c = "CATTGTCTAGAGTCTCTGACGTTAGGGTACTTCGTCATGAGGTATCGAGAGGATCATCCTTGGAGTGCGTTATAACCTCTCGTGGTCGCG"
)

for (name in names(seqs)) {
  dna <- seqs[[name]]
  cat("\n==============================\n")
  cat("Sequence", name, ":", dna, "\n")
  cat("Size:", dna_size(dna), "\n")
  cat("Base percentages:\n"); base_percentage(dna)
  rna <- dna_to_rna(dna)
  cat("RNA:", rna, "\n")
  cat("Protein:", rna_to_protein(rna), "\n")
  cat("Reverse strand:", reverse_strand(dna), "\n")
  comp <- complementary_strand(dna)
  cat("Complementary strand:", comp, "\n")
  cat("Reverse complementary:", reverse_complement(comp), "\n")
}

