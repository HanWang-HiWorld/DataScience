/* Project: Mapping a list of company names with customer employer name record -------- */
/* Author: Han Wang @ 22 Jun. 2019 ---------------------------------------------------- */

/* ---------------  0.Set Environment ------------------------------------------------- */
libname sample "/sasdata/......./DAT";
/* --------------- 1. Set Customer Base ----------------------------------------------- */
%let base_dt = 30JUN2019;
proc sql;
    create table sample.emp_name as 
    select cust_id
        , join_date
		, put(join_date, yymmn6.) as join_mth length=20
		, intck('month', join_date, "&base_dt."d) as tenture
		, empyr_name
    from cust_base
	where cust_id in (select cust_id from selected_base)
	order by cust_id, join_date
	;
quit;

/* --------------- 2. Read In Company Name -------------------------------------------- */
proc import datafile = "/.../company_list.xlsx"
            out = company_list
			dbms = xlsx
			replace;
			getnames = yes;
run;

options validvarname=any;
data sample.company_list;
    set company_list;
	com_name_cln = compress(company_name, "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^&*()-_=+\|[]{};:',.<>?/ ", "kis");
run;

/* --------------- 3-1. Employer Name Match ------------------------------------------- */
** 3-1-1 NUll employer name;
proc sql;
    create table sample.null_emp_name_001 as 
	select * from sample.emp_name
	where empyr_name in ('', ' ', '*', '-', 'NA', 'N/A', 'N\A', 'na', 'n/a', 'n\a')
	or (length(empyr_name=1)
	order by cust_id
	;
quit;

** 3-2-1 Exact Match;
proc sql;
    create table name1 as
	select *
	     , compress(upcase(compress(empyr_name, "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", "kis"))) as emp_name_match_id
	from sample.emp_name
	where cust_id not in (select cust_id from sample.null_emp_name_001)
	order by emp_name_match_id
	;
quit;

data name2;
    set sample.company_list;
	emp_name_match_id = compress(upcase(compress(com_name_cln, "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", "kis")));
proc sort; by emp_name_match_id;
run;

proc sql;
    create table ext_match as
	select *
	from name1 as a 
	inner join name2 as b on a.emp_name_match_id = b.emp_name_match_id
	;
quit;

proc sort data = ext_match out = sample.ext_match_002 dupout = chk2 nodupkey;
    by cust_id;
run;

** 3-3 Fuzzy Match;
** Fuzzy matching algorithms apply to the rest of customers with non-missing employer information;
proc sql;
    create table sample.fuzzy_base as 
	select * from sample.emp_name\
	where cust_id not in (select cust_id from sample.null_emp_name_001)
	and cust_id not in (select cust_id from sample.ext_match_002)
	order by cust_id
	;
quit;

** 3-3-1 Fuzzy Match -- COMPGED;
proc sql;
    create table sample.compged_base_003 as
	select a.*
	     , b.*
		 , compged(upcase(compress(empyr_name, "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", "kis")),
		           upcase(compress(com_name_cln, "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", "kis"))) as compged_score
	from sample.fuzzy_base as a, sample.company_list as b 
/* where calculated compged_score le 2000 */
	order by cust_id, compged_score;
quit;

** QC == Start;
proc sql;
    select count(*) as n1
	     , count(distinct cust_id) as n2
	from sample.compged_base_003
	;
quit;
** QC == End, all compged_score gt than 2000

** 3-3-2 Fuzzy Match -- INDEX + COMPGED + SPEDIS + COMPLEV + SOUNDEX;
data sample.spedis_index_soundex_base_003;
    set sample.compged_base_003;
	empyr_name_base = upcase(compress(empyr_name, "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", "kis"));
	com_name_base = upcase(compress(com_name_cln, "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", "kis"));
	
	index_score = index(com_name_base, empyr_name_base);
	spedis_score = spedis(empyr_name_base, com_name_base);
	complev_score = complev(empyr_name_base, com_name_base);
	
	empyr_name_base_soundex = soundex(empyr_name_base);
	com_name_base_soundex = soundex(com_name_base);
	
	if empyr_name_base_soundex = com_name_base_soundex then soundex_idc = "Y";
	else                                                    soundex_idc = "N";
	
	if index_score > 0 then index_idc = "Y";
	else                    index_idc = "N";                
run;

** 3-3-2-------@1 COMPGED (le 600) + SPEDIS;
data compged_spedis_match_003_01;
    set sample.spedis_index_soundex_base_003;
	if compged_score <= 600;
	if 10 <= compged_score <= 100 and spedis_score > 100 then delete;
	if 110 <= compged_score <= 190 and spedis_score >= 50 then delete;
	if 200 <= compged_score <= 290 and spedis_score > 30 then delete;
	if 300 <= compged_score <= 390 and spedis_score >= 30 then delete;
	if 400 <= compged_score <= 590 and spedis_score > 25 then delete;
    if length(compress(empyr_name)) <= 10 and compged_score >= 100 then delete;
proc sort; by cust_id compged_score spedis_score;
run;

proc sort data = compged_spedis_match_003_01
          out = sample.compged_spedis_match_003_01
		  nodupkey
		  ;
    by cust_id;
run;

** Remove Invalid Employer Name;
proc sql;
    create table compged_invalid_003_00 as 
	select * 
	from sample.spedis_index_soundex_base_003
	where cust_id not in (select cust_id from sample.compged_spedis_match_003_01)
	and (length(empyr_name) = 1 or empyr_name in ('', ' ', '-', 'NA', 'N/A', 'N\A'))
	;
quit;
proc sort data = compged_invalid_003_00
          out = sample.compged_invalid_003_00
		  nodupkey
		  ;
	by cust_id;
run;


** 3-3-2-------@2 COMPGED + SPEDIS + COMPLEV;
proc sql;
    create table compged_base_003_02 as 
	select *
	from sample.spedis_index_soundex_base_003
	where cust_id not in (select cust_id from sample.compged_spedis_match_003_01)
	and cust_id not in (select cust_id from sample.compged_invalid_003_00)
	;
quit;

** 01 - COMPGED le 600 + min(SPEDIS) + INDEX > 0;
data compged_index_003_02_00;
    set compged_base_003_02;
	index_score2 = index(compress(upcase(strip(com_name_cln))), compress(upcase(strip(emp))));
proc sort; by cust_id compged_score;
run;

data compged_index_003_02_00;
    set compged_index_003_02_00;
	if index_score2 ~= 0 and compged_score <= 600;
run;

proc sort data = compged_index_003_02_00
          out = sample.compged_index_003_02_00;
		  nodupkey
		  ;
    by cust_id;
run;


** 02 - COMPGED le 600 ||| gt 600 + min(SPEDIS) + min(COMPLEV_SCORE);
proc sql;
    create table compged_003_02_01 as
	select * 
	from compged_base_003_02
	where cust_id not in (select cust_id from sample.compged_index_003_02_00)
	;
quit;

proc sort data = compged_003_02_01;
    by cust_id compged_score spedis_score complev_score;
run;

proc sort data = compged_003_02_01 out = sample.compged_003_02_01 nodupkey;
    by cust_id;
run;


** 3-4-1 ------- Summary;
data no_info1;
    set sample.null_emp_name_001 (keep = cust_id);
	format match_level $50.;
	match_level = '00. Null Employer Name';
proc sort; by cust_id;
run;

data exact_match;
    set sample.ext_match_002;
	format match_level $50.;
	match_level = 'L1. Exact Match';
proc sort; by cust_id;
run;

data match2;
    set sample.compged_spedis_match_003_01;
	format match_level $50.;
	match_level = 'L2. Strict Match by COMPGED & SPEDIS';
proc sort; by cust_id;
run;

data match3;
    set sample.compged_index_003_02_00;
	format match_level $50.;
	match_level =  'L3. Strict Match by INDEX & COMPGED & SPEDIS';
proc sort; by cust_id;
run;

data match4;
    set sample.compged_003_02_01;
	format match_level $50.;
	match_level = 'L4. Fuzzy Match by COMPGED & SPEDIS & COMPLEV';
proc sort; by cust_id;
run;

data sample.match_level;
    set no_info1 exact_match match2 match3 match4;
proc sort; by cust_id;
run;

data sample.macth_all;
    merge sample.emp_name (in = ina)
        sample.match_level
        ;		
    by cust_id;
	if ina;
proc sort; by cust_id;
run;
