# code to create the json prediction:

populationSettings <- list(PatientLevelPrediction::createStudyPopulationSettings(riskWindowEnd = 30,
                                                                                 riskWindowStart = 1,
                                                                                 washoutPeriod = 365,
                                                                                 removeSubjectsWithPriorOutcome = TRUE,
                                                                                 firstExposureOnly = TRUE,
                                                                                 priorOutcomeLookback = 99999,
                                                                                 requireTimeAtRisk = FALSE),
                           PatientLevelPrediction::createStudyPopulationSettings(riskWindowEnd = 60,
                                                                                 riskWindowStart = 1,
                                                                                 washoutPeriod = 365,
                                                                                 removeSubjectsWithPriorOutcome = TRUE,
                                                                                 firstExposureOnly = TRUE,
                                                                                 priorOutcomeLookback = 99999,
                                                                                 requireTimeAtRisk = FALSE),
                           PatientLevelPrediction::createStudyPopulationSettings(riskWindowEnd = 90,
                                                                                 riskWindowStart = 1,
                                                                                 washoutPeriod = 365,
                                                                                 removeSubjectsWithPriorOutcome = TRUE,
                                                                                 firstExposureOnly = TRUE,
                                                                                 priorOutcomeLookback = 99999,
                                                                                 requireTimeAtRisk = FALSE))


modelList <- list(list("LassoLogisticRegressionSettings" = list("variance" = 0.01,
                                                                "seed" = 1000)))

covariateSettings <- list(list(list(fnct = 'createCovariateSettings',
                                    settings = FeatureExtraction::createCovariateSettings(useDemographicsGender = T,
                                                                                          useDemographicsAgeGroup = T,
                                                                                          longTermStartDays = -183,
                                                                                          endDays = -4,
                                                                                          useDrugGroupEraLongTerm = T)),
                               list(fnct = 'createCovariateSettings',
                                    settings = FeatureExtraction::createCovariateSettings(useConditionGroupEraAnyTimePrior = T,
                                                                                          endDays = 0))),
                          list(list(fnct = 'createCovariateSettings',
                                    settings = FeatureExtraction::createCovariateSettings(useDemographicsGender = T,
                                                                                          useDemographicsAgeGroup = T,
                                                                                          useDemographicsEthnicity = T,
                                                                                          useDemographicsRace = T,
                                                                                          longTermStartDays = -365,
                                                                                          endDays = 0,
                                                                                          useConditionGroupEraLongTerm = T,
                                                                                          useDrugGroupEraLongTerm = T,
                                                                                          useProcedureOccurrenceLongTerm = T,
                                                                                          useDeviceExposureLongTerm = T,
                                                                                          useObservationLongTerm = T,
                                                                                          useMeasurementLongTerm = T)))
)

resrictOutcomePops <- NULL
resrictModelCovs <- NULL

executionSettings <- list(minCovariateFraction = 0.000,
                          normalizeData = T,
                          testSplit = "stratified",
                          testFraction = 0.25,
                          splitSeed = 1000,
                          nfold = 3)

json <- createDevelopmentStudyJson(packageName = 'CovCoagFullPrediction',
                                   packageDescription = 'Prediction model based on full predictor set.',
                                   createdBy = 'Henrik John',
                                   organizationName = 'Erasmus University Medical Center',
                                   targets = data.frame(targetId = c(22956),
                                                        cohortId = c(22956),
                                                        targetName = c('Target')),
                                   outcomes = data.frame(outcomeId = c(22601,22600,22599,22595,22596,22602,22933,22954),
                                                         cohortId = c(22601,22600, 22599,22595,22596,22602,22933,22954),
                                                         outcomeName = c('MI','IS','MI or IS','PE','DVT narrow',
                                                                         'VTE narrow', 'DTH', 'STR')),
                                   populationSettings = populationSettings,
                                   modelList = modelList,
                                   covariateSettings = covariateSettings,
                                   resrictOutcomePops = resrictOutcomePops,
                                   resrictModelCovs = resrictModelCovs,
                                   executionSettings = executionSettings,
                                   webApi = webApi,
                                   outputLocation = 'D:/hjohn/CovCoagFull',
                                   jsonName = 'predictionAnalysisList.json')

specifications <- Hydra::loadSpecifications(file.path('D:/hjohn/CovCoagFull', 'predictionAnalysisList.json'))
Hydra::hydrate(specifications = specifications, outputFolder = 'D:/hjohn/CovCoagFull/CovCoagFullPrediction')
