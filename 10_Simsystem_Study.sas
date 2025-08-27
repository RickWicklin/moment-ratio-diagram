/* SAS program to accompany the presentation 
   "Beyond the Histogram: Moment-Ratio Diagrams for Modeling Distributions"
   by Rick Wicklin
   August 2025

   This program demsonstrates how to use PROC SIMSYSTEM to design a simulation study.
   The research question is:
   What is the empirical coverage probability for the 
        formula that gives the CI of the mean
        [xbar - t*s/sqrt(n), xbar + t*s/sqrt(n)]
        when the distribution for the data has skewness and excess kurtosis.
*/

cas;

/* Visualize the grid of (skew, kurt) values and a few simulated data samples */
%let N = 50;           /* sample size */   
%let NSamples = 20000; /* number of simulated samples for each (skew,kurt) value */
/* NOTE: If the grid contains G points, then the Moments data set has
   G*NSamples*N observations, which can be big! */
proc simsystem system=Johnson  /* use the Johnson system to simulate */
               seed=123        /* set the random number seed */
               n=&N            /* sample size */
               nrep=&NSamples  /* number of samples */ 
               momentreps      /* output moments for each simulated sample */
               plot=NONE;      /* draw a MR diagram */
   /* specify a grid of moments */ 
   momentgrid skewness = -0.5 to 2.5 by 0.25
              kurtosis = 1.5 to 8   by 0.5;
   ods select NONE;
   ods output Moments=Moments;          /* output sample moments to WORK */
run;
ods select ALL;

/* for each sample, create indicator variable that has the value 1 iff
   the CI contains the true mean (which is 0 in all cases)
*/
data CoverageCI;
    set Moments;
    alpha = 0.05;
    t_crit = quantile("t", 1-alpha/2, &N-1);
    SEM = t_crit * SampleStdDev / sqrt(&N);
    LowerCI = SampleMean - SEM;
    UpperCI = SampleMean + SEM;
    ParamInCI = (LowerCI < Mean & UpperCI > Mean);
    drop alpha t_crit SEM;
run;

/* the mean of the indicator variable is an estimate
   of the coverage probability */
proc means data=CoverageCI Mean noprint;
    class simIndex;
    var ParamInCI;
    ID skewness kurtosis;
    output out=Coverage(where=(_TYPE_=1)) Mean=CoverageProb;
run;

data Params;
    set Moments;
    by SimIndex;
    if first.SimIndex;
    keep SimIndex Mean StdDev Skewness Kurtosis;
run;

data SimSummary;
    merge Params Coverage;
run;

proc print data=SimSummary(obs=10);
    where Skewness >= 0;
    var SimIndex Skewness Kurtosis CoverageProb;
run;

/* create a heat map to visualize the covereage probability estimates */
proc sgplot data=SimSummary;
    where Skewness >= 0;
    heatmapparm x=skewness y=kurtosis colorresponse=CoverageProb;
    xaxis grid;
    yaxis grid reverse;
run;

/* model the covereage probability by using a quadratic response surface */
proc rsreg data=SimSummary plots=Contour;
    model CoverageProb = Kurtosis Skewness;
    ods select Contour;
run;
