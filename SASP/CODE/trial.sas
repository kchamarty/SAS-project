/*samples trial and errors*/

/* lokking for distinct residence type*/
proc sql;
	select  ID, CASE WHEN Q3P2 is not null then Q3p2 
	from saspdata.demographics
 	group by id 
;
quit;


/*Job status */

proc sql;
	select ID, MAx(AGE)
	from saspdata.demographics
 	where Q4P7 is NOT NULL or Q4P4 =1 or (Q4P3 = 0 and Q4P6 in(4,6,1,16,18))
 	group by id 
 	order by 2;
 quit;

/* summing up total number of jobs per household*/
proc sql;
	select ID, Q4P7, Q4P4, Q4P3, Q4P6,   
	SUM(case when Q4P7 is NOT NULL then Q4P7 else 0 end +
	case when Q4P4 =1 then 1 else 0 end +
	case when (Q4P3 = 0 and Q4P6 in(4,6,1,16,18)) then 1 else 0 end )as total_num_jobs_hhld
	from saspdata.demographics
/*  	where Q4P7 is NOT NULL or Q4P4 =1 or (Q4P3 = 0 and Q4P6 in(4,6,1,16,18)) */
 	group by id
 	; 
 	
 quit;
 
/*  13644	12 */
/* 11917	12 */
/* 55412	12 */
/* 20287	11 */
/* 15436	10 */
 PROC SQL OUTOBS=100;
 SELECT ID,  Q2P17, SUM(Q2P17), COUNT(Q2P17)AS PPL ,AVG(Q2P17)
 FROM SASPDATA.DEMOGRAPHICS
 GROUP BY ID
 ORDER BY PPL DESC
 ;
 QUIT;
 
 PROC SQL OUTOBS=100;
 SELECT ID, AGE, Q2P17, SUM(Q2P17), COUNT(Q2P17)AS PPL ,AVG(Q2P17),round(AVG(Q2P17))
 FROM SASPDATA.HOUSING
 group by id
 ;
 QUIT;
 
 /* FIGURING OUT AVERAGE AGE OF HOUSEHOLD*/
 
 PROC SQL OUTOBS=100;
 SELECT ID, AGE, sum(AGE) as age_sum, ROUND(avg(AGE)) as avg_age, ROUND(SUM(CASE WHEN AGE >= 20 THEN AGE END)/count(CASE WHEN AGE >= 20 THEN AGE END)) as rounded
 from SASPDATA.HOUSING
 group by id
 having rounded <1
 ;
 QUIT;
 
 
 /* figuring out veteran status*/
 PROC SQL OUTOBS=100;
  SELECT ID, AGE, Q215P, Q2P15, sum(CASE WHEN Q215P=1 OR Q2P15=1 THEN 1 WHEN Q215P=0 and Q2P15=0 THEN 0 else . END) as num_veterans
  
  from SASPDATA.HOUSING
  group by id
  having num_veterans is null
 ;
 QUIT;
/*   group by idSUM(CASE WHEN Q215P=1 OR Q2P15=1 THEN 1 WHEN =1 THEN 1 END) AS SERVING_IN_ARMY */
 
 PROC SQL OUTOBS=100;
  SELECT distinct Q215P, Q2P15, CASE WHEN Q215P=1 OR Q2P15=1 THEN 1 WHEN Q215P=0 and Q2P15=0 THEN 0 else . END as status
  from SASPDATA.HOUSING

 ;
 QUIT;
 
/*  AVG OF EDUCATION LEVEL */
/* HOUSEHOLD HAS MORE THAN ONE RESIDENCE */
/* #(aVG) OF YRS PPL LIVING IN US */
/* # OF PPL SERVING IN THE ARMY */
PROC SQL;
SELECT AVG_EDU_LVL,COUNT(AVG_EDU_LVL) as count /*MODE =3*/
FROM SASPDATA.HOUSING2
GROUP BY AVG_EDU_LVL
ORDER BY COUNT DESC;
QUIT;
PROC SQL;
SELECT NUM_IN_ARMY,COUNT(NUM_IN_ARMY) as count /*MODE =0*/
FROM SASPDATA.HOUSING2
GROUP BY NUM_IN_ARMY
ORDER BY COUNT DESC;
QUIT;
PROC SQL;
SELECT RSDNC,COUNT(RSDNC) as count /*MODE =2*/
FROM SASPDATA.HOUSING2
GROUP BY RSDNC
ORDER BY COUNT DESC;
QUIT;


/* NUM_YEARS_US/*mean=45 */


DATA SASPDATA.HOUSING2_NOMISS_TEMP;
	SET SASPDATA.HOUSING2_NOMISS_HO;
	IF MISSING(AVG_EDU_LVL ) THEN AVG_EDU_LVL =3;
	IF MISSING(NUM_IN_ARMY ) THEN NUM_IN_ARMY =0;
	IF MISSING(RSDNC ) THEN RSDNC =0;
	IF MISSING(NUM_YEARS_US ) THEN NUM_YEARS_US =45;
RUN;
TITLE "SUMMARY OF DATA AT AFTER REMOVING MISSING VALUES OF HOME OWNERSHIP ";
PROC MEANS DATA = SASPDATA.HOUSING2_NOMISS_HO NMISS N MIN MEAN MEDIAN MAX ;
RUN;
TITLE "SUMMARY OF DATA AT AFTER REMOVING MISSING VALUES OF HOME OWNERSHIP ";
PROC MEANS DATA = SASPDATA.HOUSING2_NOMISS_TEMP NMISS N MIN MEAN MEDIAN MAX ;
RUN;


/* summarizing the adults and  income info*/

PROC SQL;
CREATE TABLE SASPDATA.HOUSING2_ADULTINCOME AS
SELECT 	HHINC/*HOUSE HOLD INCOME AVERAGE */
		, PEOPL - CHLDRN_LT_20 AS ADULTS/*NUMBER OF PEOPLE */ 
FROM SASPDATA.HOUSING2

;
QUIT;

PROC SQL;

SELECT ID,Q4P5,SUM(Q4P5),max(Q4P5)
FROM SASPDATA.HOUSING1_S
GROUP BY ID
;
quit;

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