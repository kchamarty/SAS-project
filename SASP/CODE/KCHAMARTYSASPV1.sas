*SAS PROJECT;
/* checking out the variables and its properties*/

DATA SASPDATA.DEMOGRAPHICVARS;
	SET SASPDATA.PROJECT2_VARIABLES;
RUN;
DATA SASPDATA.DEMOGRAPHICS;
	SET SASPDATA.PROJECT2;
RUN;
PROC SQL;
	SELECT * FROM SASPDATA.DEMOGRAPHICVARS ORDER BY 'varnum';
QUIT;

PROC SQL;
	SELECT Name, LABEL FROM SASPDATA.DEMOGRAPHICVARS ORDER BY 'varnum';
quit;

/* checking out sample data*/
PROC SQL outobs=10;
	SELECT * FROM SASPDATA.DEMOGRAPHICS;
QUIT;

/* Exporting data into CSV Files*/
PROC EXPORT data=saspdata.HOUSING2 
		outfile="/Users/KC/Documents/GitHub/SAS-project/SASP/output/demographics_final.csv" dbms=csv;
		/* path for sas ue
		"/folders/myfolders/output/demographicvars.csv"*/
/* 	PATH FOR COLLEGE SYSTEM
	C:/Users/kchamart/Desktop/SASP/saspoutput/demographics.csv */
run;

PROC EXPORT data=saspdata.Demographics 
		outfile="/Users/KC/Documents/GitHub/SAS-project/SASP/Output/demographics.csv" dbms=csv; 
		*path in college system;
run;
/*CREATING A LIBRARY FOR STORING FORMATS*/
/* libname prjfrmt '/folders/myfolders/formats'; */
/*OPTIONS FMTSEARCH=(PRJFRMT  WORK); *Specifying the order of Libraries; */
	
/*CREATING THE FORMATS*/
PROC FORMAT ;

 	VALUE REGION 	  
  		1 = "NORTH PUGET      "
        2 = "WEST BALANCE     "
		3 = "KING             "
		4 = "OTHER PUGET METRO"
		5 = "CLARK            "
		6 = "EAST BALANCE     "
		7 = "SPOKANE          "
		8 = "TRI-CITIES       "
	;
	VALUE  AgeSeg
		0 	- <20 	=	'Age: <20    ' 
		21	- <30 	=	'Age: 21--30 '
		31  - <40   = 	'Age: 31--40 '
		41	- <50   = 	'Age: 41--50 '
		51  - <60   = 	'Age: 51--60 '
		61	- <80 	= 	'Age: 61--80 '
		80  - HIGH 	= 	'Age: >80    '
		.			= 	'Age: Missing'
	;	
	VALUE IncomeSeg
		0      - <20000  = 'Income: <$20k    '
		20000  - <40000  = 'Income: $20-40k'
		40000  - <60000  = 'Income: $40-60k'
		60000  - <80000  = 'Income: $60-80k'
		80000  - <100000 = 'Income: $80-100k'
		100000 - <150000 = 'Income: $100-150k'
		150000 - HIGH    = 'Income: >$150k'
		.                = 'Income: Missing'
 	;
	VALUE  RESIDENCETYPE
 	 	1 = 'OWNERS'
 	 	2 = "RENTERS"
 	 	3 = "NEITHER"
 	 	. = "MISSING INGO"
 	 ;
 	 
 	 
 	  VALUE  ARMY
 	 	1,2,3 = 'SERVED IN ARMY       '
 	 	0 = "DID NOT SERVE IN ARMY"
 	 	. = "MISSING INFO"
 	 ;

RUN;

/* subsetting the data to match project frame work needs*/
PROC SQL;
	CREATE TABLE SASPDATA.HOUSING AS(
		SELECT ID /* HOUSEHOLD ID*/
		, PNUM /* PERSON NUMBER*/
		, REGION 
		, HHINC /*HOUSE HOLD INCOME AVERAGE */
		, PEOPL /*NUMBER OF PEOPLE */
		, Q4P5
		, Q215P, Q2P15 /*Armed forces 0 OR 1*/
		, CHLDRN14, CHLDRN17, CHLDRN18, CHLDRN20 /* DEPENDENTS */
		, AGE /*AVERAGE*/
		, CITIZEN
		, Q2P17  /* HIGHEST LEVEL OF SCHOOL OR DEGREE  AVERAGE*/
		, Q2P18 , Q2P20 /* number of years a person has lived in the country AVERAGE*/
		, Q2P14 /* MARITAL STATUS */
		, Q4P7 , Q4P3, Q4P4, Q4P6 /*JOB STATUS AND NUMBER OF JOBS */
		, Q4P9 , Q4P10 /*TYPE OF EMPLOYMENT */
		, Q3P2  FORMAT = RESIDENCETYPE. /* HOUSE OWNERSHIP*/   
		, RSDNC /*MORE THAN 1 HOME IN WASHINGTON STATE*/
		, Q3P2A , Q3P2B , Q3P3 , Q3P4 , Q3P5 
		
FROM SASPDATA.DEMOGRAPHICS
WHERE AGE GE 16
);
QUIT;


/* Combining CHLDREN INFORMATION into 1 column as it is repetitive */
DATA SASPDATA.HOUSING1 (DROP=CHLDRN14 CHLDRN17 CHLDRN18 CHLDRN20);
	SET SASPDATA.HOUSING;
	LABEL CHLDRN_LT_20 = '# OF CHILDREN BELOW 20 YEARS';

	IF CHLDRN20 >0 THEN
		CHLDRN_LT_20 =CHLDRN20;
	ELSE IF CHLDRN18 >0 THEN
		CHLDRN_LT_20=CHLDRN18;
	ELSE IF CHLDRN17 >0 THEN
		CHLDRN_LT_20=CHLDRN17;
	ELSE IF CHLDRN14 >=0 THEN
		CHLDRN_LT_20=CHLDRN14;
RUN;

/* SORTING DATA FOR QUICKER PROCESSING*/ 
PROC SORT DATA = SASPDATA.HOUSING1 OUT=SASPDATA.HOUSING1_S;
BY ID PNUM;


/* verifing the data for  missing values*/ 
PROC MEANS DATA = SASPDATA.HOUSING1_S NMISS N MIN MAX Q1 Q3;
RUN;

/* checking the sample values */
PROC PRINT DATA=SASPDATA.HOUSING1_S (OBS=10);
RUN;


/* proc transpose data=SASPDATA.HOUSING1S out=SASPDATA.HOUSING1_TS  */
/* 		prefix=PID_ SUFFIX=_HLE; */
/* 	var Q2P17; */
/* 	id PNUM; */
/* 	by ID; */
/* run; */

/* CONSOLIDATING ALL HOUSEHOLD INFORMATION */ 
PROC SQL;
	CREATE TABLE  SASPDATA.HOUSING2 AS
	SELECT DISTINCT ID
	, REGION FORMAT= REGION.
	, PEOPL 
	, HHINC FORMAT=DOLLAR10.  /*HOUSE HOLD INCOME AVERAGE */
	, HHINC AS HouseHold_Income FORMAT=IncomeSeg. LABEL=" TOTAL INCOME OF HOUSEHOLD"
	, ROUND(AVG(Q2P17)) as AVG_EDU_LVL LABEL="AVG OF EDUCATION LEVEL"/* Average ofHIGHEST LEVEL OF SCHOOL OR DEGREE  AVERAGE*/
	, ROUND(AVG(AGE))AS AVG_AGE FORMAT= AgeSeg. LABEL= "AVERAGE OF AGE OF PPL IN THE HOUSE HOLD"
	, CHLDRN_LT_20
	, MAX(Q4P5) AS OTHR_INCM_SRC LABEL="INCOME FROM FARM OR BUSINESS"
	, RSDNC /*MORE THAN 1 HOME IN WASHINGTON STATE*/
	, ROUND(AVG(CASE WHEN Q2P20 IS NOT NULL THEN 2004-Q2p20 WHEN Q2P18=1 THEN AGE END)) AS NUM_YEARS_US LABEL="#AVG OF YRS PPL LIVING IN US"
	, sum(CASE WHEN Q215P=1 OR Q2P15=1 THEN 1 WHEN Q215P=0 and Q2P15=0 THEN 0 else . END) AS NUM_IN_ARMY FORMAT = ARMY. LABEL="# OF PPL SERVING IN THE ARMY"
	, SUM(CASE WHEN Q4P7 IS NOT NULL THEN Q4P7 ELSE 0 END +
	CASE WHEN Q4P4 =1 THEN 1 ELSE 0 END +
	CASE WHEN (Q4P3 = 0 AND Q4P6 IN(4,6,1,16,18)) THEN 1 ELSE 0 END) AS NUM_JOBS_HHLD LABEL="# OF JOBS PER HOUSEHOLD"
	, (CASE WHEN MAX(Q3P2) = 1 THEN 1 when MAX(Q3P2) > 1 THEN 0 ELSE .S END) AS OWNS_HOUSE LABEL='OWN HOME OR NOT'
	
	FROM SASPDATA.HOUSING1_S
	GROUP BY ID;
	 
QUIT;

PROC PRINT DATA=SASPDATA.HOUSING2 (OBS)=10;RUN;

/**********************---   SUMMARY OF DATA AT HOUSEHOLD LEVEL    ---*************/

TITLE "SUMMARY OF DATA AT HOUSEHOLD LEVEL";
PROC MEANS DATA = SASPDATA.HOUSING2 NMISS N MIN MEAN MEDIAN MAX MODE;
RUN;


/******************************************************************************************************************************
/* GETTING RID OF RECORDS MISSING HOME OWNERSHIP INFO*/
PROC SQL;
	CREATE TABLE  SASPDATA.HOUSING2_NOMISS_HO AS
	SELECT *
	FROM SASPDATA.HOUSING2
	WHERE OWNS_HOUSE IS NOT NULL;
	 
QUIT;

/*** FIlling up missing values with Mean and Median  ****/

DATA SASPDATA.HOUSING2_NOMISS;
	SET SASPDATA.HOUSING2_NOMISS_HO(DROP=OTHR_INCM_SRC HouseHold_Income);
	IF MISSING(AVG_EDU_LVL ) THEN AVG_EDU_LVL =3;
	IF MISSING(NUM_IN_ARMY ) THEN NUM_IN_ARMY =0;
	IF MISSING(RSDNC ) THEN RSDNC =0;
	IF MISSING(NUM_YEARS_US ) THEN NUM_YEARS_US =45;
RUN;

/*******To Analyze number of adults contributing to household income******/

PROC SQL;
CREATE TABLE SASPDATA.HOUSING2_ADULTINCOME AS
SELECT ID
		, HouseHold_Income /*HOUSE HOLD INCOME AVERAGE */
		, PEOPL - CHLDRN_LT_20 AS ADULTS/*NUMBER OF PEOPLE */ 
FROM SASPDATA.HOUSING2
;
QUIT;



/**************************************************************************************************************/
/****---- GettingrRid of outliers------****/
PROC SQL;
	CREATE TABLE  SASPDATA.HOUSING2_NOOUT AS
	SELECT *
	FROM SASPDATA.HOUSING2_NOMISS
	WHERE HHINC le 600000;
	 
QUIT;

TITLE "SUMMARY OF FINAL DATA AT HOUSEHOLD LEVEL";
PROC MEANS DATA = SASPDATA.HOUSING2_NOOUT NMISS N MIN MEAN MEDIAN MAX MODE;
RUN;

/*Transformation of code into categorical columns*/

data SASPDATA.HOUSING3;
	length Age_Catg  $11;
	length HHINC_Catg $9.;
	set SASPDATA.HOUSING2;

	select;
		when (0  <=AVG_AGE <=20) Age_Catg='Age :  <20';
		when (21 <=AVG_AGE <=30) Age_Catg='Age : 21-30';
		when (31 <=AVG_AGE <=40) Age_Catg='Age : 31-40';
		when (41 <=AVG_AGE <=50) Age_Catg='Age : 41-50';
		when (51 <=AVG_AGE <=60) Age_Catg='Age : 51-60';
		when (61 <=AVG_AGE <=80) Age_Catg='Age : 61-80';
		otherwise Age_Catg='Age : >80';
	end;
	select;
		when (0  <=HHINC <20000) HHINC_Catg=' <20k ';
		when (20000 <=HHINC <40000) HHINC_Catg='20-40k';
		when (40000 <=HHINC <60000) HHINC_Catg='40-60k';
		when (60000 <=HHINC <80000) HHINC_Catg='60-80k';
		when (80000 <=HHINC <100000) HHINC_Catg='80-100k';
		when (100000 <=HHINC <150000) HHINC_Catg='100-150k';
		otherwise HHINC=' >150k ';
	end;
run;

PROC CONTENTS DATA=SASPDATA.HOUSING2;RUN;

/***********************************************************************************/
/*****************---------UNIVARIATE ANALYSIS-----------***********/




/***********************--- HISTOGRAM OF AGE---***************/

TITLE  "HISTOGRAM OF AGE";

PROC SGPLOT DATA=SASPDATA.HOUSING2;
	HISTOGRAM AVG_AGE / SHOWBINS NBINS=6
	DATASKIN = MATTE;
	Density AVG_AGE;
RUN;

/*******---PERCENTATGE OF HOUSEHOLDS THAT HAVE VETERANS---*********/

TITLE "PERCENTATGE OF HOUSEHOLDS THAT HAVE VETERANS";
proc template;
	define statgraph SASStudio.Pie;
		begingraph;
		layout region;
		piechart category=NUM_IN_ARMY / stat=pct datalabellocation=callout 
			fillattrs=(transparency=0.25) dataskin=gloss;
		endlayout;
		endgraph;
	end;
run;

ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgrender template=SASStudio.Pie data=SASPDATA.HOUSING2;
run;

ods graphics / reset;

/* Frquency Precentatge distribution of  Residence status*/
TITLE  "HOUSE OWNERS OR RENTERS";
/* PROC SGPLOT DATA=SASPDATA.HOUSING2_S_REGION; */
/* 	HISTOGRAM Q3P2_SUM */
/* 	/DATASKIN = MATTE BINWIDTH=0.5 BINSTART=0 fill; */
/*  	XAXIS VALUES=(-1 to 3 by 1) COLORBANDS=EVEN; */
/*  	FORMAT Q3P2_SUM OWNERS.; */
/*  	RUN; */
/* QUIT; */
proc sgplot data=SASPDATA.HOUSING;
	vbar Q3P2 / fillattrs=(color=CX3ace8e) datalabel stat=percent;
	yaxis grid;
run;

/* BOXPLOT ANALYSIS OF HOUSEHOLD INCOME*/

ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=SASPDATA.HOUSING2;
	vbox HouseHold_Income / fillattrs=(color=CXf3c017) notches;
	yaxis grid;
	refline 600000 / axis=y lineattrs=(thickness=2 color=green) label 
		labelattrs=(color=green);
run;

proc sgplot data=SASPDATA.HOUSING2_NOOUT;
	vbox HHINC / fillattrs=(color=CX21da9f transparency=0.25) notches 
		capshape=line;
	yaxis grid;
	refline 600000 / axis=y lineattrs=(thickness=2 color=green) label 
		labelattrs=(color=green);
run;


ods graphics / reset;

/***************---PERCENTATGE OF HOUSEHOLDS OWNING HOMES---**********/

TITLE "PERCENTATGE OF HOUSEHOLDS OWNING HOMES";
PROC GCHART DATA=SASPDATA.HOUSING2;
	PIE  OWNS_HOUSE / 
         clockwise
         value=none
         percent=INSIDE
         noheading            
    ;
RUN;

TITLE  "HOUSE HOLD INCOME";
PROC SGPLOT DATA=SASPDATA.HOUSING;
	HISTOGRAM HHINC /
	DATASKIN = MATTE;
	DENSITY HHINC;
	RUN;
QUIT;

/**********************************************************************************************/
/***************------------ BIVARIATE ANALYSIS---------------************/

/*****************---DISTRIBUTION OF RESIDENCE TYPE  BY REGION----************/

PROC SQL;
	CREATE TABLE  SASPDATA.HOUSING2_REGION AS
	SELECT DISTINCT ID
	, REGION FORMAT = REGION.
	,SUM(Q3P2) aS Q3P2_SUM LABEL='RESIDENCE TYPE' FORMAT = RESIDENCETYPE.
	FROM SASPDATA.HOUSING1_S
	GROUP BY ID;
QUIT;

TITLE  "HOUSE OWNERS - REGION WISE";

proc sgplot data=SASPDATA.HOUSING2_REGION;
	vbar REGION / CATEGORYORDER=RESPDESC group=Q3P2_SUM groupdisplay=cluster 
		fillattrs=(transparency=0.25) datalabel;
	xaxis discreteorder=data;
	yaxis grid;
run;

ods graphics / reset;

/***************---DISTRIBUTION OF HOME OWNERS - BY AGE----********************/
TITLE  "DISTRIBUTION OF HOME OWNERS - BY AGE";

PROC SORT DATA=SASPDATA.HOUSING2 OUT =SASPDATA.HOUSING_2S_OWNSHOUSE;
BY OWNS_HOUSE;
RUN;

proc sgplot data=SASPDATA.HOUSING3;

	vbar Age_Catg / CATEGORYORDER=RESPDESC group=OWNS_HOUSE groupdisplay=cluster 
		datalabel stat=percent;
run;

TITLE  "DISTRIBUTION OF HOME OWNERS - BY AGE";

proc sgplot data=SASPDATA.HOUSING3;
	vbar HHINC_Catg / group=OWNS_HOUSE groupdisplay=cluster datalabel stat=percent;
	yaxis grid;
run;

/***************---DISTRIBUTION OF Income vs HOME OWNERShip ----********************/

title 'Income Distribution By House Ownership';
proc sgplot data=SASPDATA.HOUSING2;
	vbar HouseHold_Income / CATEGORYORDER=RESPDESC group=OWNS_HOUSE groupdisplay=cluster 
		fillattrs=(transparency=0.25) datalabel stat=percent dataskin=sheen;
	yaxis grid;
run;

/***************---DISTRIBUTION OF Income and number of People----********************/
title 'Income vs Number of people';

proc sgplot data=SASPDATA.HOUSING2_ADULTINCOME;
	vbar HouseHold_Income / group=ADULTS groupdisplay=cluster;
	yaxis grid;
run;




/**** Creating training data set ******/
PROC SORT DATA=SASPDATA.HOUSING2_NOOUT OUT=SASPDATA.HOUSING2_NOOUT_S;
BY OWNS_HOUSE;
RUN;

PROC SURVEYSELECT DATA=SASPDATA.HOUSING2_NOOUT_S 
	out =SASPDATA.HOUSING2_TRAIN(DROP=SelectionProb	SamplingWeight Total AllocProportion 
	SampleSize ActualProportion) 
	method =srs samprate=.75 SEED=1234567;
	STRATA OWNS_HOUSE / alloc=prop;
RUN;



PROC PRINT DATA=SASPDATA.HOUSING2_TRAIN (OBS=10);
RUN;
PROC MEANS DATA=SASPDATA.HOUSING2_TRAIN N NMISS MIN MAX;
RUN;



/* RUNNING THE LOGISTIC REGRESSION */
proc stdize data=SASPDATA.HOUSING2_NOOUT method=std nomiss 
		out=SASPDATA.HOUSING_STD oprefix sprefix=Std_;
	var HHINC PEOPL AVG_EDU_LVL AVG_AGE CHLDRN_LT_20  NUM_YEARS_US 
		NUM_JOBS_HHLD;
run;

proc logistic data=SASPDATA.HOUSING_STD;
	model OWNS_HOUSE(event='1')=NUM_IN_ARMY Std_PEOPL Std_HHINC Std_AVG_EDU_LVL 
		Std_AVG_AGE Std_CHLDRN_LT_20 Std_NUM_YEARS_US Std_NUM_JOBS_HHLD / 
		selection=backward slstay=0.05 hierarchy=single technique=fisher;

run;


/****** PREDICTION ******/
DATA SASPDATA.HOUSING_PREDICT;
	SET  SASPDATA.HOUSING_STD;
	PRED=  -4.0983 +0.1898*PEOPL + 0.000028*HHINC 
  				+ 0.0299 * AVG_AGE + 0.0351 * NUM_YEARS_US + 0.2384*NUM_JOBS_HHLD;
  	IF PRED <=0.0 THEN PREDICTED =0;
  	ELSE PREDICTED =1;
  	
  	PREDICTED_S=  1.3270 +0.2805*Std_PEOPL + 1.3499*Std_HHINC 
  				+ 0.4842 * Std_AVG_AGE + 0.5997 * Std_NUM_YEARS_US + 0.2862*Std_NUM_JOBS_HHLD;
  				
RUN;



DATA SASPDATA.HOUSING_CLASSIFICATION;
	SET  SASPDATA.HOUSING_PREDICT;
  		 IF (PREDICTED=1 AND OWNS_HOUSE=1) THEN DO; CL="TP"; CLS='ALREADY OWN A HOME      ';END;
  	ELSE IF (PREDICTED=1 AND OWNS_HOUSE=0) THEN DO; CL="FP"; CLS='HIGH POTENTIAL CUSTOMERS';END;
  	ELSE IF (PREDICTED=0 AND OWNS_HOUSE=0) THEN DO; CL="TN"; CLS='LESS LIKELY CUSTOMERS';END;
  	ELSE IF (PREDICTED=0 AND OWNS_HOUSE=1) THEN DO; CL="FP"; CLS='ALREADY OWN A HOME';END;
  	FORMAT REGION REGION.;
RUN;

proc sgplot data=SASPDATA.HOUSING_CLASSIFICATION;
	vbar REGION / CATEGORYORDER=RESPDESC group=CLS groupdisplay=cluster fillattrs=(transparency=0.25) 
		datalabel stat=percent dataskin=crisp;
	xaxis valuesrotate=diagonal;

run;


  				
PROC MEANS DATA= SASPDATA.HOUSING_PREDICT;RUN;
PROC MEANS DATA= SASPDATA.HOUSING_CLASSIFICATION;RUN;

  				
  				
  				
/*  */
/* Intercept	1	1.3270	0.0378	1234.1196	<.0001 */
/* Std_PEOPL	1	0.2805	0.0365	58.9150	<.0001 */
/* Std_HHINC	1	1.3499	0.0638	447.2344	<.0001 */
/* Std_AVG_AGE	1	0.4842	0.0975	24.6354	<.0001 */
/* Std_NUM_YEARS_US	1	0.5997	0.0982	37.3004	<.0001 */
/* Std_NUM_JOBS_HHLD	1	0.2862	0.0395	52.5226	<.0001 */
/* ntercept	1	-4.0983	0.1609	648.6011	<.0001 */
/* PEOPL	1	0.1898	0.0247	58.9150	<.0001 */
/* HHINC	1	0.000028	1.333E-6	447.2344	<.0001 */
/* AVG_AGE	1	0.0299	0.00602	24.6354	<.0001 */
/* NUM_YEARS_US	1	0.0351	0.00575	37.3004	<.0001 */
/* NUM_JOBS_HHLD	1	0.2384	0.0329	52.5226	<.0001 */





