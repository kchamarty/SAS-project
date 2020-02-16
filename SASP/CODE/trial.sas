/*samples trial and errors*/

/*Q4P6  */

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