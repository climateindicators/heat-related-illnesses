# Build tidy long-format data for the Heat-Related Illnesses indicator.
#
#   Rscript R/build_data.R
#
# Reads EPA's published figure CSVs in data-raw/ and writes data/*.csv plus
# data/meta.yml. Rerunning with unchanged inputs produces byte-identical output.
# Nothing here touches the network.
#
# Generated as a stub by the build-indicator skill. Each figure below has a
# `todo_reshape()` call standing where its reshape belongs. Replace that line,
# then delete the todo_reshape() helper once no call to it remains.
#
# TO UPDATE THE DATA: drop replacement CSVs into data-raw/ and rerun. Headers
# are asserted, not assumed, so a renamed or reordered column stops the build.

suppressPackageStartupMessages({
  library(dplyr)
})

root <- here::here()
source(file.path(root, "R/utils/epa_csv.R"))
source(file.path(root, "R/utils/write_stable.R"))

raw_dir <- file.path(root, "data-raw")
out_dir <- file.path(root, "data")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

todo_reshape <- function(n) {
  stop(
    "R/build_data.R: the reshape for figure ", n, " has not been written yet.\n",
    "Replace the todo_reshape(", n, ") call with the pivot that produces the tidy\n",
    "long-format data frame for that figure, then remove this helper.",
    call. = FALSE
  )
}

# ---- Indicator constants -----------------------------------------------------

INDICATOR <- list(
  name                    = "Heat-Related Illnesses",
  slug                    = "heat-related-illness-new",
  publisher               = "U.S. Environmental Protection Agency",
  source_page             = "https://19january2025snapshot.epa.gov/climate-indicators/heat-related-illnesses/index.html",
  technical_documentation = "https://19january2025snapshot.epa.gov/sites/default/files/2021-03/documents/heat-illness_tech-doc.pdf",
  rights                  = "Public domain, work of the U.S. Government (17 U.S.C. 105)"
)

# ---- Figure 1: Heat-Related Hospitalizations in 20 States, 2001–2010 ----

f1_path <- file.path(raw_dir, "heat-illnesses_fig-1.csv")
f1_meta <- read_epa_preamble(f1_path)
f1_raw  <- read_epa_csv(f1_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f1_raw,
  id_cols          = character(),
  expected_headers = c("Year", "Hospitalizations per 100,000 people"),
  what             = "heat-illnesses_fig-1.csv"
)

# TODO reshape: 10 rows, Year + 1 series.
# Source headers: Year | Hospitalizations per 100,000 people
# Units line: number of hospitalizations per 100,000 people
# Produce a tidy long-format data frame. Keep every value as character: the
# source carries up to 10 significant digits and must survive byte for byte.
f1 <- todo_reshape(1)

# The output name below is a placeholder. Rename it for what the figure
# actually carries, the way river_flooding_magnitude.csv does.
write_csv_stable(f1, file.path(out_dir, "heat_related_illness_new_fig1.csv"))

# ---- Figure 2: Average Rate of Heat-Related Hospitalizations in 23 States, 2001-2010 ----

f2_path <- file.path(raw_dir, "heat-illnesses_fig-2.csv")
f2_meta <- read_epa_preamble(f2_path)
f2_raw  <- read_epa_csv(f2_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f2_raw,
  id_cols          = character(),
  expected_headers = c("State", "2001-2010 average"),
  what             = "heat-illnesses_fig-2.csv"
)

# TODO reshape: 23 rows, State + 1 series.
# Source headers: State | 2001-2010 average
# Units line: average annual rate of hospitalizations per 100,000 people
# Produce a tidy long-format data frame. Keep every value as character: the
# source carries up to 10 significant digits and must survive byte for byte.
f2 <- todo_reshape(2)

# The output name below is a placeholder. Rename it for what the figure
# actually carries, the way river_flooding_magnitude.csv does.
write_csv_stable(f2, file.path(out_dir, "heat_related_illness_new_fig2.csv"))

# ---- Figure 3: Heat-Related Hospitalizations in 20 States by Sex and Age, 2001–2010 ----

f3_path <- file.path(raw_dir, "heat-illnesses_fig-3.csv")
f3_meta <- read_epa_preamble(f3_path)
f3_raw  <- read_epa_csv(f3_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f3_raw,
  id_cols          = character(),
  expected_headers = c("Group", "Number of hospitalizations reported"),
  what             = "heat-illnesses_fig-3.csv"
)

# TODO reshape: 7 rows, Group/Number of hospitalizations reported.
# Source headers: Group | Number of hospitalizations reported
# Units line: total number of hospitalizations
# Produce a tidy long-format data frame. Keep every value as character: the
# source carries up to 10 significant digits and must survive byte for byte.
f3 <- todo_reshape(3)

# The output name below is a placeholder. Rename it for what the figure
# actually carries, the way river_flooding_magnitude.csv does.
write_csv_stable(f3, file.path(out_dir, "heat_related_illness_new_fig3.csv"))

# ---- Data dictionary ---------------------------------------------------------

col <- function(name, type, description) {
  list(name = name, type = type, description = description)
}

# One entry per output column, in order, filled from the data frame itself so it
# cannot drift. `type` and `description` are deliberately blank: tests/test-data.R
# fails while either is empty, so every column has to be documented by hand.
describe <- function(df) lapply(names(df), function(nm) col(nm, "", ""))

meta <- list(
  indicator = INDICATOR,
  datasets = list(
    list(
      file            = "heat_related_illness_new_fig1.csv",
      figure          = "Figure 1",
      figure_title    = f1_meta$title,
      source_file     = "heat-illnesses_fig-1.csv",
      source_sha256   = file_sha256(f1_path),
      source_encoding = "windows-1252",
      data_source     = f1_meta$data_source,
      web_update      = f1_meta$web_update,
      unit            = f1_meta$units,
      rows            = nrow(f1),
      columns         = describe(f1)
    ),
    list(
      file            = "heat_related_illness_new_fig2.csv",
      figure          = "Figure 2",
      figure_title    = f2_meta$title,
      source_file     = "heat-illnesses_fig-2.csv",
      source_sha256   = file_sha256(f2_path),
      source_encoding = "UTF-8",
      data_source     = f2_meta$data_source,
      web_update      = f2_meta$web_update,
      unit            = f2_meta$units,
      rows            = nrow(f2),
      columns         = describe(f2)
    ),
    list(
      file            = "heat_related_illness_new_fig3.csv",
      figure          = "Figure 3",
      figure_title    = f3_meta$title,
      source_file     = "heat-illnesses_fig-3.csv",
      source_sha256   = file_sha256(f3_path),
      source_encoding = "windows-1252",
      data_source     = f3_meta$data_source,
      web_update      = f3_meta$web_update,
      unit            = f3_meta$units,
      rows            = nrow(f3),
      columns         = describe(f3)
    )
  )
)

write_yaml_stable(meta, file.path(out_dir, "meta.yml"))

# ---- Verify what was written -------------------------------------------------

written <- list.files(out_dir, pattern = "[.](csv|yml)$", full.names = TRUE)
invisible(lapply(written, assert_clean_output))

cat("\nWrote:\n")
for (p in written) {
  cat(sprintf("  %-34s %8d bytes  %s\n", basename(p), file.size(p), substr(file_sha256(p), 1, 12)))
}
