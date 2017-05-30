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
            DATAFILE= "D:\Dropbox\Dropbox\Work\ShiftWork\sas analysis\PNSDcoredatafil
e2012-12-30MLL.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
DATA PNSD;
  SET 'C:\Users\Lee\Documents\My SAS Files(32)\9.2\pnsd.sas7bdat';
RUN;



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
var JDS Mean_Neg_IED Mean_Neg_IED std_Dev_Neg_IED __Time_with_Eyes_Closed Mean_BTD Std_Dev_BTD Mean_Pos_AVR StdDev_Pos_AVR Mean_Neg_AVR Std_Dev_Neg_AVR __Long_Closures Mean_DOQ;
output out=SubjectxCondition mean=JDS Mean_Neg_IED Mean_Neg_IED std_Dev_Neg_IED __Time_with_Eyes_Closed Mean_BTD Std_Dev_BTD Mean_Pos_AVR StdDev_Pos_AVR Mean_Neg_AVR Std_Dev_Neg_AVR __Long_Closures Mean_DOQ;
run;
*Delete Post-Shift2 data;
data SubjectxCondition;
set SubjectxCondition;
if cmiss(of _all_) then delete;
run;

*By condition;
proc means data=subjectxcondition n mean median max std var nway;
class condition;
var JDS Mean_Neg_IED Mean_Neg_IED std_Dev_Neg_IED __Time_with_Eyes_Closed Mean_BTD Std_Dev_BTD Mean_Pos_AVR StdDev_Pos_AVR Mean_Neg_AVR Std_Dev_Neg_AVR __Long_Closures Mean_DOQ;
output out=Condition mean=JDS Mean_Neg_IED Mean_Neg_IED std_Dev_Neg_IED __Time_with_Eyes_Closed Mean_BTD Std_Dev_BTD Mean_Pos_AVR StdDev_Pos_AVR Mean_Neg_AVR Std_Dev_Neg_AVR __Long_Closures Mean_DOQ;
run;

*Analysis of Max JDS score;
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

*Analysis of mean Ocular measures;

proc means data=subjectxcondition n mean median max std var nway;
class condition;
var JDS Mean_Neg_IED Mean_Neg_IED std_Dev_Neg_IED __Time_with_Eyes_Closed Mean_BTD Std_Dev_BTD Mean_Pos_AVR StdDev_Pos_AVR Mean_Neg_AVR Std_Dev_Neg_AVR __Long_Closures Mean_DOQ;
output out=Condition mean=JDS Mean_Neg_IED Mean_Neg_IED std_Dev_Neg_IED __Time_with_Eyes_Closed Mean_BTD Std_Dev_BTD Mean_Pos_AVR StdDev_Pos_AVR Mean_Neg_AVR Std_Dev_Neg_AVR __Long_Closures Mean_DOQ;
run;

* DATA EXCLUSION
Replaces Optalert variables that are to be excluded due to visual inspection or design with '.' ;
*Exclude JDS if exclude = 1 (Combination of JDS, Visual, Raw_data or design;
*Exclude other variables by visual or raw_data;

data PNSD;
modify PNSD;
if EXCLUDE=1 then 
do;
JDS =.;
end;
if visual =1 or raw_data=1 then
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
Mean_DOQ_=.;
Std_Dev_DOQ=.;
end;
run;


* Calculates means for optalert variables;
* Grouped by subject and condition;
* Outputs data into a new dataset, "SubjectxCondition";
* Only displays highest TYPE observations;

proc means data=pnsd n mean median std var nway;
class condition;
class subject_no;
output out=SubjectxCondition mean=JDS Mean_Neg_IED Std_Dev_Neg_IED __Time_with_Eyes_Closed Mean_BTD Std_Dev_BTD Mean_Pos_AVR StdDev_Pos_AVR Mean_Neg_AVR Std_Dev_Neg_AVR __Long_Closures Mean_DOQ_ Std_Dev_DOQ;
var JDS Mean_Neg_IED Std_Dev_Neg_IED __Time_with_Eyes_Closed Mean_BTD Std_Dev_BTD Mean_Pos_AVR StdDev_Pos_AVR Mean_Neg_AVR Std_Dev_Neg_AVR __Long_Closures Mean_DOQ_ Std_Dev_DOQ;
run;



* Calculates means for optalert variables;
* Grouped by subject, condition and segment;
* Outputs data into a new dataset, "SubjectxConditionxSegment";
* Only displays highest TYPE observations;
proc means data=pnsd n mean median std var nway;
class condition;
class subject_no;
class segment;
output out=SubjectxConditionxSegment mean=JDS Mean_Neg_IED Std_Dev_Neg_IED __Time_with_Eyes_Closed Mean_BTD Std_Dev_BTD Mean_Pos_AVR StdDev_Pos_AVR Mean_Neg_AVR Std_Dev_Neg_AVR __Long_Closures Mean_DOQ Std_Dev_DOQ;
var JDS Mean_Neg_IED Std_Dev_Neg_IED __Time_with_Eyes_Closed Mean_BTD Std_Dev_BTD Mean_Pos_AVR StdDev_Pos_AVR Mean_Neg_AVR Std_Dev_Neg_AVR __Long_Closures Mean_DOQ Std_Dev_DOQ;
run;



*Plots Optalert value by Condition : Boxplots;
title JDS*condition;
proc sgplot data =Subjectxcondition;
vbox JDS / category=condition;
yaxis max=6;
run;

title IED*condition;
proc sgplot data =Subjectxcondition;
vbox Mean_Neg_IED / category=condition;
yaxis max=.25;
run;

title Std_Dev_IED*condition;
proc sgplot;
vbox Std_Dev_Neg_IED / category=condition;
yaxis max=.4;
run;
title Pos_AVR*condition;
proc sgplot;
vbox Mean_Pos_AVR/ category=condition;
yaxis max=3.5;
run;

title StdDev_PosAVR*condition;
proc sgplot;
vbox StdDev_Pos_AVR/ category=condition;
yaxis max=3.0;
run;

title Neg_AVR*condition;
proc sgplot;
vbox Mean_Neg_AVR/ category=condition;
yaxis max=3.5;
run;

title Std_Dev_NegAVR*condition;
proc sgplot;
vbox Std_Dev_Neg_AVR/ category=condition;
yaxis max=1.5;
run;

title LongClosures*condition;
proc sgplot;
vbox __Long_Closures/ category=condition;
yaxis max=4;
run;

title DOQ*condition;
proc sgplot;
vbox Mean_DOQ_/ category=condition;
yaxis max=1;
run;

title Std_Dev_DOQ*condition;
proc sgplot;
vbox Std_Dev_DOQ/ category=condition;
yaxis max=1;
run;

title BTD*condition;
proc sgplot;
vbox Mean_BTD / category=condition;
yaxis max=1;
run;


*Code for paired t-test;
*For Optalert Variables;
*Creates data set for post shift data
Adds "shift" prefix to all optalert variables;
DATA PairedDataSet1;
SET Subjectxcondition;
 if condition = 'post shift'; 
  rename JDS= shiftJDS Mean_Neg_IED=shiftMean_Neg_IED Std_Dev_Neg_IED=shiftStd_Dev_Neg_IED __Time_with_Eyes_Closed=shift__Time_with_Eyes_Closed Mean_BTD=shiftMean_BTD Std_Dev_BTD=shiftStd_Dev_BTD Mean_Pos_AVR=shiftMean_Pos_AVR StdDev_Pos_AVR=shiftStdDev_Pos_AVR Mean_Neg_AVR=shiftMean_Neg_AVR Std_Dev_Neg_AVR=shiftStd_Dev_Neg_AVR __Long_Closures=shift__Long_Closures Mean_DOQ_=shiftMean_DOQ_ Std_Dev_DOQ=shiftStd_Dev_DOQ;
RUN;

*Creates data set for post sleep data;
DATA PairedDataSet2;
SET Subjectxcondition;
 if condition = 'post sleep'; 
RUN;
*Merges two data sets;
Data PairedDataSet3;
merge PairedDataSet1 PairedDataSet2;
by subject_no;
run;
*Delete subject 11019 data because no Post-Shift data;
data PairedDataSet4;
set PairedDataSet3;
if cmiss(of _all_) then delete;
run;

DATA pairedDataset5;
Set pairedDataset4;
dJDS=shiftJDS-JDS;
dMeannegIED=Mean_Neg_IED-shiftMean_Neg_IED;
dStd_Dev_Neg_IED=Std_Dev_Neg_IED- shiftStd_Dev_Neg_IED ;
d__Time_with_Eyes_Closed=__Time_with_Eyes_Closed- shift__Time_with_Eyes_Closed;
dMean_BTD=Mean_BTD- shiftMean_BTD ;
dStd_Dev_BTD=Std_Dev_BTD- shiftStd_Dev_BTD;
dMean_Pos_AVR=Mean_Pos_AVR- shiftMean_Pos_AVR ;
dStdDev_Pos_AVR=StdDev_Pos_AVR- shiftStdDev_Pos_AVR ;
dMean_Neg_AVR=Mean_Neg_AVR- shiftMean_Neg_AVR;
dStd_Dev_Neg_AVR=Std_Dev_Neg_AVR- shiftStd_Dev_Neg_AVR;
d__Long_Closures=__Long_Closures- shift__Long_Closures;
dStd_Dev_DOQ=Std_Dev_DOQ- shiftStd_Dev_DOQ;
PROC UNIVARIATE data=pairedDataset5 normal;
Var dJDS dMeannegIED dStd_Dev_Neg_IED d__Time_with_Eyes_Closed dMean_BTD dStd_Dev_BTD dMean_Pos_AVR dStdDev_Pos_AVR dMean_Neg_AVR dStd_Dev_Neg_AVR d__Long_Closures dMean_DOQ dStd_Dev_DOQ;
Run;
