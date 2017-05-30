*From Work Computer;
PROC IMPORT OUT= SASUSER.PNSD
            DATAFILE= "C:\Documents and Settings\mll66\My Documents\Drop
box\Work\ShiftWork\PNSDcoredatafile2012-11-20MLL.csv"  
          DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
DATA PNSD;
  SET 'C:\Documents and Settings\mll66\My Documents\My SAS Files\9.2\pnsd.sas7bdat';
RUN;


*From Home Computer;

PROC IMPORT OUT= SASUSER.PNSD
            DATAFILE= "D:\Dropbox\Dropbox\Work\ShiftWork\PNSDcoredatafil
e2012-12-24MLL.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
DATA PNSD;
  SET 'C:\Users\Lee\Documents\My SAS Files(32)\9.2\pnsd.sas7bdat';
RUN;

*Analysis of Max JDS score;

data PNSD;
modify PNSD;
if Exclusion__JDS_3=1 or Exclusion__Raw_Data=1 or Exclusion__Raw_Data__Visual_=1 or condition="postshift2" or segment=8 then 
do;
JDS =.;
end;
if  Exclusion__Raw_Data=1 then
do;
Mean_Neg_IED =.;
std_Dev_Neg_IED =.;
__Time_with_Eyes_Closed=.;
Mean_BTD=.;
Std_Dev_BTD=.;
Mean_Pos_AVR=.;
StdDev_Pos_AVR=.;
Mean_Neg_AVR=.;
Std_Dev_Neg_AVR=.;
__Long_Closures=.;
Mean_DOQ=.;
Std_Dev_DOQ=.;
end;
run;

*By condition and Subject;
proc means data=pnsd n mean median max std var nway;
class condition;
class subject_no;
var JDS Mean_Neg_IED;
output out=SubjectxCondition mean=JDS Mean_Neg_IED;
run;
*Delete Post-Shift2 data;
data SubjectxCondition;
set SubjectxCondition;
if cmiss(of _all_) then delete;
run;

*By condition;
proc means data=subjectxcondition n mean median max std var nway;
class condition;
var JDS Mean_Neg_IED;
output out=Condition mean=JDS Mean_Neg_IED;
run;


*Delete Post-Shift2 data;

proc means data=pnsd n mean median max std var nway;
class condition;
class subject_no;
var JDS Mean_Neg_IED;
output out=maxSubjectxCondition max=JDS;
run;
data maxSubjectxCondition;
set maxSubjectxCondition;
if cmiss(of _all_) then delete;
run;

proc means data=maxSubjectxCondition n mean median max std var nway;
class condition;
var JDS;
output out=maxCondition mean=JDS;
run;

title Max JDS*condition;
proc sgplot data =maxcondition;
vbox JDS / category=condition;
yaxis max=8;
run;

title Max JDS*condition;
proc sgplot data =maxSubjectxcondition;
vbox JDS / category=condition;
yaxis max=8;
run;


DATA PairedDataSet1;
SET maxSubjectxcondition;
 if condition = 'post shift'; 
  rename JDS= shiftJDS;
RUN;

*Creates data set for post sleep data;
DATA PairedDataSet2;
SET maxSubjectxcondition;
 if condition = 'post sleep'; 
RUN;
*Merges two data sets;
Data PairedDataSet3;
merge PairedDataSet1 PairedDataSet2;
by subject_no;
run;

DATA pairedDataset4;
Set pairedDataset3;
dJDS=shiftJDS-JDS;
PROC UNIVARIATE data=pairedDataset4;
Var dJDS;
Run;


*By Segment;

proc means data=pnsd n mean median max std var nway;
class condition;
class subject_no;
class segment;
var JDS;
output out=SubjectxConditionxSegment max=JDS;
run;

data SubjectxConditionxSegment;
set SubjectxConditionxSegment;
if cmiss(of _all_) then delete;
run;

title MaxJDS*segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox JDS / category=segment;
yaxis max=7;
run;
title MaxJDS*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox JDS / category=segment;
yaxis max=7;
run;
