/* SAS program to accompany the presentation 
   "Beyond the Histogram: Moment-Ratio Diagrams for Modeling Distributions"
   by Rick Wicklin
   August 2025

   Introduction and motivation for looking at moment-ratio
   diagrams as a tool for fitting distributions */

/**************************************************/
/* 1. Visualize the PFD of the Gamma(alpha, sigma) distribution 
      where alpha = 1.6 is a SHAPE parameter, and
            sigma = 1   is a SCALE parameter.
*/
data PDF;
do x = 0 to 6 by 0.01;
   PDF = pdf("Gamma", x, 1.6, 1);
   output;
end;

ods graphics / push width=400px height=200px;
title "PDF of Gamma(1.6, 1)";
proc sgplot data=PDF;
  series x=x y=PDF / lineattrs=(thickness=2);
  xaxis grid;
  yaxis grid;
run;
ods graphics / pop;
title;

/**************************************************/
/* 2. Generate N=50 random observation from  
      Gamma(alpha, sigma), 
      where alpha=1.6 is SHAPE parameter, 
            sigma=1   is SCALE parameter */
%let NObs = 50;
data Gamma1Sim;
call streaminit(6262);
do i = 1 to &NObs;
   y = rand("Gamma", 1.6, 1);
   output;
end;
keep y;
run;

/* The population skewness=1.58 and kurtosis=3.75.
   What are the sample estimates? */
proc means data=Gamma1Sim N Mean Std Skew Kurt ndec=2;
run;

/* visualize the data distribution */
ods graphics / push width=400px height=200px;
proc univariate data=Gamma1Sim;
   histogram y / endpoints ODSTitle="Random Sample (N=50)";
   ods select Histogram;
run;
ods graphics / pop;

/**************************************************/
/* 3. The "shotgun approach": Fit a bunch of distributions
   to the data. Use GoF tests to reject some. */
proc univariate data=Gamma1Sim;
   var y;
   histogram y / Lognormal Exp Weibull Gamma IGauss  
                 endpoints ODSTitle="Many Fits";
   ods select GoodnessOfFit Histogram;
run;

/**************************************************/
/* 4. Notice: Even though the data are simulated from a Gamma
      distribution, the GoF tests cannot exclude the possibility
      that the data are sampled from LogN, Exp, Weibull, and Gamma! */

/* 5. Perhaps the GoF tests have low power.
      Instead of GoF tests, let's 
      select the model that has the lowest criterion such as 
      -2*LL, AIC, AICC, BIC, or similar. Use PROC SEVERITY to 
      quickly get these statistics. */
proc severity data=Gamma1Sim plots=none 
       print(ONLY)=(ALLFITSTATS);
   loss y;
   dist Logn Exp Gamma IGauss Weibull;
   ods select AllFitStatistics;
   ods output AllFitStatistics=FitStats;
run;

proc print data=FitStats(keep=_MODEL_ Neg2LogLike Neg2LogLike_Sel) noobs;
  where Neg2LogLike_Sel=1;
run;


/**************************************************/
/* 6. Hmm, the "best choice" depend on the criterion we use! 
   Furthermore, look at the values of the other models relative 
   to the "best" model. For example, the numbers in the -2*LL column are similar. 
   This is a random sample, how much might the -2*LL value vary 
   if we draw a new sample? Let's simulate 1000 random samples
   and look at how many times the "best" model is selected 
   by the -2*LL criterion. */
%let NReps = 1000;
%let NObs = 50;
/* 6a: Simulate 1000 samples */
data GammaSim;
call streaminit(6262);
do SampleID = 1 to &NReps;
   do i = 1 to &NObs;
      y = rand("Gamma", 1.6, 1);
      output;
   end;
end;
run;

/* 6b: Find -2*LL for all 1000 samples */
ods exclude all;
proc severity data=GammaSim plots=none 
       print(ONLY)=(ALLFITSTATS);
   by SampleID;
   loss y;
   /* fit all pre-defined distribs */
   dist Logn Exp Gamma IGauss Weibull;
   ods output AllFitStatistics=FitStats;
run;
ods exclude none;

/* 6c: Count the number of times each model was selected */
proc freq data=FitStats(keep=SampleID _MODEL_ Neg2LogLike Neg2LogLike_Sel);
   where Neg2LogLike_Sel=1;
   tables _MODEL_ / nocum;
run;

/**************************************************/
/* 7. Why is there such a discrepancy in the "best" model?
      Two reasons:
      A. The Gamma, LogN, Weibull, etc, distributions have
         similar shapes. There are parameter values for which 
         the distributions look similar.
      B. Some random samples have fewer or more large values, which 
         affect the moments of the distribution (skewness and kurtosis).
         The standard errors of the skewness and kurtosis statistics are
         big for small data samples. */

/**************************************************/
/* 8. Show the distribution of the skewness and kurtosis statistics */
proc means data=GammaSim noprint;
   by SampleID;
   var y;
   output out=SK skew=Skewness kurt=Kurtosis;
run;

/* 8a. FInd the Monte Carlo estimates of skew and kurt */
proc means data=SK N Mean Std;
   var Skewness Kurtosis;
run;

title "Skewness vs Kurtosis for &NReps Random Samples from Gamma(1.6,1)";
proc sgplot data=SK;
   scatter x=Skewness y=Kurtosis / transparency=0.6;
   xaxis grid max=4;
   yaxis grid REVERSE max=20;
run;

ods graphics / push width=400px height=200px;
title "Skewness for &NReps Random Samples from Gamma(1.6,1)";
proc sgplot data=SK;
   histogram Skewness;
   refline 1.3666 / axis=x lineattrs=GraphData2(thickness=2) label="MC Est" splitchar=" ";
   refline 1.58 / axis=x lineattrs=GraphData3(thickness=2) label="Pop Value" splitchar=" ";
run;
title "Kurtosis for &NReps Random Samples from Gamma(1.6,1)";
proc sgplot data=SK;
   histogram Kurtosis;
   refline 2.44 / axis=x lineattrs=GraphData2(thickness=2) label="MC Est" splitchar=" ";
   refline 3.75 / axis=x lineattrs=GraphData3(thickness=2) label="Pop Value" splitchar=" ";
run;
ods graphics / reset;

/**************************************************/
/* 9. It almost looks like we could put a 
   curve inside the center these points in the scatter plot.
   Let's generate a curve. Later, we'll discover
   that this curve is the 'Gamma distribution' curve in an MR diagram. */
data MR_Gamma_Curve;
xL = 0.1; xR=5.1;
a0 = (2/xR)**2;
a = a0;
x1 = 2/sqrt(a); y1= 6/a; output;
dx=0.1; N=floor(xR/dx);
do i = 2 to N;
   a = (2/(2/sqrt(a) - 0.1))**2;
   x1 = 2/sqrt(a); y1= 6/a;
   if (xL<= x1 <=xR) then output;
end;
x1=0; y1=0; output;
keep a x1 y1;
run;

data All;
   set SK MR_Gamma_curve;
run;

title "Skewness vs Kurtosis for &NReps Random Samples from Gamma(1.6,1)";
proc sgplot data=All;
   scatter x=Skewness y=Kurtosis / transparency=0.6;
   series x=x1 y=y1;
   xaxis grid max=4;
   yaxis grid REVERSE max=20;
run;
