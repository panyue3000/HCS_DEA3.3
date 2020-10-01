/**************************************YEAR**********************************/

/*order by state county year dea_reg_num then select the last record*/
PROC SQL;
   CREATE TABLE DEA_DW_Y_0 AS 
   SELECT DISTINCT	 
			T1.DW,
			T1.STATE,
			t1.reporterid,
            t1.YEAR_RECORD_VIN,
			T1.NAME,
			t1.dea_reg_num,
			input(SUBSTR(DW,4,3),3.) as level
			FROM DEA_5 t1
      ORDER BY T1.DW,
			   T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
			   T1.dea_reg_num,
     		   level
;
QUIT;

DATA DEA_DW_Y_1;
SET DEA_DW_Y_0;
BY DW STATE reporterid YEAR_RECORD_VIN dea_reg_num ;
IF LAST.dea_reg_num;
RUN;



PROC SQL;
   CREATE TABLE DEA_DW_Y AS 
   SELECT DISTINCT 
   		  T1.DW,
   		  T1.STATE,
		  t1.reporterid,
		  YEAR_RECORD_VIN AS YEAR,
          count (distinct dea_reg_num) as sum_ct
      FROM DEA_DW_Y_1 t1
      GROUP BY T1.DW,
			   T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN
;
QUIT;


/***********************************************QUARTER*******************************************/
PROC SQL;
   CREATE TABLE DEA_DW_QTR_0 AS 
   SELECT DISTINCT 
			T1.DW,
			T1.STATE,
			t1.reporterid,
            t1.YEAR_RECORD_VIN,
			T1.NAME,
			t1.dea_reg_num,
            INPUT(substr(CAT(T1.QUARTER_RECORD_VIN),2,1),1.) AS QUARTER,
		    input(SUBSTR(DW,4,3),3.) as level
			FROM DEA_5 t1
      ORDER BY T1.DW,
			   T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
			   QUARTER,
			   T1.dea_reg_num,
     		   level
;
QUIT;

DATA DEA_DW_QTR_1;
SET DEA_DW_QTR_0;
BY DW STATE reporterid YEAR_RECORD_VIN QUARTER dea_reg_num ;
IF LAST.dea_reg_num;
RUN;



PROC SQL;
   CREATE TABLE DEA_DW_QTR AS 
   SELECT DISTINCT 
   		  T1.DW,
		  T1.STATE,
		  t1.reporterid,
		  YEAR_RECORD_VIN AS YEAR,
		  QUARTER,
          count (distinct dea_reg_num) as sum_ct
      FROM DEA_DW_QTR_1 t1
      GROUP BY T1.DW,
			   T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
			   QUARTER
;
QUIT;


/**********************************************MONTH***********************************************/
PROC SQL;
   CREATE TABLE DEA_DW_MONTH_0 AS 
   SELECT DISTINCT 
			T1.DW,
			T1.STATE,
			t1.reporterid,
            t1.YEAR_RECORD_VIN,
			T1.MONTH_RECORD_VIN,
			T1.NAME,
			t1.dea_reg_num,
		    input(SUBSTR(DW,4,3),3.) as level
			FROM DEA_5 t1
      ORDER BY T1.DW,
			   T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
			   MONTH_RECORD_VIN,
			   T1.dea_reg_num,
     		   level
;
QUIT;

DATA DEA_DW_MONTH_1;
SET DEA_DW_MONTH_0;
BY DW STATE reporterid YEAR_RECORD_VIN MONTH_RECORD_VIN dea_reg_num ;
IF LAST.dea_reg_num;
RUN;

PROC SQL;
   CREATE TABLE DEA_DW_MONTH AS 
   SELECT DISTINCT 
   		  T1.DW,
		  T1.STATE,
		  t1.reporterid,
		  YEAR_RECORD_VIN AS YEAR,
		  MONTH_RECORD_VIN AS MONTH,
          count (distinct dea_reg_num) as sum_ct
      FROM DEA_DW_MONTH_1 t1
      GROUP BY T1.DW,
			   T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
		       MONTH
;
QUIT;

/*COMBINE ALL*/
DATA DEA_DW_0;
SET DEA_DW_Y DEA_DW_QTR DEA_DW_MONTH;
RUN;


/*JOIN REPORTER ID*/
PROC SQL;
   CREATE TABLE DEA_DW_1 AS 
   SELECT DISTINCT 
		  t1.*, 
		  T2.POP
      FROM DEA_DW_0 t1
		   LEFT JOIN POPEST T2 ON t1.ReporterId=T2.ReporterId AND 
								  T1.YEAR=T2.YEAR
      ORDER BY T1.DW,
			   T1.STATE,
			   t1.ReporterId,
			   T1.YEAR,
			   T1.QUARTER,
			   T1.MONTH
;
QUIT;


/*FORMAT ACCORDING TO THE HCS REQUIREMENT*/
PROC SQL;
   CREATE TABLE DEA_DW_2 AS 
   SELECT DISTINCT 
   		  DW,
	      STATE,
		  ReporterId,
		  CASE WHEN DW='DW-30' THEN '3.3.30' 
		  	   WHEN DW='DW-100' THEN '3.3.100'
			   WHEN DW='DW-275' THEN '3.3.275' 
				END AS MEASUREID,
		  SUM_CT AS NUMERATOR,
		  POP AS DENOMINATOR,
		  MONTH,
		  QUARTER,
		  YEAR,
		  CASE WHEN SUM_CT EQ . THEN 1
		       ELSE 0 END AS IsSuppressed,
		  "This data is from DEA &DEA_VERSION." AS NOTES,
		  '' AS STRATIFICATION
      FROM DEA_dw_1
      ORDER BY DW,
			   REPORTERID,
			   YEAR,
			   QUARTER,
			   MONTH
;
QUIT;


/*DELETE PARTIAL COUNTY WITHOUT A REPORT ID*/
DATA DEA_DW;
SET DEA_DW_2;
WHERE REPORTERID NE '';
/*DROP DW;*/
RUN;


/*COMBINE WITH DEA_ALL*/
DATA DEA33_FINAL_EXCEL;
LENGTH MEASUREID $50.;
SET DEA_ALL DEA_DW;
IF DW='' THEN DW='OVERALL';
RUN;


PROC SQL;
   CREATE TABLE DEA33_FINAL_EXCEL_0 AS 
   SELECT DISTINCT 
		  T1.MEASUREID,
   	      T1.STATE,
		  T2.COMMUNITY AS COUNTY_NAME2,
	      T1.ReporterId,
		  T1.NUMERATOR,
		  T1.DENOMINATOR,
		  T1.MONTH,
		  T1.QUARTER,
		  T1.YEAR,
		  T1.IsSuppressed,
		  T1.NOTES,
		  T1.STRATIFICATION,
		  DW
      FROM DEA33_FINAL_EXCEL AS T1 LEFT JOIN MAP.REPORTER_LIST T2 ON t1.REPORTERID=T2.REPORTERID
      ORDER BY MEASUREID,
			   REPORTERID,
			   YEAR,
			   QUARTER,
			   MONTH
;
QUIT;



/*SOURCE FILE FOR HCS*/

PROC SQL;
   CREATE TABLE DEA33_FORHCS_&DATE. AS 
   SELECT DISTINCT 
			T1.STATE,
	        T2.COMMUNITY AS COUNTY,
 			t1.reporterid,
            t1.YEAR_RECORD_VIN AS YEAR,
            INPUT(substr(CAT(T1.QUARTER_RECORD_VIN),2,1),1.) AS QUARTER,
			T1.MONTH_RECORD_VIN AS MONTH,
			T1.NAME,
			t1.dea_reg_num,
			T1.DW
			FROM DEA_4_1 t1 LEFT JOIN MAP.REPORTER_LIST T2 ON t1.REPORTERID=T2.REPORTERID
      ORDER BY T1.STATE,
			   t1.reporterid,
               t1.YEAR_RECORD_VIN,
			   T1.MONTH_RECORD_VIN,
			   T1.DW
;
QUIT;



