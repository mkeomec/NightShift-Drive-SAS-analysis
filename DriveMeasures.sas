run;
*Work computer;
PROC IMPORT OUT= SASUSER.PNSD
            DATAFILE= "C:\Documents and Settings\mll66\My Documents\Dropbox\Work\ShiftWork\SAS analysis\PNSDcoredatafile2012-12-30MLL.csv"  
          DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

DATA PNSD;
  SET 'C:\Documents and Settings\mll66\My Documents\My SAS Files\9.2\pnsd.sas7bdat';
RUN;


*Home Computer;
PROC IMPORT OUT= SASUSER.PNSD
            DATAFILE= "D:\Dropbox\Dropbox\Work\ShiftWork\PNSDcoredatafile2012-12-30MLL.csv"  
          DBMS=CSV REPLACE; 
     GETNAMES=YES;
     DATAROW=2; 
RUN;

DATA PNSD;
  SET 'C:\Users\Lee\Documents\My SAS Files(32)\9.2\pnsd.sas7bdat';
RUN;

*Excludes data in between surveys;
*Excludes row labelled Segment 8;
*Excludes data for LOCF data;
data PNSD1;
set PNSD;
if Exclusion__Design=1 then
delete;
if Segment=8 then
delete;
if 	mins_from_optalert_start_time=0 then
delete;
run;

*THIS ANALYSIS APPLIES TO Drive performance data!!!;

*Plots histogram of variable counts;

proc univariate data= pnsd1;
class condition;
var lineeventsrate;
histogram lineeventsrate / endpoints = 0 to 20 by 1;
title 'Histogram of Line Events Rate';
run;





*Generates averaged measures by subject and condition;

proc means data=pnsd1 n mean median std var nway;
class condition;
class subject_no;
output out=SubjectxCondition mean= SDLanePosSecAll SDSteerPosSecAll SDSteerPosAll MeanSteerErrorSecAll MeanSteerErrorAll SDSpeed LineEventsRate BrakeEventsRate LineEventsStrRate BrakeEventsStrRate;
var SDLanePosSecAll SDSteerPosSecAll SDSteerPosAll MeanSteerErrorSecAll MeanSteerErrorAll SDSpeed LineEventsRate BrakeEventsRate LineEventsStrRate BrakeEventsStrRate;
run;
*Generates averaged measures by condition;
proc means data=subjectxcondition n mean median std var nway ;
class condition;
output out=meanSubjectxCondition mean= _freq_ SDLanePosSecAll SDSteerPosSecAll SDSteerPosAll MeanSteerErrorSecAll MeanSteerErrorAll SDSpeed LineEventsRate BrakeEventsRate LineEventsStrRate BrakeEventsStrRate;
var _freq_ SDLanePosSecAll SDSteerPosSecAll SDSteerPosAll MeanSteerErrorSecAll MeanSteerErrorAll SDSpeed LineEventsRate BrakeEventsRate LineEventsStrRate BrakeEventsStrRate;
run;

*T-test by condition;
proc ttest data=subjectxcondition;
class condition;
var LineEventsstrRate;
run;
*For non-parametric comparison, data needs to rearranged;
*Rearranges data for paired comparison;
DATA subjectxcondition1;
SET subjectxcondition;
 if condition = 'post shift'; 
  rename SDLanePosSecAll=shiftSDLanePosSecAll SDSteerPosSecAll=shiftSDSteerPosSecAll SDSteerPosAll=shiftSDSteerPosAll MeanSteerErrorSecAll=shiftMeanSteerErrorSecAll MeanSteerErrorAll=shiftMeanSteerErrorAll SDSpeed=shiftSDSpeed LineEventsRate=shiftLineEventsRate BrakeEventsRate=shiftBrakeEventsRate LineEventsStrRate=shiftLineEventsStrRate BrakeEventsStrRate=shiftBrakeEventsStrRate;
RUN;
DATA subjectxcondition2;
SET Subjectxcondition;
 if condition = 'post sleep'; 
  RUN;
Data Paired;
merge subjectxcondition1 subjectxcondition2;
by subject_no;
run;

Data Paired2;
set Paired;
dSDLanePosSecAll= SDLanePosSecAll-shiftSDLanePosSecAll;
dSDSteerPosSecAll=SDSteerPosSecAll-shiftSDSteerPosSecAll ;
dSDSteerPosAll=SDSteerPosAll-shiftSDSteerPosAll	;
dMeanSteerErrorSecAll=MeanSteerErrorSecAll-shiftMeanSteerErrorSecAll ;
dMeanSteerErrorAll=MeanSteerErrorAll-shiftMeanSteerErrorAll ;
dSDSpeed=SDSpeed-shiftSDSpeed ;
dLineEventsRate=LineEventsRate-shiftLineEventsRate;
dBrakeEventsRate=BrakeEventsRate-shiftBrakeEventsRate;
dLineEventsStrRate=LineEventsStrRate-shiftLineEventsStrRate;
dBrakeEventsStrRate=BrakeEventsStrRate-shiftBrakeEventsStrRate;
run;

*Paired t-test and other non-parametric tests;
PROC UNIVARIATE data=Paired2;
Var dSDLanePosSecAll dSDSteerPosSecAll dSDSteerPosAll dMeanSteerErrorSecAll dMeanSteerErrorAll dSDSpeed dLineEventsRate dBrakeEventsRate dLineEventsStrRate dBrakeEventsStrRate;
Run;

*Calculates frequency of Driving events by condition;
proc freq data=PNSD1;
tables SDLanePosSecAll SDSteerPosSecAll SDSteerPosAll MeanSteerErrorSecAll MeanSteerErrorAll SDSpeed LineEventsRate BrakeEventsRate LineEventsStrRate BrakeEventsStrRate;
Run;


*calculates means of individual subjects by condition and segment; 
proc means data=pnsd1 n mean median std var nway;
class condition;
class subject_no;
class segment;
output out=SubjectxConditionxSegment mean= SDLanePosSecAll SDSteerPosSecAll SDSteerPosAll MeanSteerErrorSecAll MeanSteerErrorAll SDSpeed LineEventsRate BrakeEventsRate LineEventsStrRate BrakeEventsStrRate ;
var SDLanePosSecAll SDSteerPosSecAll SDSteerPosAll MeanSteerErrorSecAll MeanSteerErrorAll SDSpeed LineEventsRate BrakeEventsRate LineEventsStrRate BrakeEventsStrRate;
run;


*Plots measures by segment and condition; 
title SDLanePosSecAll*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox SDLanePosSecAll / category=segment;
yaxis max=1750 min=400;
run;

title SDLanePosSecAll*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox SDLanePosSecAll / category=segment;
yaxis max=1750 min=400;
run;


title SDSteerPosSecAll*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox SDSteerPosSecAll / category=segment;
yaxis max=12 min=3;
run;

title SDSteerPosSecAll*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox SDSteerPosSecAll / category=segment;
yaxis max=12 min=3;
run;

title SDSteerPosAll*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox SDSteerPosAll / category=segment;
yaxis max=80 min=60;
run;

title SDSteerPosAll*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox SDSteerPosAll / category=segment;
yaxis max=80 min=60;
run;

title MeanSteerErrorSecAll*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox MeanSteerErrorSecAll / category=segment;
yaxis max=5 min=1;
run;

title MeanSteerErrorSecAll*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox MeanSteerErrorSecAll / category=segment;
yaxis max=5 min=1;
run;

title MeanSteerErrorAll*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox  MeanSteerErrorAll / category=segment;
yaxis max=6 min=1;
run;

title MeanSteerErrorAll*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox  MeanSteerErrorAll / category=segment;
yaxis max=6 min=1;
run;

title SDSpeed*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox  SDSpeed / category=segment;
yaxis max=10 min=2;
run;

title SDSpeed*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox  SDSpeed / category=segment;
yaxis max=10 min=2;
run;

title LineEventsRate*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox  LineEventsRate / category=segment;
yaxis max=15 min=0;
run;

title LineEventsRate*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox  LineEventsRate / category=segment;
yaxis max=15 min=0;
run;

title brakeEventsRate*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox  brakeEventsRate / category=segment;
yaxis max=.2 min=0;
run;

title brakeEventsRate*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox  brakeEventsRate / category=segment;
yaxis max=.2 min=0;
run;

title LineEventsStrRate*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox  LineEventsStrRate / category=segment;
yaxis max=5 min=0;
run;

title LineEventsStrRate*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox  LineEventsStrRate / category=segment;
yaxis max=5 min=0;
run;

title brakeEventsStrRate*Segment_Post_Shift;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post shift"));
vbox  brakeEventsStrRate / category=segment;
yaxis max=5 min=0;
run;

title BrakeEventsStrRate*Segment_Post_Sleep;
proc sgplot data =Subjectxconditionxsegment (where=(condition="post sleep"));
vbox  BrakeEventsStrRate / category=segment;
yaxis max=80 min=60;
run;


*Rate Ratios;
*Condition 1=post shift, 2=post sleep;
data insure;
      input mins lineevents strlineevents condition;
      ln = log(mins);
      datalines;
      1449  4482 853 1
      1516  2252 287 2
      run;
proc genmod data=insure;
      class condition;
      model lineevents=condition / d=p offset=ln;
      estimate 'ratio' condition 1 -1;
      output out=genout xbeta=xb stdxbeta=std;
      run;
data predrates;
      set genout;
      obsrate=lineevents/mins;    /* observed rate */
      lograte=xb-ln;
      prate=exp(lograte);
      lcl=exp(lograte-probit(.975)*std);
      ucl=exp(lograte+probit(.975)*std);
      run;

   proc print data=predrates noobs;
      run;

 proc nlmixed data=insure;
      condition1=0;
      if condition=1 then condition1=1;
      l=exp(b0+b1*condition1+ln);
      model lineevents ~ poisson(l);
      estimate "Rate Difference" exp(b0+b1)-exp(b0);
      run;

proc genmod data=insure;
      class condition;
      model strlineevents=condition / d=p offset=ln;
      estimate 'ratio' condition 1 -1;
      output out=genout xbeta=xb stdxbeta=std;
      run;
data predrates;
      set genout;
      obsrate=strlineevents/mins;    /* observed rate */
      lograte=xb-ln;
      prate=exp(lograte);
      lcl=exp(lograte-probit(.975)*std);
      ucl=exp(lograte+probit(.975)*std);
      run;


proc nlmixed data=insure;
      condition1=0;
      if condition=1 then condition1=1;
      l=exp(b0+b1*condition1+ln);
      model strlineevents ~ poisson(l);
      estimate "Rate Difference" exp(b0+b1)-exp(b0);
      run;
