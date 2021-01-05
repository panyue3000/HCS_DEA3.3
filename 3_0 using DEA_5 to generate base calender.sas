
/*YEAR*/
PROC SQL;
   CREATE TABLE CAL_YEAR AS 
   SELECT DISTINCT 
		  YEAR_RECORD_VIN AS YEAR
      FROM DEA_4_0 T1
      GROUP BY YEAR_RECORD_VIN
	  ORDER BY YEAR_RECORD_VIN;
QUIT;

/*QUARTER*/
PROC SQL;
   CREATE TABLE CAL_QTR_0 AS 
   SELECT DISTINCT 
   		  YEAR_RECORD_VIN AS YEAR,
		  MONTH_RECORD_VIN AS MONTH,
          INPUT(substr(CAT(T1.QUARTER_RECORD_VIN),2,1),1.) AS QUARTER
      FROM DEA_4_0 T1
      GROUP BY YEAR_RECORD_VIN,
			   CALCULATED QUARTER
      ORDER BY YEAR_RECORD_VIN,
			   CALCULATED QUARTER;
QUIT;

/**********************************************DELETE QUARTER IF IT'S NOT REACH TO CORRECT MONTH******************************/
DATA CAL_QTR_1;
SET CAL_QTR_0;
BY YEAR QUARTER;

/*********************************REMEMBER TO CHANGE THE YEAR HERE************************************************************************************/
IF YEAR=2021 THEN DO;
	IF LAST.MONTH/3<last.quarter then delete;
END;
run;

PROC SQL;
   CREATE TABLE CAL_QTR AS 
   SELECT DISTINCT 
		 YEAR,
		 QUARTER
		FROM WORK.CAL_QTR_1 t1
;
QUIT;


/*MONTH*/
PROC SQL;
   CREATE TABLE CAL_MONTH AS 
   SELECT DISTINCT 
   		  YEAR_RECORD_VIN AS YEAR,
		  MONTH_RECORD_VIN AS MONTH
      FROM DEA_4_0 T1
      GROUP BY YEAR_RECORD_VIN,
			   MONTH_RECORD_VIN
      ORDER BY YEAR_RECORD_VIN,
			   MONTH_RECORD_VIN;
QUIT;

DATA CAL_0;
SET CAL_YEAR CAL_QTR CAL_MONTH;
RUN;

PROC SORT DATA=CAL_0;
BY YEAR MONTH;
RUN;

DATA CAL_1;
SET CAL_0;
BY YEAR MONTH;
	IF YEAR=2021 THEN DO;
/*DELETE YEAR IF MONTH NOT REACH TO 12*/
		IF LAST.MONTH<12 THEN DO;
			IF QUARTER=. AND MONTH=. THEN DELETE;
			END;
	END;
RUN;


/*TEMPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPappend empty 2020 10 to data*/
DATA TEMP;
YEAR=2020;
MONTH=10;
RUN;

DATA CAL_1;
SET CAL_0 TEMP;
RUN; 