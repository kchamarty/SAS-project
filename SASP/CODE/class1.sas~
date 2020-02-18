/* Transpose narrow data set to wide data set.*/ 
proc print data=saspdata.quiz_01;run;

proc sort data =  saspdata.quiz_01 out = saspdata.quiz_01_S;
by stid gender;
run;
proc transpose data=saspdata.quiz_01_S  out=saspdata.quiz_01_T(DROP=_name_) prefix=score_ ;
	ID subj;
	var score;
	by stid gender;
	
run;

PROC SURVEYSELECT data=sashelp.cars out =saspdata. outall method =srs samprate=.8;
/* sampsize= 30; */
strata origin;
run;
