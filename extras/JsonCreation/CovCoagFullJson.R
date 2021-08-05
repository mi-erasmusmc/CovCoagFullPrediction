# code to create the json prediction:
webApi = 'https://awsagunva1011.jnj.com:8443/WebAPI'

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


modelList <- list(list("LassoLogisticRegressionSettings" = list("variance" = 0.01)))

covariateSettings <- list(list(list(fnct = 'createCovariateSettings',
                                    settings = FeatureExtraction::createCovariateSettings(useDemographicsGender = T,
                                                                                          useDemographicsAge = T,
                                                                                          useDemographicsEthnicity = T,
                                                                                          useDemographicsRace = T,
                                                                                          longTermStartDays = -365,
                                                                                          endDays = 0,
                                                                                          useConditionGroupEraLongTerm = T,
                                                                                          useDrugGroupEraLongTerm = T,
                                                                                          useProcedureOccurrenceLongTerm = T,
                                                                                          useDeviceExposureLongTerm = T,
                                                                                          useObservationLongTerm = T,
                                                                                          useMeasurementLongTerm = T))),
                          list(list(fnct = 'createCovariateSettings',
                                    settings = FeatureExtraction::createCovariateSettings(useDemographicsGender = T,
                                                                                          useDemographicsAge = T,
                                                                                          useDemographicsEthnicity = T,
                                                                                          useDemographicsRace = T,
                                                                                          longTermStartDays = -365,
                                                                                          mediumTermStartDays = -180,
                                                                                          endDays = 0,
                                                                                          useConditionGroupEraAnyTimePrior = T,
                                                                                          useDrugGroupEraMediumTerm = T,
                                                                                          useProcedureOccurrenceAnyTimePrior = T,
                                                                                          useDeviceExposureAnyTimePrior = T,
                                                                                          useObservationAnyTimePrior = T,
                                                                                          useMeasurementAnyTimePrior = T)))
)

resrictOutcomePops <- NULL
resrictModelCovs <- NULL

executionSettings <- list(minCovariateFraction = 0.000,
                          normalizeData = T,
                          testSplit = "stratified",
                          testFraction = 0.20,
                          splitSeed = 1000,
                          nfold = 3)

json <- createDevelopmentStudyJson(packageName = 'CovCoagFullPrediction',
                           packageDescription = 'Prediction model based on full predictor set.',
                           createdBy = 'Henrik John',
                           organizationName = 'Erasmus University Medical Center',
                           targets = data.frame(targetId = c(22932),
                                                cohortId = c(22932),
                                                targetName = c('COVID19 PCR positive test or diagnosis')),
                           outcomes = data.frame(outcomeId = c(22601,22600,22599,22595,22596,22602,22933),
                                                 cohortId = c(22601,22600, 22599,22595,22596,22602,22933),
                                                 outcomeName = c('MI','IS','MI_and_IS','PE','DVT_narrow',
                                                                 'VTE_narrow', 'DTH')),
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
