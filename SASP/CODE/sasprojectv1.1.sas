*SAS PROJECT;

proc SQL;
	SELECT Name,LABEL
	FROM saspdata.Demographicvars;
quit;
Data saspdata.var;
	input name $
DATALINES;

proc SQL outobs=10;
	SELECT *
	FROM saspdata.Demographics;
quit;

proc export data= saspdata.Demographicvars outfile="C:\Users\KC\Documents\Metro College\SASP\data\demographicvars.csv" dbms=csv;run;
proc export data= saspdata.Demographics outfile="C:\Users\KC\Documents\Metro College\SASP\data\demographics.csv" dbms=csv;run;