# Provenance

Every file in this directory is reproduced unmodified from EPA's published
indicator page and its per-figure data downloads. To update the data, replace the
file and rerun `Rscript R/build_data.R`.

## Indicator page

- `source-page.html`  \
  <https://19january2025snapshot.epa.gov/climate-indicators/heat-related-illnesses/index.html>  \
  sha256 `8865fc1675cfe9d0d92cd7530ff5a1187d4f7b042ce1a55bd77a858897251ea3`

Technical documentation: <https://19january2025snapshot.epa.gov/sites/default/files/2021-03/documents/heat-illness_tech-doc.pdf>

## Figure data

- `heat-illnesses_fig-1.csv`  \
  <https://19january2025snapshot.epa.gov/sites/default/files/2016-08/heat-illnesses_fig-1.csv>  \
  sha256 `cf2c98d9eaf411e93bdec56ca9dc0fb6e857b0d081260f4a7e0a277663aed091`  \
  encoding windows-1252, 10 data rows, columns: `Year`, `Hospitalizations per 100,000 people`  \
  title: Figure 1. Heat-Related Hospitalizations in 20 States, 2001–2010  \
  data source: Choudhary and Vaidyanathan, 2014; web update: August 2016; units: number of hospitalizations per 100,000 people

- `heat-illnesses_fig-2.csv`  \
  <https://19january2025snapshot.epa.gov/sites/default/files/2016-08/heat-illnesses_fig-2.csv>  \
  sha256 `2a437a213f2ffc2fbc2880695b4b251755880d705a401da230404d7f921ee0d6`  \
  encoding UTF-8, 23 data rows, columns: `State`, `2001-2010 average`  \
  title: Figure 2. Average Rate of Heat-Related Hospitalizations in 23 States, 2001-2010  \
  data source: CDC, 2016; web update: August 2016; units: average annual rate of hospitalizations per 100,000 people

- `heat-illnesses_fig-3.csv`  \
  <https://19january2025snapshot.epa.gov/sites/default/files/2016-08/heat-illnesses_fig-3.csv>  \
  sha256 `ab1fefdd4d5cb6b70015af437d401065bf0f94f9f45ec85a6399be9cc1ce571e`  \
  encoding windows-1252, 7 data rows, columns: `Group`, `Number of hospitalizations reported`  \
  title: Figure 3. Heat-Related Hospitalizations in 20 States by Sex and Age, 2001–2010  \
  data source: Choudhary and Vaidyanathan, 2014; web update: August 2016; units: total number of hospitalizations
