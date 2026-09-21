# Regression checks on the generated data for the Heat-Related Illnesses indicator.
#
#   Rscript tests/test-data.R
#
# The checks below are shape-independent: they hold whatever the reshape in
# R/build_data.R turns each figure into. Value snapshots, which pin the actual
# numbers so a data update fails loudly instead of passing silently, are the
# TODO at the bottom.

setwd(here::here())
source("R/utils/write_stable.R")

# Keeps the dictionary check readable when a meta.yml field is absent altogether.
`%||%` <- function(a, b) if (is.null(a)) b else a

failures <- character()
check <- function(label, ok) {
  ok <- isTRUE(ok)
  cat(sprintf("  [%s] %s\n", if (ok) "PASS" else "FAIL", label))
  if (!ok) failures <<- c(failures, label)
  invisible(ok)
}

rd <- function(f) {
  readr::read_csv(file.path("data", f),
                  col_types = readr::cols(.default = readr::col_character()),
                  na = character(), progress = FALSE)
}

meta <- yaml::read_yaml("data/meta.yml")

cat("\nData dictionary\n")
check("meta.yml documents 3 dataset(s)", length(meta$datasets) == 3L)
check("meta.yml has no timestamp",
      !any(grepl("\\d{4}-\\d{2}-\\d{2}T|Sys\\.time|generated_at",
                 readLines("data/meta.yml", warn = FALSE))))

for (ds in meta$datasets) {
  df   <- rd(ds$file)
  cols <- vapply(ds$columns, function(x) x$name, character(1))
  check(sprintf("%s: meta.yml lists the columns the file actually has", ds$file),
        identical(cols, names(df)))
  check(sprintf("%s: meta.yml row count matches the file", ds$file),
        identical(as.integer(ds$rows), nrow(df)))
  check(sprintf("%s: every column has a type and a description", ds$file),
        all(vapply(ds$columns, function(x) nzchar(x$type %||% "") && nzchar(x$description %||% ""), logical(1))))
  check(sprintf("%s: source file is still present and unchanged", ds$file),
        identical(file_sha256(file.path("data-raw", ds$source_file)), ds$source_sha256))
  check(sprintf("%s: no blank rows", ds$file), nrow(df) > 0L)
}

cat("\nFile hygiene\n")
for (f in list.files("data", pattern = "[.](csv|yml)$", full.names = TRUE)) {
  check(sprintf("%s is UTF-8, LF, no BOM, no mojibake", basename(f)),
        tryCatch({ assert_clean_output(f); TRUE },
                 error = function(e) { cat("      ", conditionMessage(e), "\n"); FALSE }))
}

cat("\nValue snapshots\n")

annual <- rd("heat_illness_annual_rate.csv")
check("heat_illness_annual_rate.csv: 10 rows", nrow(annual) == 10L)
check("heat_illness_annual_rate.csv: first row is 2001",
      identical(annual$year[1], "2001") &&
      identical(annual$value[1], "1.8"))
check("heat_illness_annual_rate.csv: last row is 2010",
      identical(annual$year[nrow(annual)], "2010") &&
      identical(annual$value[nrow(annual)], "2.3"))
check("heat_illness_annual_rate.csv: value min/max",
      identical(annual$value[which.min(as.numeric(annual$value))], "1.1") &&
      identical(annual$value[which.max(as.numeric(annual$value))], "2.5"))

by_state <- rd("heat_illness_rate_by_state.csv")
check("heat_illness_rate_by_state.csv: 23 rows", nrow(by_state) == 23L)
check("heat_illness_rate_by_state.csv: first row is California",
      identical(by_state$state[1], "California") &&
      identical(by_state$value[1], "1.57"))
check("heat_illness_rate_by_state.csv: last row is Wisconsin",
      identical(by_state$state[nrow(by_state)], "Wisconsin") &&
      identical(by_state$value[nrow(by_state)], "1.31"))
check("heat_illness_rate_by_state.csv: value min/max",
      identical(by_state$value[which.min(as.numeric(by_state$value))], "0.56") &&
      identical(by_state$value[which.max(as.numeric(by_state$value))], "4"))

by_sex_age <- rd("heat_illness_by_sex_and_age.csv")
check("heat_illness_by_sex_and_age.csv: 7 rows", nrow(by_sex_age) == 7L)
check("heat_illness_by_sex_and_age.csv: first row is male",
      identical(by_sex_age$group_key[1], "male") &&
      identical(by_sex_age$value[1], "19457"))
check("heat_illness_by_sex_and_age.csv: last row is age_65_plus",
      identical(by_sex_age$group_key[nrow(by_sex_age)], "age_65_plus") &&
      identical(by_sex_age$value[nrow(by_sex_age)], "11889"))
check("heat_illness_by_sex_and_age.csv: value min/max",
      identical(by_sex_age$value[which.min(as.numeric(by_sex_age$value))], "285") &&
      identical(by_sex_age$value[which.max(as.numeric(by_sex_age$value))], "19457"))
# EPA's own published figures: the sex total and the age total are two
# independent breakdowns of the same hospitalizations and differ by 14.
check("heat_illness_by_sex_and_age.csv: sex total is 28133",
      sum(as.numeric(by_sex_age$value[by_sex_age$group_type == "sex"])) == 28133)
check("heat_illness_by_sex_and_age.csv: age total is 28119",
      sum(as.numeric(by_sex_age$value[by_sex_age$group_type == "age"])) == 28119)

cat("\n")
if (length(failures)) {
  cat(sprintf("%d FAILED:\n", length(failures)))
  for (f in failures) cat("  -", f, "\n")
  quit(status = 1L)
}
cat("All data checks passed.\n")
