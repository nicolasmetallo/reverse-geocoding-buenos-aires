# Applied Data Science 2016 Final Project
## New York University
### Reverse Geocoding on Real Estate Properties in Buenos Aires

* CARTODB MAP: https://nicolasmetallo.carto.com/viz/dbf8c6d8-c1c3-11e6-8e4a-0ee66e2c9693/map*

![real estate buenos aires](https://i.imgur.com/iMbFOjT.jpg "Reverse geocoding in Real estate properties in Buenos Aires")

### Team:
- Ilan Reinstein
- Fernando Melchor
- Felipe Gonzales
- Nicolas Metallo

### ABSTRACT
Understanding demographics is a crucial part of the policy making process, but because of cost and complexity income is not usually measured within the census in Latin-American countries. Our work addresses this issue by developing a predictive model for household income down to the census block level. We extend previous work on the problem by ECLAC (Economic Commission for Latin America and the Caribbean) in three ways: (1) We develop scripts to access and handle REDATAM (data retrieval software) census data. (2) We train our model with survey data from both INDEC (National Institute of Statistics and Census of Argentina) and the Buenos Aires City Government, and we compare several feature reduction methods to define that the most relevant attributes for our prediction model are education, occupation and number of people in the household. (3) We compare our predicted model against publicly available income data from press releases, maps with geographical location of slums and historically low income neighborhoods and real estate prices that we scraped from the Internet. In the end, our model shows a high correlation with survey data although it overestimates for lower income city departments and underestimates for high income city departments. This model is highly representative of wealth distribution at a granular level and could potentially be use for: progressive taxation, public services disposition, real estate estimation and social policy making.

### DATA SOURCES
- Permanent Household Survey (EPH) Q3 2010 (INDEC)
- National Census of Population, Homes and Households 2010 (INDEC)
- Annual Household Survey 2010 in Buenos Aires City performed by the General Direction of Statistics and Census.

### IPYTHON NOTEBOOKS
- 1. Model_by_Individual.ipynb = Prediction Model for Individual data from Permanent Household Survey (EPH)
- 2. Merge_Invididual_to_Household.ipynb = Relating Individual Data to Household Data
- 3. Model Evaluation and Selection.ipynb = Final prediction model and validation

### HELPER FUNCTIONS
- categorize.py
- createVariables.py
- functionsForModels.py
- getEPH.py
- make_dummy.py
- schoolYears.py

redatamScript = REDATAM Script

## REFERENCES
- How to access Latin America census data (Spanish): https://observatoriocensal.org/2016/06/17/modos-de-acceso-a-los-datos-censales-en-los-paises-de-america-latina/
- REDATAM Background (Spanish): http://andresvazquez.com.ar/blog/anatomia-de-los-censos-en-latinoamerica/
- Latin America Census Data Visualization: https://data.terrapop.org/
- How to query REDATAM: https://github.com/jazzido/liberacion-del-censo
- Permanent Household Survey (EPH) Variables: EPH_disenoreg_T4_2014.pdf

## Variable names (original = changed)

* CODUSU = CODUSU
* NRO-HOGAR = NRO-HOGAR
* COMPONENTE = COMPONENTE
* AGLOMERADO = AGLOMERADO
* PONDERA = PONDERA
* CH03 = familyRelation
* CH04 = female
* CH06 = age
* CH12 = schoolYear
* CH13 = finishedYear
* CH14 = lastYear
* ESTADO = activity
* CAT_OCUP = empCond
* CAT_INAC = unempCond
* ITF = ITF
* IPCF = IPCF
* P47T = P47T

## Adding Household csv file creating see example on Using_getEPH.PY
### Variable names (original = changed)
					    'CODUSU',		=		CODUSU',
			       		'NRO_HOGAR',	        =            'NRO_HOGAR',
					'REGION',	        =            'REGION',
					PONDERA',	        =            'PONDERA',
			                      'IV1',	        =            'HomeType',
                                             'IV1_ESP',	        =            'HomeTypeesp',
                                             'IV2',	        =           'RoomsNumber',
                                             'IV3',	        =            'FloorMaterial',
                                             'IV3_ESP',	        =            'FloorMaterialesp',
                                             'IV4',	        =            'RoofMaterial',
                                             'IV5',	        =            'RoofCoat',
                                             'IV6',	        =            'Water',
                                             'IV7',	        =            'WaterType',
                                             'IV7_ESP',	        =            'WaterTypeesp',
                                             'IV8',	        =            'Toilet',
                                             'IV9',	        =            'ToiletLocation',
                                             'IV10',	        =            'ToiletType',
                                             'IV11',	        =            'Sewer',
                                             'IV12_1',	        =            'DumpSites',
                                             'IV12_2',	        =            'Flooding',
                                             'IV12_3',	        =            'EmergencyLoc',
                                             'II1',	        =            'UsableTotalRooms',
                                             'II2',	        =            'SleepingRooms',
                                             'II3',	        =            'OfficeRooms',
                                             'II3_1',	        =            'OnlyWork',
                                             'II4_1',	        =            'Kitchen',
                                             'II4_2',	        =            'Sink',
                                             'II4_3',	        =            'Garage',
                                             'II7',	        =            'Ownership',
                                             'II7_ESP',	        =            'Ownershipesp',
                                             'II8',	        =           'CookingCombustible',
                                             'II8_ESP',	        =            'CookingCombustibleesp'
                                             'II9',	        =           'BathroomUse',
                                             'V1',	        =            'Working',
                                             'IX_TOT',	        =            'HouseMembers',
                                             'IX_MEN10',	=                    'Memberless10',
                                             'IX_MAYEQ10',	=                    'Membermore10',
                                             'ITF',	        =            'TotalHouseHoldIncome',
                                             'VII1_1',	        =            'DomesticService1',
                                             'VII1_2',	        =            'DomesticService2',
                                             'VII2_1',	        =            'DomesticService3',
                                             'VII2_2',	        =            'DomesticService4',
                                             'VII2_3',	        =            'DomesticService5',
                                            'VII2_4'	        =            'DomesticService6'
