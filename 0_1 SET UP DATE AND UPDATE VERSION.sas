
/*SET UP DATE AND UPDATE VERSION */

%LET DATE=010421;

%let DEA_VERSION= V1.14;

/*check date*/

proc freq data=redivis_export;
tables RECORD_VINTAGE;
run;