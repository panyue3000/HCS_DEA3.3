
proc sort data=DEA33_FINAL_comb_fiscal_&DATE.;
by reporterid year month quarter;
run;

data DEA;
set DEA33_FINAL_comb_fiscal_&DATE.;
run;

data m33;
set DEA;
if measureid eq '3.3';
rename
numerator=N33;
drop issuppressed denominator;
run;

data m3330;
set DEA;
if measureid eq '3.3.30';
rename
numerator=N3330;
drop issuppressed denominator;
run;

data m33100;
set DEA;
if measureid eq '3.3.100';
rename
numerator=N33100;
drop issuppressed denominator;
run;

data m33275;
set DEA;
if measureid eq '3.3.275';
rename
numerator=N33275;
drop issuppressed denominator;
run;

Data m33wide;
merge m33 m3330 m33100 m33275;
by reporterid year month quarter;
Calcsum=n3330+n33100+n33275;
If calcsum=n33 then comparison='equal';
If calcsum>n33 then comparison='GT';
if calcsum<n33 then comparison='LT';
difference=calcsum-n33;
if reporterid in ('0368','0369','0370') then delete;
run;
Title 'Look at Sum of submeasures of 3.3 and compare to 3.3';
proc freq data=m33wide;
table comparison difference;
run;
/*
proc freq data=m33wide;
table reporterid;
run;
*/
proc freq data=m33wide;
where month eq . and quarter=.;
table Year*difference;
run;
