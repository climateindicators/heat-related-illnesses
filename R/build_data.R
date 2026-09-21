# Build tidy long-format data for the Heat-Related Illnesses indicator.
#
#   Rscript R/build_data.R
#
# Reads EPA's published figure CSVs in data-raw/ and writes data/*.csv plus
# data/meta.yml. Rerunning with unchanged inputs produces byte-identical output.
# Nothing here touches the network.
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

# This source file is already tidy: one row per year, carrying the annual
# hospitalization rate across the 20-state group. There is no wide-to-long
# pivot, so the reshape only names what the bare value column measures.
assert_headers(
  f1_raw,
  id_cols          = "Year",
  expected_headers = "Hospitalizations per 100,000 people",
  what             = "heat-illnesses_fig-1.csv"
)

f1_split <- split_value_flag(f1_raw[["Hospitalizations per 100,000 people"]])

f1 <- f1_raw |>
  dplyr::transmute(
    year    = as.integer(Year),
    measure = "annual_hospitalization_rate",
    unit    = f1_meta$units,
    value   = f1_split$value,
    flag    = f1_split$flag
  )

write_csv_stable(f1, file.path(out_dir, "heat_illness_annual_rate.csv"))

# ---- Figure 2: Average Rate of Heat-Related Hospitalizations in 23 States, 2001-2010 ----

f2_path <- file.path(raw_dir, "heat-illnesses_fig-2.csv")
f2_meta <- read_epa_preamble(f2_path)
f2_raw  <- read_epa_csv(f2_path)

# Already tidy: one row per state, carrying its 2001-2010 average rate.
assert_headers(
  f2_raw,
  id_cols          = "State",
  expected_headers = "2001-2010 average",
  what             = "heat-illnesses_fig-2.csv"
)

f2_split <- split_value_flag(f2_raw[["2001-2010 average"]])

f2 <- f2_raw |>
  dplyr::transmute(
    state   = State,
    measure = "average_annual_rate_2001_2010",
    unit    = f2_meta$units,
    value   = f2_split$value,
    flag    = f2_split$flag
  )

write_csv_stable(f2, file.path(out_dir, "heat_illness_rate_by_state.csv"))

# ---- Figure 3: Heat-Related Hospitalizations in 20 States by Sex and Age, 2001–2010 ----

f3_path <- file.path(raw_dir, "heat-illnesses_fig-3.csv")
f3_meta <- read_epa_preamble(f3_path)
f3_raw  <- read_epa_csv(f3_path)

assert_headers(
  f3_raw,
  id_cols          = "Group",
  expected_headers = "Number of hospitalizations reported",
  what             = "heat-illnesses_fig-3.csv"
)

# EPA's Group column packs two independent breakdowns of the same 20-state,
# 2001-2010 total into one axis: by sex (Male, Female) and by age group (0-4
# through 65+). group_type keeps the two apart so they are never summed
# together as if they were seven peers of each other; the totals genuinely
# differ (28,133 by sex vs. 28,119 by age in EPA's own published figures).
FIG3_GROUPS <- tibble::tribble(
  ~source_header, ~group_key,    ~group_label, ~group_type,
  "Male",         "male",        "Male",       "sex",
  "Female",       "female",      "Female",     "sex",
  "0-4",          "age_0_4",     "0-4",        "age",
  "5-14",         "age_5_14",    "5-14",       "age",
  "15-34",        "age_15_34",   "15-34",      "age",
  "35-64",        "age_35_64",   "35-64",      "age",
  "65+",          "age_65_plus", "65+",        "age"
)

stopifnot(
  "figure 3: every Group value is a recognised sex or age category" =
    all(f3_raw$Group %in% FIG3_GROUPS$source_header),
  "figure 3: no duplicate Group values" = !any(duplicated(f3_raw$Group))
)

f3_split <- split_value_flag(f3_raw[["Number of hospitalizations reported"]])
f3_idx   <- match(f3_raw$Group, FIG3_GROUPS$source_header)

f3 <- f3_raw |>
  dplyr::transmute(
    group_key   = FIG3_GROUPS$group_key[f3_idx],
    group_label = FIG3_GROUPS$group_label[f3_idx],
    group_type  = FIG3_GROUPS$group_type[f3_idx],
    measure     = "total_hospitalizations_2001_2010",
    unit        = f3_meta$units,
    value       = f3_split$value,
    flag        = f3_split$flag
  )

write_csv_stable(f3, file.path(out_dir, "heat_illness_by_sex_and_age.csv"))

# ---- Data dictionary ---------------------------------------------------------

col <- function(name, type, description) {
  list(name = name, type = type, description = description)
}

flag_col_note <- paste(
  "Empty for an ordinary observation. A non-empty flag would mean the source",
  "withheld the value (e.g. a disclosure-threshold suppression); `value` is",
  "empty whenever `flag` is set. No source row in this data update is flagged."
)

meta <- list(
  indicator = INDICATOR,
  datasets = list(
    list(
      file            = "heat_illness_annual_rate.csv",
      figure          = "Figure 1",
      figure_title    = f1_meta$title,
      source_file     = "heat-illnesses_fig-1.csv",
      source_sha256   = file_sha256(f1_path),
      source_encoding = f1_meta$encoding,
      data_source     = f1_meta$data_source,
      web_update      = f1_meta$web_update,
      unit            = f1_meta$units,
      rows            = nrow(f1),
      columns = list(
        col("year", "integer", "Calendar year."),
        col("measure", "string", "What the `value` column measures."),
        col("unit", "string", "Unit of `value`, taken from the source file's own Units line."),
        col("value", "number", "Annual hospitalization rate across the 20-state group, verbatim from the source file."),
        col("flag", "string", flag_col_note)
      ),
      note = paste(
        "20 states participating in CDC's hospitalization tracking program.",
        "Rate is age-adjusted and covers May 1-September 30 of each year."
      )
    ),
    list(
      file            = "heat_illness_rate_by_state.csv",
      figure          = "Figure 2",
      figure_title    = f2_meta$title,
      source_file     = "heat-illnesses_fig-2.csv",
      source_sha256   = file_sha256(f2_path),
      source_encoding = f2_meta$encoding,
      data_source     = f2_meta$data_source,
      web_update      = f2_meta$web_update,
      unit            = f2_meta$units,
      rows            = nrow(f2),
      columns = list(
        col("state", "string", "U.S. state name, verbatim from the source file."),
        col("measure", "string", "What the `value` column measures."),
        col("unit", "string", "Unit of `value`, taken from the source file's own Units line."),
        col("value", "number", "2001-2010 average hospitalization rate for that state, verbatim from the source file."),
        col("flag", "string", flag_col_note)
      ),
      note = "23 states participating in CDC's hospitalization tracking program. EPA published this figure as a map."
    ),
    list(
      file            = "heat_illness_by_sex_and_age.csv",
      figure          = "Figure 3",
      figure_title    = f3_meta$title,
      source_file     = "heat-illnesses_fig-3.csv",
      source_sha256   = file_sha256(f3_path),
      source_encoding = f3_meta$encoding,
      data_source     = f3_meta$data_source,
      web_update      = f3_meta$web_update,
      unit            = f3_meta$units,
      rows            = nrow(f3),
      columns = list(
        col("group_key", "string", "Machine-readable group identifier."),
        col("group_label", "string", "Display label, verbatim from the source file's Group column."),
        col("group_type", "string", "Which of EPA's two independent breakdowns this row belongs to: \"sex\" or \"age\". The two breakdowns are separate totals of the same underlying hospitalizations and should not be summed together across types."),
        col("measure", "string", "What the `value` column measures."),
        col("unit", "string", "Unit of `value`, taken from the source file's own Units line."),
        col("value", "number", "Total hospitalizations, 2001-2010, verbatim from the source file."),
        col("flag", "string", flag_col_note)
      ),
      note = paste(
        "20 states participating in CDC's hospitalization tracking program.",
        "The sex total (28,133) and the age total (28,119) differ by 14",
        "hospitalizations in EPA's own published figures; this is EPA's data,",
        "not a build error."
      )
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
