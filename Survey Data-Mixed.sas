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

data PNSD1;
set PNSD;
if Exclusion__Design=1 or condition="postshift2" then
delete;
if Segment=8 then
delete;
run;
proc means data=Pnsd1 n mean median std var nway;
class condition;
class subject_no;
class segment;
output out=QxCondition mean=sleepiness fallasleep Struggling_to_keep_your_eyes_ope Vision_becoming_blurred Nodding_off_to_sleep Difficulty_keeping_to_the_middle Difficulty_maintaining_the_corre Mind_wandering_to_other_things Reactions_were_slow Head_dropping_down;
var sleepiness fallasleep Struggling_to_keep_your_eyes_ope Vision_becoming_blurred Nodding_off_to_sleep Difficulty_keeping_to_the_middle Difficulty_maintaining_the_corre Mind_wandering_to_other_things Reactions_were_slow Head_dropping_down;
run;

proc mixed data=Qxcondition;
class condition segment;
model Struggling_to_keep_your_eyes_ope = condition segment condition*segment;
run;


proc mixed data=Qxcondition method=ml;
class condition segment;
model Struggling_to_keep_your_eyes_ope = condition segment condition*segment /solution;
random intercept/subject= subject_no;
run;

proc print data=predicted;
run;
