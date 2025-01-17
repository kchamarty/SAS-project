

* import data to SAS;

PROC IMPORT;
RUN;


* UNDERSTAND YOUR DATA AND ITS PROPERTIES;

PROC CONTENTS DATA = YOUR_DATA;
RUN;

*DATA VALUE;

PROC PRINT DATA = YOUR_DATA (OBS=20);
RUN;


*DUPLICATES;
PROC SQL;
 SELECT COUNT(Status)AS TOTAL_COUNT, COUNT(DISTINCT ID) AS UNIQUE_COUNT
 FROM SASHELP.HEART
 ;QUIT;

 *REMOVE DUPLICATE OBSERVATIONS;
PROC SORT DATA = SASHELP.HEART OUT=YOUR_DATA_S NODUPKEY;
 BY _ALL_;
RUN;

*SINGLE ID MULTIPE TRANSACTION;

Proc Anova data=saspdata.data_anova;
	class region;
	model height =region;
	means region/scheffe;
	title "";
run;
	
	
/*Missing Data*/



	

DATA TEST;
 INPUT ID $ AMOUNT T_DATE PRODUCT;
CARDS;
1001 200 12JAN2020 A
1002 250 11JAN2020 B
1001 100 15JAN2020 B
1003 120 19JAN2020 A
1003 180 21JAN2020 C
1002 120 13JAN2020 B
1004 300 19JAN2020 A
1001 500 11JAN2020 C
;
RUN;

PROC PRINT;RUN;

PROC SQL;
 CREATE TABLE SUMMARY AS
 SELECT ID,SUM(AMOUNT) AS TOTAL
 FROM TEST
 GROUP BY ID
 ;
 QUIT;

PROC PRINT;RUN;


PROC SORT DATA = TEST OUT= TEST01;
BY ID;
PROC PRINT;RUN;

*SUM STATEMENT IN DATA STEP ;MONETARY AND FREQUENCY;

DATA SUMMARY01; 
SET TEST01;
BY ID;
IF FIRST.ID THEN TOTAL=0;
TOTAL+AMOUNT;

IF FIRST.ID THEN NUM_VISIT =0;
 NUM_VISIT+1;
/**/
/*IF LAST.ID;*/

DROP AMOUNT;
RUN;

PROC PRINT;RUN;

*WITH TRANSACTION DATE;
DATA TEST;
 INPUT ID $ AMOUNT T_DATE DATE9.;
  FORMAT T_DATE DATE9.;
  DROP AMOUNT;
CARDS;
1001 200 12JAN2020
1002 250 11JAN2020
1001 100 15JAN2020
1003 120 19JAN2020
1003 180 21JAN2020
1002 120 13JAN2020
1004 300 19JAN2020
1001 500 11JAN2020
;
RUN;

PROC PRINT DATA = TEST;
RUN;

PROC SORT DATA = TEST OUT=TEST01;
 BY ID DESCENDING T_DATE;
RUN;
PROC PRINT DATA = TEST01;
RUN;

DATA TEST02;
 SET TEST01;
 BY ID;
 N_DATE = LAG(T_DATE);
 IF FIRST.ID THEN N_DATE =T_DATE;
 DIFF_DAY = N_DATE - T_DATE;


 RUN;


PROC PRINT DATA = TEST02;
 FORMAT N_DATE DATE9.;
RUN;

*WITH TRANSACTION DATE;
DATA TEST;
 INPUT ID $ PRODUCT $ ;
CARDS;
1001  A
1002  B
1001  B
1003  B
1003  A
1002  C
1004  A
1001  C
;
RUN;

PROC PRINT DATA = TEST;
RUN;

PROC SORT DATA = TEST OUT=TEST01;
 BY ID PRODUCT;
RUN;
PROC PRINT DATA = TEST01;
RUN;


DATA PRD_SUMMARY;
 SET TEST01;
 BY ID;
 RETAIN TOTAL_PRD;
 LENGTH TOTAL_PRD $12.;
 IF FIRST.ID THEN TOTAL_PRD = " ";
  TOTAL_PRD = CATX("," ,TOTAL_PRD,PRODUCT) ;
  IF LAST.ID;
  DROP PRODUCT;
 
 RUN;


 PROC PRINT DATA = PRD_SUMMARY;
 RUN;






*DATA MERGING;

PROC SQL;
 CREATE TABLE P0 AS
 SELECT A.*,B.*
 FROM DATA1 AS A LEFT JOIN DATA2 AS B
 ON A.ID = B.ID
 ;
 QUIT;


*SELECT VARIABLES INDENTIFIED IN YOUR STUDY FRAMEWORK;

PROC SQL;
 CREATE TABLE P1 AS
 SELECT CHD,AGE,BMI,HT,CHOLESTROL
 FROM YOUR_DATA
 ;
 QUIT;


 *UNIVARIATE ANALYSIS;

 *ALL CONTINUOUS;
  PROC MEANS DATA = SASHELP.HEART N NMISS MIN MEAN MEDIAN MAX STD ;
  RUN;

PROC MEANS DATA = SASHELP.HEART N NMISS MIN MEAN MEDIAN MAX STD ;
 VAR WEIGHT HEIGHT AgeAtStart;
  RUN;


*FOR CATEGORICAL;
  TITLE "THIS IS DESCRIPTIVE ANALYSIS";
  FOOTNOTE "CRETED BY ARKAR";
PROC FREQ DATA = SASHELP.HEART;
 TABLE DeathCause STATUS SEX/MISSING ;
RUN;

PROC FREQ DATA = SASHELP.HEART;
 TABLE AgeCHDdiag/MISSING ;
RUN;


*CONTINOUSE DATA : VISUAL METHODS;
PROC SGPLOT DATA = SASHELP.HEART;
 HISTOGRAM WEIGHT;
 DENSITY WEIGHT;
RUN;
TITLE "THIS IS HORIZONTAL BOXPLOT";
PROC SGPLOT DATA = SASHELP.HEART;
 HBOX WEIGHT;
RUN;
TITLE "THIS IS VERTICAL BOXPLOT";
PROC SGPLOT DATA = SASHELP.HEART;
 VBOX WEIGHT;
RUN;


*CATEGORICAL DATA : VISUAL METHODS;

PROC SGPLOT DATA = SASHELP.HEART;
 VBAR STATUS;
 TITLE "THIS IS VERTICAL BARCHART";
 TITLE2 "THIS IS TEST";
 FOOTNOTE "CREATED BY ARKAR";
 FOOTNOTE2 "TEST";
RUN;




TITLE "THIS IS HORIZONTAL BARCHART";
PROC SGPLOT DATA = SASHELP.HEART;
 HBAR STATUS;
RUN;
QUIT;


ODS PDF FILE = "Z:\DSP SAS Project 17 Jun 2019\MY_REPORT.PDF";
TITLE "THIS IS PIE CHART";
PROC GCHART DATA = SASHELP.HEART;
 PIE Smoking_Status;
RUN;
QUIT;

ODS PDF CLOSE;


ODS HTML FILE = "C:\Users\amin\Desktop\SBP\MY_REPORT.HTML" style=HTMLBlue;
TITLE "THIS IS PIE CHART";
PROC GCHART DATA = SASHELP.HEART;
 PIE Smoking_Status;
RUN;
QUIT;

ODS HTML CLOSE;

ODS CSV FILE = "Z:\DSP SAS Project 17 Jun 2019\MY_REPORT.CSV";
TITLE "THIS IS PIE CHART";
PROC PRINT DATA = SASHELP.HEART;
RUN;

ODS CSV CLOSE;

ODS RTF FILE = "Z:\DSP SAS Project 17 Jun 2019\MY_REPORT.RTF";
TITLE "THIS IS PIE CHART";
PROC GCHART DATA = SASHELP.HEART;
 PIE Smoking_Status;
RUN;
QUIT;

ODS RTF CLOSE;


*CREATING UNIQUE ID;
PROC SQL;
 CREATE TABLE TEST AS
 SELECT MONOTONIC () AS ID,*
 FROM SASHELP.HEART;
 QUIT;

 DATA TEST01;
  SET SASHELP.HEART;
  ID =_N_;
  KEEP ID WEIGHT HEIGHT;
RUN;

PROC PRINT DATA = TEST01;RUN;


*OUPUT DELIVERY SYSTEM :ODS;


*BIVARIATE ANALYSIS;

*CONTINOUS VS CONTINUOUS: CORRELATION;

proc print data = AKM.DATA_CORR;run;


PROC CORR DATA = AKM.DATA_CORR;
RUN;

PROC CORR DATA = AKM.DATA_CORR;
 VAR tvhrs exhrs;
 WITH score; 
RUN;

*IF YOUR DATA IS NOT NORMAL DISTRIBUTED;
PROC CORR DATA = AKM.DATA_CORR SPEARMAN;
 VAR tvhrs exhrs;
 WITH score; 
RUN;


PROC CORR DATA = AKM.DATA_CORR PEARSON SPEARMAN;
 VAR tvhrs exhrs;
 WITH score; 
RUN;


PROC CORR DATA = AKM.DATA_CORR plots=matrix(histogram);
RUN;


PROC CORR DATA = AKM.DATA_CORR PLOTS = (SCATTER MATRIX);
RUN;

ODS GRAPHICS ON;



*DAY 5;

DATA saspdata.DATA_CATEGO;
INPUT BusType $ OnTimeOrLate $ @@;
DATALINES;
E O E L E L R O E O E O E O R L R O R L R O E O R L E O R L R O E O
E O R L E L E O R L E O R L E O R L E O R O E L E O E O E O E O E L
E O E O R L R L R O R L E L E O R L R O E O E O E O E L R O R L
;
RUN;

PROC PRINT DATA = saspdata.DATA_CATEGO;
RUN;



proc FREQ data=saspdata.DATA_CATEGO;
TABLE  BusType*OntimeOrLate/chisq nopercent nocum;
run;


PROC SGPLOT DATA =SASHELP.CARS;
VBAR ORIGIN/GROUP=TYPE;
RUN;



/* Continuous 

category 
*/


proc means data=sashelp.heart n nmiss min mean max median max std maxdec=2;
var cholesterol;
output out mean_out = mean;run;
proc print data=mean_out; run;

