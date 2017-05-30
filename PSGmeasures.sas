*From Laptop;
PROC IMPORT OUT= SASUSER.PNSD
            DATAFILE= "C:\Users\Appa\Dropbox\Work\Studies\ShiftWork\Data Analysis\SAS analysis\PNSDcoredatafile2013-7-3-MLL.xls" 
            DBMS=EXCEL REPLACE;
    SHEET="PNSDcoredatafile";
	GETNAMES=YES;
    MIXED=NO;
    SCANTEXT=YES;
    USEDATE=YES;
    SCANTIME=YES;
RUN;
DATA PNSD;
  SET 'C:\Users\Appa\Documents\My SAS Files(32)\9.2\pnsd.sas7bdat';
RUN;

*From Work Computer;
PROC IMPORT OUT= SASUSER.PNSD
            DATAFILE= "C:\Documents and Settings\mll66\My Documents\Drop
box\Work\ShiftWork\sas analysis\PNSDcoredatafile2012-12-30MLL.csv"  
          DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
DATA PNSD;
  SET 'C:\Documents and Settings\mll66\My Documents\My SAS Files\9.2\pnsd.sas7bdat';
RUN;


*From Home Computer;

PROC IMPORT OUT= SASUSER.PNSD
            DATAFILE= "D:\Dropbox\Dropbox\Work\ShiftWork\SAS analysis\PNSDcoredatafil
e2012-12-30MLL.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
DATA PNSD;
  SET 'C:\Users\Lee\Documents\My SAS Files(32)\9.2\pnsd.sas7bdat';
RUN;

* DATA EXCLUSION

*Excludes data in between surveys;
*Excludes row labelled Segment 8;
*Excludes data for LOCF data;
data PNSD1;

if Segment=8 then
delete;
if 	mins_from_optalert_start_time=0 then
delete;
run;


title PSG values;
proc means data=pnsd1 n sum nway;
class condition;
class subject_no;
output out=PSGSubjectxCondition sum=Alpha theta SEM ;
var Alpha theta SEM;
run;

title PSG values;
proc means data=pnsd1 n sum nway;
class condition;
output out=PSGSubjectxCondition sum=Alpha theta SEM ;
var Alpha theta SEM;
run;

*creates columns for percentage of PSG value against number of observations
Empty cells indicate 0 score of PSG event, so replace . with 0;
data PSGSubjectxCondition1;
set PSGSubjectxCondition;
Alphapercent = alpha / _FREQ_;
Thetapercent = theta / _FREQ_;
SEMpercent = SEM / _FREQ_;
if Alphapercent=. then Alphapercent =0 ;
if thetapercent=. then thetapercent =0 ;
if SEMpercent=. then SEMpercent =0 ;
run;

*Mean by condition;
proc means data=PSGSubjectxCondition1 n sum nway;
class condition;
output out=PSGxCondition mean=Alpha theta SEM Alphapercent thetapercent SEMpercent;
var Alpha theta SEM Alphapercent thetapercent SEMpercent;
run;
*Creates data set for post shift data;
DATA PSGPairedData1;
SET PSGSubjectxcondition1;
 if condition = 'post shift'; 
  rename Alphapercent=shiftalphapercent thetapercent=shiftthetapercent sempercent=shiftsempercent;
RUN;

*Creates data set for post sleep data;
DATA PSGPairedData2;
SET PSGSubjectxcondition1;
 if condition = 'post sleep'; 
  RUN;

*Merges two data sets;
Data PSGPairedData3;
merge PSGPairedData2 PSGPairedData1;
by subject_no;
run;

*PSG: Test for Normality;
proc univariate plot normal data=PSGPairedData3;
histogram;
var alphapercent shiftalphapercent thetapercent shiftthetapercent sempercent shiftsempercent;
run;

data psgPairedDataSet3;
set psgPairedDataSet3;
if cmiss(of _all_) then delete;
run;

DATA PSGpairedData4;
Set PSGpairedData3;
dalpha=alphapercent-shiftalphapercent;
dtheta= thetapercent-shiftthetapercent;
dsem=sempercent- shiftsempercent;
run;
PROC UNIVARIATE data=psgpaireddata4;
Var dalpha dtheta dsem;
Run;

*PSG variables. Paired t-tests;

proc ttest;
      paired alphapercent*shiftalphapercent;
   run;
proc ttest;
      paired thetapercent*shiftthetapercent;
   run;
   proc ttest;
      paired sempercent*shiftsempercent;
   run;

*Sum data for Post Shift PSG variables;
proc print data = Psgpaireddata1;
sum _Freq_ alpha theta SEM;
run;

*Sum data for Post Sleep PSG variables;
proc print data = Psgpaireddata2;
sum _Freq_ alpha theta SEM;
run;
