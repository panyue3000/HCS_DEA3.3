



DATA DEA_4;
	SET DEA_3;
	LENGTH DECODE_BA $100.;
	LENGTH DW $10.;

	 IF BUSINESS_ACTIVITY_CODE = 'C' AND BUSINES_ACTIVITY_SUB_CODE='1' THEN Decode_BA='1.Practitioner DW30';
ELSE IF BUSINESS_ACTIVITY_CODE = 'C' AND BUSINES_ACTIVITY_SUB_CODE='4' THEN Decode_BA='2.Practitioner DW100';
ELSE IF BUSINESS_ACTIVITY_CODE = 'C' AND BUSINES_ACTIVITY_SUB_CODE='B' THEN Decode_BA='3.Practitioner DW275';
ELSE IF BUSINESS_ACTIVITY_CODE = 'C' AND BUSINES_ACTIVITY_SUB_CODE='K' THEN Decode_BA='1.1 Practitioner DW30/SW';

	 IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='F' THEN Decode_BA='4.MLP-Nurse Practitioner DW30';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='G' THEN Decode_BA='7.MLP-Physician Assistant DW30';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='H' THEN Decode_BA='5.MLP-Nurse Practitioner DW100';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='I' THEN Decode_BA='8.MLP-Physician Assistant DW100';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='K' THEN Decode_BA='6.MLP-Nurse Practitioner DW275';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='L' THEN Decode_BA='9.MLP-Physician Assistant DW275';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='Q' THEN Decode_BA='4.1 MLP-Nurse Practitioner DW30/SW';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='R' THEN Decode_BA='7.1 MLP-Physician Assistant DW30/SW';
ELSE IF BUSINESS_ACTIVITY_CODE = 'M' AND BUSINES_ACTIVITY_SUB_CODE='S' THEN Decode_BA='7.2 Assistant Physician DW30/SW';

	 IF Decode_BA in ('1.Practitioner DW30',
				      '4.MLP-Nurse Practitioner DW30',
					  '7.MLP-Physician Assistant DW30',
					  '1.1 Practitioner DW30/SW',
					  '4.1 MLP-Nurse Practitioner DW30/SW',
					  '7.1 MLP-Physician Assistant DW30/SW',
					  '7.2 Assistant Physician DW30/SW') THEN DW='DW-30';

ELSE IF Decode_BA IN ('2.Practitioner DW100',
					  '5.MLP-Nurse Practitioner DW100',
					  '8.MLP-Physician Assistant DW100') THEN DW='DW-100';
ELSE IF Decode_BA IN ('3.Practitioner DW275',
					  '6.MLP-Nurse Practitioner DW275',
					  '9.MLP-Physician Assistant DW275') THEN DW='DW-275';

/*add an additional measure where we count the number of DW/30SW codes?*/
     IF Decode_BA IN (  '1.1 Practitioner DW30/SW',
						'4.1 MLP-Nurse Practitioner DW30/SW',
						'7.1 MLP-Physician Assistant DW30/SW',
						'7.2 Assistant Physician DW30/SW') THEN DW30_SW='DW30/SW';

RUN;

proc freq data=dea_4;
tables decode_ba record_vintage county_name2 zip_code county_name2*zip_code;
run;

proc freq data=dea_4;
tables decode_ba BUSINESS_ACTIVITY_CODE BUSINES_ACTIVITY_SUB_CODE dw 
	   Decode_BA*dw BUSINESS_ACTIVITY_CODE*BUSINES_ACTIVITY_SUB_CODE*decode_ba;
run;

/*ADD QUARTER*/

DATA DEA_4_0;
SET DEA_4;

     IF MONTH_RECORD_VIN IN (1,2,3) THEN QUARTER_RECORD_VIN='Q1';
ELSE IF MONTH_RECORD_VIN IN (4,5,6) THEN QUARTER_RECORD_VIN='Q2';
ELSE IF MONTH_RECORD_VIN IN (7,8,9) THEN QUARTER_RECORD_VIN='Q3';
ELSE IF MONTH_RECORD_VIN IN (10,11,12) THEN QUARTER_RECORD_VIN='Q4';

QUARTER_RECORD_VIN1=catx('-', YEAR_RECORD_VIN, QUARTER_RECORD_VIN);

RUN;

proc freq data=dea_4_0;
tables record_vintage;
run;