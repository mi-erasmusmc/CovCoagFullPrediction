# Copyright 2020 Observational Health Data Sciences and Informatics
#
# This file is part of CovCoagFullPrediction
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Format and check code ---------------------------------------------------
OhdsiRTools::formatRFolder()
OhdsiRTools::checkUsagePackage("CovCoagFullPrediction")
OhdsiRTools::updateCopyrightYearFolder()

# Create manual -----------------------------------------------------------
shell("rm extras/CovCoagFullPrediction.pdf")
shell("R CMD Rd2pdf ./ --output=extras/CovCoagFullPrediction.pdf")

# Create vignette ---------------------------------------------------------
rmarkdown::render("vignettes/UsingSkeletonPackage.Rmd",
                  output_file = "../inst/doc/UsingSkeletonPackage.pdf",
                  rmarkdown::pdf_document(latex_engine = "pdflatex",
                                          toc = TRUE,
                                          number_sections = TRUE))
rmarkdown::render("vignettes/AddingCohortCovariates.Rmd",
                  output_file = "../inst/doc/AddingCohortCovariates.pdf",
                  rmarkdown::pdf_document(latex_engine = "pdflatex",
                                          toc = TRUE,
                                          number_sections = TRUE))

rmarkdown::render("vignettes/CreatingStudyPackageInR.Rmd",
                  output_file = "../inst/doc/CreatingStudyPackageInR.pdf",
                  rmarkdown::pdf_document(latex_engine = "pdflatex",
                                          toc = TRUE,
                                          number_sections = TRUE))

# Create analysis details -------------------------------------------------
# Insert cohort definitions from ATLAS into package -----------------------
OhdsiRTools::insertCohortDefinitionSetInPackage(fileName = "CohortsToCreate.csv",
                                                baseUrl = "webapi",
                                                insertTableSql = TRUE,
                                                insertCohortCreationR = TRUE,
                                                generateStats = FALSE,
                                                packageName = "CovCoagFullPrediction")

# Create analysis details -------------------------------------------------
source("extras/CreatePredictionAnalysisDetails.R")
createAnalysesDetails("inst/settings")

# Store environment in which the study was executed -----------------------
OhdsiRTools::insertEnvironmentSnapshotInPackage("CovCoagFullPrediction")

# Cohorts -----
# Because of some inconsistencies in bringing in diagnosis cohorts from atlas, 
# here I specify the full set of codes to be used
library(here)
library(SqlRender)
library(stringr)
# Diagnosis cohorts
diag_template_sql<-readSql(here("extras", "template sql", "COVID19 diagnosis template.sql"))
# broad
diag_broad_codes<-"756031,756039,3655975,3655976,3655977,3656667,3656668,3656669,3661405,3661406,3661408,3661631,3661632,3661748,3661885,3662381,3663281,37310254,37310283,37310284,37310286,37310287,37311060,37311061,320651,439676,4100065,37016927,37396171,40479642,700296,700297,704995,704996,37311060, 45763724, 37310268, 37310282"
diag_broad_sql<-str_replace(diag_template_sql, "@codes",
                            diag_broad_codes)
fileConn<-file(here("inst", "sql", "sql_server", "COVID19_diagnosis_broad.sql"))
writeLines(diag_broad_sql, fileConn)
close(fileConn)
# narrow
diag_narrow_codes<-"756031,756039,3655975,3655976,3655977,3656667,3656668,3656669,3661405,3661406,3661408,3661631,3661632,3661748,3661885,3662381,3663281,37310254,37310283,37310284,37310286,37310287,37311061,700296,700297,704995,704996"
diag_narrow_sql<-str_replace(diag_template_sql, "@codes",
                             diag_narrow_codes)
fileConn<-file(here("inst", "sql", "sql_server", "COVID19_diagnosis_narrow.sql"))
writeLines(diag_narrow_sql, fileConn)
close(fileConn)

