
/*SET UP DATE AND UPDATE VERSION */

%LET DATE=030821;

%let DEA_VERSION= V1.16;

/*check date*/

proc freq data=redivis_export;
tables RECORD_VINTAGE;
run;