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
box\Work\ShiftWork\PNSDcoredatafile2012-11-6MLL.csv"  
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
e2012-12-30MLL.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
DATA PNSD;
  SET 'C:\Users\Lee\Documents\My SAS Files(32)\9.2\pnsd.sas7bdat';
RUN;

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

*Excludes all measures of first drive segment;
data PNSD;
modify PNSD;
if EXCLUDE=1 then 
do;
JDS =.;
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
output out=SubjectxConditionxSegment mean=JDS Mean_Neg_IED Std_Dev_Neg_IED __Time_with_Eyes_Closed Mean_BTD Std_Dev_BTD Mean_Pos_AVR StdDev_Pos_AVR Mean_Neg_AVR Std_Dev_Neg_AVR __Long_Closures Mean_DOQ_ Std_Dev_DOQ;
var JDS Mean_Neg_IED Std_Dev_Neg_IED __Time_with_Eyes_Closed Mean_BTD Std_Dev_BTD Mean_Pos_AVR StdDev_Pos_AVR Mean_Neg_AVR Std_Dev_Neg_AVR __Long_Closures Mean_DOQ_ Std_Dev_DOQ;
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



*NEED TO DO PAIRED T TEST;

*This is a t-test for independent samples;
proc ttest data=subjectxcondition;
  class condition;
var jds Mean_Neg_IED Std_Dev_Neg_IED __Time_with_Eyes_Closed Mean_BTD Std_Dev_BTD Mean_Pos_AVR StdDev_Pos_AVR Mean_Neg_AVR Std_Dev_Neg_AVR __Long_Closures Mean_DOQ_ Std_Dev_DOQ;
run;

*Analysis of Optalert variable x condition x segment;
*Boxplots;
title JDS*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox JDS / category=segment;
yaxis max=6;
run;
title JDS*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox JDS / category=segment;
yaxis max=6;
run;

title IED*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox Mean_Neg_IED / category=segment;
yaxis max=.25;
run;
title IED*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox Mean_Neg_IED / category=segment;
yaxis max=.25;
run;

title PosAVR*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox Mean_Pos_AVR/ category=segment;
yaxis max=3.5;
run;
title PosAVR*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox Mean_Pos_AVR/ category=segment;
yaxis max=3.5;
run;

title StdDev_PosAVR*condition;
proc sgplot;
vbox StdDev_Pos_AVR/ category=condition;
yaxis max=3.0;
run;

title NEGAVR*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox Mean_Neg_AVR/ category=segment;
yaxis max=3.5;
run;
title NEGAVR*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox Mean_Neg_AVR/ category=segment;
yaxis max=3.5;
run;

title LongClosures*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox __Long_Closures/ category=segment;
yaxis max=4;
run;

title LongClosures*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox __Long_Closures/ category=segment;
yaxis max=4;
run;


title DOQ*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox Mean_DOQ_/ category=segment;
yaxis max=1;
run;
title DOQ*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox Mean_DOQ_/ category=segment;
yaxis max=1;
run;


title BTD*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox Mean_BTD / category=segment;
yaxis max=1;
run;

title BTD*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox Mean_BTD / category=segment;
yaxis max=1;
run;

*PSG ANALYSIS;

*Exclude LOCF segments;
data PNSD;
modify PNSD;
if mins_from_optalert_start_time=0 then;
delete;
run;

*Outputs number of observations and sum to new dataset;


title PSG values;
proc means data=pnsd n sum nway;
class condition;
class subject_no;
output out=PSGSubjectxCondition sum=Alpha theta SEM ;
var Alpha theta SEM;
run;

title PSG values;
proc means data=pnsd n sum nway;
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

*Rate Ratios;
*Condition 1=post shift, 2=post sleep;
data PSGRates;
      input mins theta sem condition;
      ln = log(mins);
      datalines;
      1449  24 486 1
      1516  12 269 2
      run;
*Rate Ratio stats for Theta;
proc genmod data=PSGRates;
      class condition;
      model theta=condition / d=p offset=ln;
      estimate 'ratio' condition 1 -1;
      output out=genout xbeta=xb stdxbeta=std;
      run;
*Rate Ratio stats for SEM;
proc genmod data=PSGRates;
      class condition;
      model SEM=condition / d=p offset=ln;
      estimate 'ratio' condition 1 -1;
      output out=genout xbeta=xb stdxbeta=std;
      run;


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

*input data for Chi-Square test;
*Alpha Chi square test;
DATA alphaCHI;
   INPUT condition $ alpha $ count ;
   DATALINES;
Shift yes 29 
Shift no 1865
Sleep yes 19
Sleep no 1742
;

PROC PRINT; RUN; 

proc freq data=alphaCHI order=data;
weight count;
tables condition*alpha/chisq;
run;

*Theta Chi Square Test;
DATA thetaCHI;
   INPUT condition $ theta $ count ;
   DATALINES;
Shift yes 24
Shift no 1870
Sleep yes 6
Sleep no 1755
;
PROC PRINT; RUN; 

proc freq data=thetaCHI order=data;
weight count;
tables condition*theta/chisq;
run;

*SEM Chi Square Test;
DATA SEMCHI;
   INPUT condition $ SEM $ count ;
   DATALINES;
Shift yes 527 
Shift no 1367
Sleep yes 253
Sleep no 1508
;
PROC PRINT; RUN; 

proc freq data=SEMCHI order=data;
weight count;
tables condition*SEM/chisq;
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

*Examine dataset, "subjectxcondition for normality;
proc univariate plot normal;
histogram;
var JDS shiftJDS Mean_Neg_IED shiftMean_Neg_IED Std_Dev_Neg_IED shiftStd_Dev_Neg_IED __Time_with_Eyes_Closed shift__Time_with_Eyes_Closed Mean_BTD shiftMean_BTD Std_Dev_BTD shiftStd_Dev_BTD Mean_Pos_AVR shiftMean_Pos_AVR StdDev_Pos_AVR shiftStdDev_Pos_AVR Mean_Neg_AVR shiftMean_Neg_AVR  Std_Dev_Neg_AVR shiftStd_Dev_Neg_AVR __Long_Closures shift__Long_Closures Mean_DOQ_ shiftMean_DOQ_ Std_Dev_DOQ shiftStd_Dev_DOQ;
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
dMean_DOQ=Mean_DOQ_- shiftMean_DOQ_;
dStd_Dev_DOQ=Std_Dev_DOQ- shiftStd_Dev_DOQ;
PROC UNIVARIATE data=pairedDataset5;
Var dJDS dMeannegIED dStd_Dev_Neg_IED d__Time_with_Eyes_Closed dMean_BTD dStd_Dev_BTD dMean_Pos_AVR dStdDev_Pos_AVR dMean_Neg_AVR dStd_Dev_Neg_AVR d__Long_Closures dMean_DOQ dStd_Dev_DOQ;
Run;





*The following runs paired t-test for all optalert variables by condition;
title Paired T-tests;
proc ttest;
      paired shiftJDS*JDS;
   run;
proc ttest;
      paired Mean_Neg_IED*shiftMean_Neg_IED;
   run;
proc ttest;
      paired Std_Dev_Neg_IED*shiftStd_Dev_Neg_IED;
   run;
proc ttest;
      paired  __Time_with_Eyes_Closed*shift__Time_with_Eyes_Closed;
   run;
proc ttest;
      paired Mean_BTD*shiftMean_BTD;
   run;
proc ttest;
      paired  Std_Dev_BTD*shiftStd_Dev_BTD;
run;
proc ttest;
      paired  Mean_Pos_AVR*shiftMean_Pos_AVR;
run;
proc ttest;
      paired  StdDev_Pos_AVR*shiftStdDev_Pos_AVR;
run;
proc ttest;
      paired  Mean_Neg_AVR*shiftMean_Neg_AVR;
run;
proc ttest;
      paired  Std_Dev_Neg_AVR*shiftStd_Dev_Neg_AVR;
run;
proc ttest;
      paired  __Long_Closures*shift__Long_Closures;
run;
proc ttest;
      paired  Mean_DOQ_*shiftMean_DOQ_;
run;
proc ttest;
      paired  Std_Dev_DOQ*shiftStd_Dev_DOQ;
run;
   

***Added 8-16-2012;
*Creates dataset for PSG values by condition and segment;
proc means data=pnsd n sum nway;
class condition;
class subject_no;
output out=PSGSubjectxCondition sum=Alpha theta SEM ;
var Alpha theta SEM;
run;

title SEM;
proc sgplot data =PSGSubjectxCondition;
vbox SEM/ category=condition;
run;
title Theta;
proc sgplot data =PSGSubjectxCondition;
vbox theta/ category=condition;
run;title alpha;
proc sgplot data =PSGSubjectxCondition;
vbox alpha/ category=condition;
run;



*Creates dataset for PSG values by condition and segment;
proc means data=pnsd n sum nway;
class condition;
class subject_no;
class segment;
output out=PSGSubjectxConditionxSegment sum=Alpha theta SEM ;
var Alpha theta SEM;
run;

*Boxplots of sleep and shift for PSG variables;
title SEM post sleep;
proc sgplot data =PSGSubjectxConditionxSegment (where=(condition="post sleep"));
vbox SEM / category=segment;

run;
title SEM post shift;
proc sgplot data =PSGSubjectxConditionxSegment (where=(condition="post shift"));
vbox SEM / category=segment;
run;
title theta post sleep;
proc sgplot data =PSGSubjectxConditionxSegment (where=(condition="post sleep"));
vbox theta / category=segment;

run;
title theta post shift;
proc sgplot data =PSGSubjectxConditionxSegment (where=(condition="post shift"));
vbox theta / category=segment;
run;
title alpha post sleep;
proc sgplot data =PSGSubjectxConditionxSegment (where=(condition="post sleep"));
vbox alpha / category=segment;

run;
title alpha post shift;
proc sgplot data =PSGSubjectxConditionxSegment (where=(condition="post shift"));
vbox alpha / category=segment;
run;


**Within segment block analysis;


*Not needed?;
proc sort data=PNSD out=PNSD2;
by subject_no condition segment descending segment_window;
run;
*Creates Data set with first 3 minutes of included data (First 3 minutes were excluded by design);
*proc means data='C:\Documents and Settings\mll66\My Documents\My SAS Files\9.2\pnsd1.sas7bdat' n mean median std var nway;
proc means data=pnsd n mean median std var nway;
class condition;
class subject_no;
class segment;

where segment_window<7 and segment_window>3;
output out=FirstSegmentWin mean=JDS Mean_Neg_IED;
var JDS Mean_Neg_IED;
run;

*Create managable dataset with JDS to extract last 3 observations from each segment;
proc means data=pnsd n mean median std var nway;
class condition;
class subject_no;
class segment;
class segment_window;
output out=EndSegment mean=JDS Mean_Neg_IED;
var JDS Mean_Neg_IED;
run;

proc sort data=endsegment out=endsegment_sort;
by subject_no condition segment descending segment_window;
run;

data endsegmentwin;
  set endsegment_sort;
  by subject_no condition segment ; 
   if first.segment=1 then do;
    count=0;
   end;
	if first.segment=0 then do;
	count++1;
	end;
run;

*Create Dataset with Last 3 observations;
proc means data=endsegmentwin n mean median std var nway;
class condition;
class subject_no;
class segment;
where count<3;
output out=endSegmentWin1 mean=JDS Mean_Neg_IED;
var JDS Mean_Neg_IED;
run;

DATA Lastsegment;
SET endSegmentWin1;
  rename JDS= endJDS Mean_Neg_IED=endMean_Neg_IED;
RUN;

*Merges two data sets;
Data PairedSegment;
merge firstsegmentwin Lastsegment;
run;

*Calculate difference between end JDS, IED and begining segment;

data PairedSegment1;
set PairedSegment;
DiffJDS =endjds-jds;
DiffIED =endMean_Neg_IED-Mean_Neg_IED;
run;


proc expand data=pairedsegment method = none; 
  convert endJDS = endJDS_lag1   / transformout=(lag 1); 
  convert  endMean_Neg_IED = endMean_Neg_IED_lag1   / transformout=(lag 1) ;
run;
data BtwnJDSdata;
set data1;
BtwnJDS=JDS-endJDS_lag1;
run;
data BtwnIEDdata;
set data1;
BtwnIED=Mean_neg_IED-endMean_Neg_IED_lag1;
run;
*Examine only if endJDS>2;
data pairedseg2;
set pairedsegment1;
if endJDS<2 then delete;
run;

data btwnieddata2;
set btwnieddata;
if endjds<2 then delete;
run;
data btwnJDSdata2;
set btwnJDSdata;
if endjds<2 then delete;
run;

*Test for different than zero;
proc univariate data=btwnieddata;
var btwnied;
by condition;
run;

proc univariate data=btwnJDSdata;
var btwnJDS;
by condition;
run;
title withinsegment;
proc univariate data=pairedsegment1;
var diffJDS diffied;
by condition;
run;
title IED btwnsegment;
proc univariate data=btwnieddata2;
var btwnied;
by condition;
run;
title JDS btwnsegment;
proc univariate data=btwnJDSdata2;
var btwnJDS;
by condition;
run;



*Plot JDS Segment results;

Title Post Shift Begining of segment;
proc sgplot data =PairedSegment1 (where=(condition="post shift"));
vbox JDS / category=segment;
yaxis max=6;
run;

Title Post Sleep Begining of segment;
proc sgplot data =PairedSegment1 (where=(condition="post sleep"));
vbox JDS / category=segment;
yaxis max=6;
run;

Title Post Shift End segment;
proc sgplot data =PairedSegment1 (where=(condition="post shift"));
vbox endJDS / category=segment;
yaxis max=6;
run;

Title Post Sleep End segment;
proc sgplot data =PairedSegment1 (where=(condition="post sleep"));
vbox endJDS / category=segment;
yaxis max=6;
run;

Title Post Shift Change within segment;
proc sgplot data =PairedSegment1 (where=(condition="post shift"));
vbox diffJDS / category=segment;
yaxis max=4 min=-2;
run;

Title Post Sleep Change within segment;
proc sgplot data =PairedSegment1 (where=(condition="post sleep"));
vbox diffJDS / category=segment;
yaxis max=4 min=-2;

run;

Title Post Shift Change within Segment;
proc sgplot data =PairedSegment1 (where=(condition="post shift" ));
vbox diffJDS / category=condition;
yaxis max=4 min=-2;
run;
Title Post Sleep Change within segment;
proc sgplot data =PairedSegment1 (where=(condition="post sleep" ));
vbox diffJDS / category=condition;
yaxis max=4 min=-2;
run;

Title Post Shift Change within Segment if end JDS>2;
proc sgplot data =pairedseg2 (where=(condition="post shift"));
vbox diffJDS / category=condition;
yaxis max=4 min=-2;
run;
Title Post Sleep Change within segment if end JDS>2;
proc sgplot data =pairedseg2 (where=(condition="post sleep"));
vbox diffJDS / category=condition;
yaxis max=4 min=-2;
run;



Title Post Shift Between segment;
proc sgplot data =btwnJDSdata (where=(condition="post shift"));
vbox BtwnJDS / category=segment;
yaxis max=2 min=-2;
run;
Title Post Sleep Between segment;
proc sgplot data =btwnJDSdata (where=(condition="post sleep"));
vbox BtwnJDS / category=segment;
yaxis max=2 min=-2;
run;

Title Post Shift Between segment JDS>2;
proc sgplot data =btwnJDSdata2 (where=(condition="post shift" ));
vbox BtwnJDS / category=condition;
yaxis max=2 min=-4;
run;
Title Post Sleep Between segment JDS>2;
proc sgplot data =btwnJDSdata2 (where=(condition="post sleep"));
vbox BtwnJDS / category=condition;
yaxis max=2 min=-4;
run;

Title Post Shift Between segment endJDS>2;
proc sgplot data =btwnJDSdata2 (where=(condition="post shift"));
vbox BtwnJDS / category=segment;
yaxis max=2 min=-4;
run;
Title Post Sleep Between segment;
proc sgplot data =btwnJDSdata2 (where=(condition="post sleep"));
vbox BtwnJDS / category=segment;
yaxis max=2 min=-4;
run;

*PLOT IED GRAPHS;

Title IED: Post Shift Begining of segment;
proc sgplot data =PairedSegment1 (where=(condition="post shift"));
vbox mean_neg_ied / category=segment;
yaxis max=.25;
run;

Title IED: Post Sleep Begining of segment;
proc sgplot data =PairedSegment1 (where=(condition="post sleep"));
vbox mean_neg_ied / category=segment;
yaxis max=.25;
run;

Title IED: Post Shift End segment;
proc sgplot data =PairedSegment1 (where=(condition="post shift"));
vbox endmean_neg_ied / category=segment;
yaxis max=.25;
run;

Title IED: Post Sleep End segment;
proc sgplot data =PairedSegment1 (where=(condition="post sleep"));
vbox mean_neg_ied / category=segment;
yaxis max=.25;
run;

Title IED: Post Shift Change within segment;
proc sgplot data =PairedSegment1 (where=(condition="post shift"));
vbox diffied / category=segment;
yaxis max=.2 min=-.1;
run;

Title IED: Post Sleep Change within segment;
proc sgplot data =PairedSegment1 (where=(condition="post sleep"));
vbox diffied / category=segment;
yaxis max=.2 min=-.1;

run;

Title IED: Post Shift Change within Segment;
proc sgplot data =PairedSegment1 (where=(condition="post shift" ));
vbox diffIED / category=condition;
yaxis max=.2 min=-.1;
run;
Title IED: Post Sleep Change within segment;
proc sgplot data =PairedSegment1 (where=(condition="post sleep" ));
vbox diffIED / category=condition;
yaxis max=.2 min=-.1;
run;

Title IED: Post Shift Change within Segment if end JDS>2;
proc sgplot data =PairedSeg2 (where=(condition="post shift"));
vbox diffIED / category=condition;
yaxis max=.2 min=-.15;
run;
Title IED: Post Sleep Change within segment if end JDS>2;
proc sgplot data =PairedSeg2 (where=(condition="post sleep"));
vbox diffIED / category=condition;
yaxis max=.2 min=-.15;
run;



Title IED: Post Shift Between segment;
proc sgplot data =btwnIEDdata (where=(condition="post shift"));
vbox BtwnIED / category=segment;
yaxis max=.1 min=-.1;
run;
Title IED: Post Sleep Between segment;
proc sgplot data =btwnIEDdata (where=(condition="post sleep"));
vbox BtwnIED / category=segment;
yaxis max=.1 min=-.1;
run;

Title Post Shift Between segment;
proc sgplot data =btwnIEDdata (where=(condition="post shift"));
vbox BtwnIED / category=condition;
yaxis max=.1 min=-.1;
run;
Title Post Sleep Between segment;
proc sgplot data =btwnIEDdata (where=(condition="post sleep"));
vbox BtwnIED / category=condition;
yaxis max=.1 min=-.1;
run;

Title Post Shift Between segment endJDS>2;
proc sgplot data =btwnIEDdata2 (where=(condition="post shift"));
vbox BtwnIED / category=segment;
yaxis max=.1 min=-.4;
run;
Title Post Sleep Between segment endJDS>2;
proc sgplot data =btwnIEDdata2 (where=(condition="post sleep" ));
vbox BtwnIED / category=segment;
yaxis max=.1 min=-.4;
run;


* DRIVE EVENT RELATED ANALYSIS;
*Chi Square analysis;
proc sort data=PNSD out=PNSD2;
by condition;
run;
proc freq data=pnsd2;
by condition;
  tables segment;
  run; 
* By Minutes;
  DATA EventCHI;
   INPUT condition $ Event $ count ;
   DATALINES;
Shift yes 17 
Shift no 1584
Sleep yes 0
Sleep no 1530
;
proc freq data=eventCHI order=data;
weight count;
tables condition*Event/chisq;
run;
* By Subject;
  DATA SubjectCHI;
   INPUT condition $ Event $ count ;
   DATALINES;
Shift yes 7 
Shift no 9
Sleep yes 0
Sleep no 16
;
proc freq data=subjectCHI order=data;
weight count;
tables condition*Event/chisq;
run;

proc freq data=subjectxconditionxsegment order=data;
weight jds;
tables condition*jds/chisq;
run;
*****;
data event;
set pnsd;
keep subject_no condition segment mean_neg_ied jds drive_event Drive_Event_Reassign;
run;
*Delete first Observation (1st obs is to establish char or number from excel import);
proc iml;
edit event;
delete point 1;           
purge;                      
close event;
run;

data eventlevel;
set event;
if cmiss(of drive_event_reassign) then delete;
run;

proc means data=eventlevel;
output out=eventlevel2 mean= mean_neg_ied jds;
var mean_neg_ied JDS;
run;





*Create new column: event (drive event yes = 1 no =0)
Create new column:IED (IED >.12 = 1, else 0);
data IEDevent;
set event;
*if cmiss(of mean_neg_ied) then delete;
if cmiss(of segment) then delete;
if Mean_neg_ied ^= . and drive_event_reassign ^>0 then
do;
event=0;
end;
if drive_event_reassign >0 then
do;
event=1;
end;
if mean_neg_ied >.120 then
do;
IED=1;
end;
else
do;
IED=0;
end;
run;
data iedevent1;
set pnsd;
if cmiss(of drive_event) then delete;
run;


*Average IED and JDS within segment;
proc means data= event1 n mean median std var nway;
class subject_no;
class condition;
class segment;
output out=event2 mean=mean_neg_ied JDS;
var mean_neg_ied JDS;
run;

proc summary print mean n;
var IED Event;
run;

proc freq;
tables ied*event;
run;

DATA EventCHI;
   INPUT condition $ IED $ Event ;
   DATALINES;
IED>0.12 yes 8 
IED>0.12 no 498
IED<0.12 yes 1
IED<0.12 no 1488
;
proc freq data=eventCHI order=data;
weight event;
tables condition*ied/chisq;
run;






*Reassign Drive event values to closest Optalert value;

data event2;
set event1;
if cmiss(of drive_event) then delete;
run;


proc sort data=PNSD out=PNSD3;
by subject_no condition segment segment_window DRIVE_EVENT;
run;

data endsegmentwin;
  set endsegment_sort;
  by subject_no condition segment ; 
   if first.segment=1 then do;
    count=0;
   end;
	if first.segment=0 then do;
	count++1;
	end;
run;











*Questionnaire Analysis;
*NEEDS WORK!!!!;
*By Condition;
proc means data=Pnsd n mean median std var nway;
class condition;
class subject_no;
output out=QxCondition mean=sleepiness fallasleep Struggling_to_keep_your_eyes_ope Vision_becoming_blurred Nodding_off_to_sleep Difficulty_keeping_to_the_middle Difficulty_maintaining_the_corre Mind_wandering_to_other_things Reactions_were_slow Head_dropping_down;
var sleepiness fallasleep Struggling_to_keep_your_eyes_ope Vision_becoming_blurred Nodding_off_to_sleep Difficulty_keeping_to_the_middle Difficulty_maintaining_the_corre Mind_wandering_to_other_things Reactions_were_slow Head_dropping_down;
run;

title Sleepiness*Condition_Post_Sleep;
proc sgplot data =QxCondition (where=(condition="post sleep"));
vbox sleepiness / category=Condition;
yaxis max=10;
run;
title Sleepiness*Condition_Post_Shift;
proc sgplot data =QxCondition (where=(condition="post shift"));
vbox sleepiness / category=Condition;
yaxis max=10;
run;
title Struggling to keep your eyes open-Post Sleep;
proc sgplot data =QxCondition (where=(condition="post sleep"));
vbox Struggling_to_keep_your_eyes_ope / category=Condition;
yaxis max=10;
run;
title Struggling to keep your eyes open-Post Shift;
proc sgplot data =QxCondition (where=(condition="post shift"));
vbox Struggling_to_keep_your_eyes_ope / category=Condition;
yaxis max=10;
run;
title Vision_becoming_blurred-Post Sleep;
proc sgplot data =QxCondition (where=(condition="post sleep"));
vbox Vision_becoming_blurred / category=Condition;
yaxis max=10;
run;
title Vision_becoming_blurred-Post Shift;
proc sgplot data =QxCondition (where=(condition="post shift"));
vbox Vision_becoming_blurred / category=Condition;
yaxis max=10;
run;

title Nodding_off_to_sleep-Post Sleep;
proc sgplot data =QxCondition (where=(condition="post sleep"));
vbox Nodding_off_to_sleep / category=Condition;
yaxis max=10;
run;
title Nodding_off_to_sleep-Post Shift;
proc sgplot data =QxCondition (where=(condition="post shift"));
vbox Nodding_off_to_sleep / category=Condition;
yaxis max=10;
run;

title Difficulty_keeping_to_the_middle-Post Sleep;
proc sgplot data =QxCondition (where=(condition="post sleep"));
vbox Difficulty_keeping_to_the_middle/ category=Condition;
yaxis max=10;
run;
title Difficulty_keeping_to_the_middle-Post Shift;
proc sgplot data =QxCondition (where=(condition="post shift"));
vbox Difficulty_keeping_to_the_middle / category=Condition;
yaxis max=10;
run;

title Difficulty_maintaining_the_corre-Post Sleep;
proc sgplot data =QxCondition (where=(condition="post sleep"));
vbox Difficulty_maintaining_the_corre / category=Condition;
yaxis max=10;
run;
title Difficulty_maintaining_the_corre-Post Shift;
proc sgplot data =QxCondition (where=(condition="post shift"));
vbox Difficulty_maintaining_the_corre / category=Condition;
yaxis max=10;
run;

title Mind_wandering_to_other_things-Post Sleep;
proc sgplot data =QxCondition (where=(condition="post sleep"));
vbox Mind_wandering_to_other_things / category=Condition;
yaxis max=10;
run;
title Mind_wandering_to_other_things-Post Shift;
proc sgplot data =QxCondition (where=(condition="post shift"));
vbox Mind_wandering_to_other_things / category=Condition;
yaxis max=10;
run;

title Reactions_were_slow-Post Sleep;
proc sgplot data =QxCondition (where=(condition="post sleep"));
vbox Reactions_were_slow / category=Condition;
yaxis max=10;
run;
title Reactions_were_slow-Post Shift;
proc sgplot data =QxCondition (where=(condition="post shift"));
vbox Reactions_were_slow / category=Condition;
yaxis max=10;
run;

title Head_dropping_down-Post Sleep;
proc sgplot data =QxCondition (where=(condition="post sleep"));
vbox Head_dropping_down / category=Condition;
yaxis max=10;
run;
title Head_dropping_down-Post Shift;
proc sgplot data =QxCondition (where=(condition="post shift"));
vbox Head_dropping_down / category=Condition;
yaxis max=10;
run;

*By Segment;
proc means data=Pnsd n mean median std var nway;
class condition;
class subject_no;
class segment;
output out=QxConditionxSegment mean=sleepiness fallasleep Struggling_to_keep_your_eyes_ope Vision_becoming_blurred Nodding_off_to_sleep Difficulty_keeping_to_the_middle Difficulty_maintaining_the_corre Mind_wandering_to_other_things Reactions_were_slow Head_dropping_down;
var sleepiness fallasleep Struggling_to_keep_your_eyes_ope Vision_becoming_blurred Nodding_off_to_sleep Difficulty_keeping_to_the_middle Difficulty_maintaining_the_corre Mind_wandering_to_other_things Reactions_were_slow Head_dropping_down;
run;

title Sleepiness*Segment_Post_Sleep;
proc sgplot data =QxConditionxSegment (where=(condition="post sleep"));
vbox sleepiness / category=segment;
yaxis max=10;
run;
title Sleepiness*Segment_Post_Shift;
proc sgplot data =QxConditionxSegment (where=(condition="post shift"));
vbox sleepiness / category=segment;
yaxis max=10;
run;
title Struggling to keep your eyes open-Post Sleep;
proc sgplot data =QxConditionxSegment (where=(condition="post sleep"));
vbox Struggling_to_keep_your_eyes_ope / category=segment;
yaxis max=10;
run;
title Struggling to keep your eyes open-Post Shift;
proc sgplot data =QxConditionxSegment (where=(condition="post shift"));
vbox Struggling_to_keep_your_eyes_ope / category=segment;
yaxis max=10;
run;
title Vision_becoming_blurred-Post Sleep;
proc sgplot data =QxConditionxSegment (where=(condition="post sleep"));
vbox Vision_becoming_blurred / category=segment;
yaxis max=10;
run;
title Vision_becoming_blurred-Post Shift;
proc sgplot data =QxConditionxSegment (where=(condition="post shift"));
vbox Vision_becoming_blurred / category=segment;
yaxis max=10;
run;

title Nodding_off_to_sleep-Post Sleep;
proc sgplot data =QxConditionxSegment (where=(condition="post sleep"));
vbox Nodding_off_to_sleep / category=segment;
yaxis max=10;
run;
title Nodding_off_to_sleep-Post Shift;
proc sgplot data =QxConditionxSegment (where=(condition="post shift"));
vbox Nodding_off_to_sleep / category=segment;
yaxis max=10;
run;

title Difficulty_keeping_to_the_middle-Post Sleep;
proc sgplot data =QxConditionxSegment (where=(condition="post sleep"));
vbox Difficulty_keeping_to_the_middle/ category=segment;
yaxis max=10;
run;
title Difficulty_keeping_to_the_middle-Post Shift;
proc sgplot data =QxConditionxSegment (where=(condition="post shift"));
vbox Difficulty_keeping_to_the_middle / category=segment;
yaxis max=10;
run;

title Difficulty_maintaining_the_corre-Post Sleep;
proc sgplot data =QxConditionxSegment (where=(condition="post sleep"));
vbox Difficulty_maintaining_the_corre / category=segment;
yaxis max=10;
run;
title Difficulty_maintaining_the_corre-Post Shift;
proc sgplot data =QxConditionxSegment (where=(condition="post shift"));
vbox Difficulty_maintaining_the_corre / category=segment;
yaxis max=10;
run;

title Mind_wandering_to_other_things-Post Sleep;
proc sgplot data =QxConditionxSegment (where=(condition="post sleep"));
vbox Mind_wandering_to_other_things / category=segment;
yaxis max=10;
run;
title Mind_wandering_to_other_things-Post Shift;
proc sgplot data =QxConditionxSegment (where=(condition="post shift"));
vbox Mind_wandering_to_other_things / category=segment;
yaxis max=10;
run;

title Reactions_were_slow-Post Sleep;
proc sgplot data =QxConditionxSegment (where=(condition="post sleep"));
vbox Reactions_were_slow / category=segment;
yaxis max=10;
run;
title Reactions_were_slow-Post Shift;
proc sgplot data =QxConditionxSegment (where=(condition="post shift"));
vbox Reactions_were_slow / category=segment;
yaxis max=10;
run;

title Head_dropping_down-Post Sleep;
proc sgplot data =QxConditionxSegment (where=(condition="post sleep"));
vbox Head_dropping_down / category=segment;
yaxis max=10;
run;
title Head_dropping_down-Post Shift;
proc sgplot data =QxConditionxSegment (where=(condition="post shift"));
vbox Head_dropping_down / category=segment;
yaxis max=10;
run;

proc means data='C:\Documents and Settings\mll66\My Documents\My SAS Files\9.2\pnsd1.sas7bdat' n mean median std var nway;
class condition;
class subject_no;
output out=QuestionSubjectxCondition mean=The_following_is_a_9_point_scal0 What_is_the_likelihood_of_you_f0 ___Struggling_to_keep_your_eyes0 ___Vision_becoming_blurred1 ___Nodding_off_to_sleep1 ___Difficulty_keeping_to_the_mi0 ___Difficulty_maintaining_the_c0 ___Mind_wandering_to_other_thin0 ___Reactions_were_slow1 ___Head_dropping_down1;
var The_following_is_a_9_point_scal0 What_is_the_likelihood_of_you_f0 ___Struggling_to_keep_your_eyes0 ___Vision_becoming_blurred1 ___Nodding_off_to_sleep1 ___Difficulty_keeping_to_the_mi0 ___Difficulty_maintaining_the_c0 ___Mind_wandering_to_other_thin0 ___Reactions_were_slow1 ___Head_dropping_down1;
run;

*The_following_is_a_9_point_scal0;
The following is a 9 point scale to describe sleepiness# Put a 1;

proc means data='C:\Documents and Settings\mll66\My Documents\My SAS Files\9.2\pnsd1.sas7bdat' n mean median std var nway;
class condition;
class subject_no;
output out=QuestionSubjectxCondition mean=sleepiness ;
var sleepiness;
run;





