/*ORDER BY STATE, COUNTY, YEAR, MONTH*/
/*1)	From the DEA CSA Active Registrant database, create a dataset that includes each waived provider’s */
/*DEA number, HCS community, and prescriber level for each month in which they are counted for measure 3.2. */
/*Note that in 3.2, the monthly prescriber level selected for each provider is the provider’s maximum prescriber level for the month*/

PROC SQL;
   CREATE TABLE DEA_5_ORDER AS 
   SELECT DISTINCT 
			T1.STATE,
			t1.reporterid,
            t1.YEAR_RECORD_VIN,
			T1.MONTH_RECORD_VIN,
			T1.NAME,
			t1.dea_reg_num,
			T1.QUARTER_RECORD_VIN,
			input(SUBSTR(DW,4,3),3.) as level
			FROM DEA_5 t1
      ORDER BY T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
			   T1.MONTH_RECORD_VIN,
			   T1.NAME,
     		   level
;
QUIT;



/**************************************YEAR*********USE DEA_REG_NUM=MB2285864 TO CHECK*************************/

/*order by state county year dea_reg_num then select the last record*/
PROC SQL;
   CREATE TABLE DEA_Y_0 AS 
   SELECT DISTINCT 
			T1.STATE,
			t1.reporterid,
            t1.YEAR_RECORD_VIN,
			T1.NAME,
			t1.dea_reg_num,
			input(SUBSTR(DW,4,3),3.) as level
			FROM DEA_5 t1
      ORDER BY T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
			   T1.dea_reg_num,
     		   level
;
QUIT;

DATA DEA_Y_1;
SET DEA_Y_0;
BY STATE reporterid YEAR_RECORD_VIN dea_reg_num ;
IF LAST.dea_reg_num;
RUN;



PROC SQL;
   CREATE TABLE DEA_Y AS 
   SELECT DISTINCT 
   		  T1.STATE,
		  t1.reporterid,
		  YEAR_RECORD_VIN AS YEAR,
          count (distinct dea_reg_num) as sum_ct
      FROM DEA_Y_1 t1
      GROUP BY T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN
;
QUIT;

/***********************************************QUARTER*******************************************/
PROC SQL;
   CREATE TABLE DEA_QTR_0 AS 
   SELECT DISTINCT 
			T1.STATE,
			t1.reporterid,
            t1.YEAR_RECORD_VIN,
			T1.NAME,
			t1.dea_reg_num,
            INPUT(substr(CAT(T1.QUARTER_RECORD_VIN),2,1),1.) AS QUARTER,
		    input(SUBSTR(DW,4,3),3.) as level
			FROM DEA_5 t1
      ORDER BY T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
			   QUARTER,
			   T1.dea_reg_num,
     		   level
;
QUIT;

DATA DEA_QTR_1;
SET DEA_QTR_0;
BY STATE reporterid YEAR_RECORD_VIN QUARTER dea_reg_num ;
IF LAST.dea_reg_num;
RUN;



PROC SQL;
   CREATE TABLE DEA_QTR AS 
   SELECT DISTINCT 
   		  T1.STATE,
		  t1.reporterid,
		  YEAR_RECORD_VIN AS YEAR,
		  QUARTER,
          count (distinct dea_reg_num) as sum_ct
      FROM DEA_QTR_1 t1
      GROUP BY T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
			   QUARTER
;
QUIT;

/**********************************************MONTH***********************************************/
PROC SQL;
   CREATE TABLE DEA_MONTH_0 AS 
   SELECT DISTINCT 
			T1.STATE,
			t1.reporterid,
            t1.YEAR_RECORD_VIN,
			T1.MONTH_RECORD_VIN,
			T1.NAME,
			t1.dea_reg_num,
		    input(SUBSTR(DW,4,3),3.) as level
			FROM DEA_5 t1
      ORDER BY T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
			   MONTH_RECORD_VIN,
			   T1.dea_reg_num,
     		   level
;
QUIT;

DATA DEA_MONTH_1;
SET DEA_MONTH_0;
BY STATE reporterid YEAR_RECORD_VIN MONTH_RECORD_VIN dea_reg_num ;
IF LAST.dea_reg_num;
RUN;

PROC SQL;
   CREATE TABLE DEA_MONTH AS 
   SELECT DISTINCT 
   		  T1.STATE,
		  t1.reporterid,
		  YEAR_RECORD_VIN AS YEAR,
		  MONTH_RECORD_VIN AS MONTH,
          count (distinct dea_reg_num) as sum_ct
      FROM DEA_MONTH_1 t1
      GROUP BY T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
		       MONTH
;
QUIT;


DATA DEA_ALL_0;
SET DEA_Y DEA_QTR DEA_MONTH;
RUN;


/*JOIN REPORTER ID*/
PROC SQL;
   CREATE TABLE DEA_ALL_1 AS 
   SELECT DISTINCT 
		  t1.*, 
		  T3.POP
      FROM DEA_ALL_0 t1
		   LEFT JOIN POPEST T3 ON t1.reporterid=T3.reporterid AND 
								  T1.YEAR=T3.YEAR
      ORDER BY T1.STATE,
			   t1.reporterid,
			   T1.YEAR,
			   T1.QUARTER,
			   T1.MONTH
;
QUIT;


/*FORMAT ACCORDING TO THE HCS REQUIREMENT*/
PROC SQL;
   CREATE TABLE DEA_ALL_2 AS 
   SELECT DISTINCT 
   	      STATE,
		  ReporterId,
		  '3.3' AS MEASUREID,
		  SUM_CT AS NUMERATOR,
		  POP AS DENOMINATOR,
		  MONTH,
		  QUARTER,
		  YEAR,
		  CASE WHEN SUM_CT EQ . THEN 1
		       ELSE 0 END AS IsSuppressed,
		   "This data is from DEA &DEA_VERSION."  AS NOTES,
		  '' AS STRATIFICATION
      FROM DEA_ALL_1
      ORDER BY REPORTERID,
			   YEAR,
			   QUARTER,
			   MONTH
;
QUIT;


/*DELETE PARTIAL COUNTY WITHOUT A REPORT ID*/
DATA DEA_ALL;
SET DEA_ALL_2;
WHERE REPORTERID NE '';
RUN;

