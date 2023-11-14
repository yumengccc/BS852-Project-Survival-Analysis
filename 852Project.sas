options ls=70 ps=55 nofmterr;
libname prj '/home/u62266791/BS852/Project';
FILENAME lng '/home/u62266791/BS852/Project/data.longevity.csv';

/*pre: data process*/
PROC IMPORT DATAFILE=lng DBMS=csv OUT=prj.lng; RUN;

data data1;
     set prj.lng; 
	 if Alive='Yes' then Mortality=0; else if Alive='No' then Mortality=1;
	 if sex=1 then sex=1; else if sex=2 then sex=0;
	 label sex='1=Male, 0=Female';
	 label Mortality='1=not-alive, 0=alive';
run;

proc means data=data1 missing;
    class sex;
    var grip_strength;
    output out=sex_grips mean=mean_grip std=sd_grip;
run;

proc sort data=data1; by sex; run;
data data2;
    merge data1 sex_grips;
    by sex;
    where sex in (1, 0);
    drop _TYPE_ _FREQ_;
run;

data prj.cleaned;
    set data2;
    time = Age_last_contact - Age_enrollment; 
    if grip_strength=. then weak_grip=.;
    else if grip_strength < (mean_grip - sd_grip) then weak_grip=1;
    else weak_grip=0;
    label time = 'survival time in this study';
    label weak_grip = '1=weak grip strength, 0=not weak';
    drop mean_grip sd_grip;
run;

/*Data preview*/
proc means data=prj.cleaned n nmiss mean std min max;
    var Age_enrollment BMI gait_speed fev1 DSST;
    class weak_grip;
run;
proc sort data=prj.cleaned; by descending weak_grip descending Mortality; run;
proc freq data=prj.cleaned order=data;
    tables mortality*weak_grip sex*weak_grip smoke*weak_grip high_ed*weak_grip / chisq;
run;

proc means data=prj.cleaned n nmiss mean std min max;
    var Age_enrollment BMI gait_speed fev1 DSST;
    class sex;
run;
proc sort data=prj.cleaned; by descending weak_grip descending Mortality; run;
proc freq data=prj.cleaned order=data;
    tables mortality*sex weak_grip*sex smoke*sex high_ed*sex / chisq;
run;

/*Q1*/
proc lifetest data=prj.cleaned plots=(s);
     time time*Mortality(0);
     strata weak_grip;
run;

proc phreg data=prj.cleaned; model time*Mortality(0) = weak_grip / rl; run;

proc phreg data=prj.cleaned;
     model time*Mortality(0) = weak_grip sex smoke high_ed Age_enrollment BMI gait_speed fev1 DSST/ rl;
run;

/*Q2*/
proc logistic data=prj.cleaned descending; model weak_grip = sex; run;
proc logistic data=prj.cleaned descending; model weak_grip = smoke; run;
proc logistic data=prj.cleaned descending; model weak_grip = high_ed; run;
proc logistic data=prj.cleaned descending; model weak_grip = Age_enrollment; run;
proc logistic data=prj.cleaned descending; model weak_grip = BMI; run;
proc logistic data=prj.cleaned descending; model weak_grip = gait_speed; run;
proc logistic data=prj.cleaned descending; model weak_grip = fev1; run;
proc logistic data=prj.cleaned descending; model weak_grip = DSST; run;

proc freq data = prj.cleaned; tables weak_grip*sex / chisq; run;
proc freq data = prj.cleaned; tables weak_grip*smoke / chisq; run;
proc freq data = prj.cleaned; tables weak_grip*high_ed / chisq; run;

/*Q3*/
proc phreg data=prj.cleaned;
    model time*Mortality(0) = weak_grip sex/ rl;
run;
proc phreg data=prj.cleaned;
    model time*Mortality(0) = weak_grip sex weak_grip*sex / rl;
run;
proc phreg data=prj.cleaned;
    model time*Mortality(0) = weak_grip sex weak_grip*sex smoke high_ed Age_enrollment BMI gait_speed fev1 DSST/ rl;
run;

data male; set prj.cleaned; where sex=1; run;
data female; set prj.cleaned; where sex=0; run;
proc phreg data=male;
     model time*Mortality(0) = weak_grip smoke high_ed Age_enrollment BMI gait_speed fev1 DSST/ rl;
run;
proc phreg data=female;
     model time*Mortality(0) = weak_grip smoke high_ed Age_enrollment BMI gait_speed fev1 DSST/ rl;
run;

/*Q4*/
proc phreg zph data=prj.cleaned;
    model time*Mortality(0) = weak_grip sex smoke high_ed Age_enrollment BMI gait_speed fev1 DSST/ rl;
run;

proc phreg data=prj.cleaned; model time*Mortality(0) = weak_grip sex/ rl; run;
proc phreg data=prj.cleaned; model time*Mortality(0) = weak_grip smoke/ rl; run;
proc phreg data=prj.cleaned; model time*Mortality(0) = weak_grip high_ed/ rl; run;
proc phreg data=prj.cleaned; model time*Mortality(0) = weak_grip Age_enrollment / rl; run;
proc phreg data=prj.cleaned; model time*Mortality(0) = weak_grip BMI / rl; run;
proc phreg data=prj.cleaned; model time*Mortality(0) = weak_grip gait_speed / rl; run;
proc phreg data=prj.cleaned; model time*Mortality(0) = weak_grip fev1 / rl; run;
proc phreg data=prj.cleaned; model time*Mortality(0) = weak_grip DSST / rl; run;
