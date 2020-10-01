
libname export "C:\Users\panyue\Box\1 Healing Communities\DATA_NYS\PAN\3.3 DEA Active\HCS deliveries\RAW";

/*1 INTERNAL DELIVERY FILE FOR EXCEL */
/*DEA33_FINAL_EXCEL_&DATE.*/
%macro csv_export (DATA);

proc export data=&DATA. dbms=CSV
outfile= %TSLIT (C:\Users\panyue\Box\1 Healing Communities\DATA_NYS\PAN\3.3 DEA Active\Export\RAW\&DATA..CSV)
replace;
run;

%mend csv_export;

%csv_export(DEA33_FINAL_EXCEL_&DATE.);




/*2 EXTERNAL DELIVERY FILE FOR EXCEL */
/*DEA33_FINAL_&DATE.*/
/*DEA33_FORHCS_&DATE.*/
%macro csv_export (DATA);

proc export data=&DATA. dbms=CSV
outfile= %TSLIT (C:\Users\panyue\Box\1 Healing Communities\DATA_NYS\PAN\3.3 DEA Active\HCS deliveries\RAW\&DATA..CSV)
replace;
run;

%mend csv_export;

%csv_export(DEA33_FINAL_&DATE.);
%csv_export(DEA33_FORHCS_&DATE.);


/*1 COMPARISON INTERNAL DELIVERY FILE FOR EXCEL  */
/*CREATE THE COLUMN TO COMPARE TWO DELIVERIES AND RANK BY %CHANGE*/
