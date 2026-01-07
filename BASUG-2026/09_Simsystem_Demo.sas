/* SAS program to accompany the presentation 
   "Beyond the Histogram: Moment-Ratio Diagrams for Modeling Distributions"
   by Rick Wicklin
   August 2025

   This program demonstrates using PROC SIMSYSTEM to create a grid of (skew, kurt) values
   and simulate samples for each point in the grid.

   THIS PROGRAM REQUIRES A LICENSE FOR VISUAL STATISTICS in SAS VIYA.
*/
cas;

/* Visualize the grid of (skew, kurt) values and a few simulated data samples */
%let N = 50;           /* sample size */   
%let NSamples = 500; /* number of simulated samples for each (skew,kurt) value */
/* NOTE: If the grid contains G points, then the Moments data set has
   G*NSamples*N observations, which can be big! */

proc simsystem system=Johnson  /* use the Johnson system to simulate */
               seed=123        /* set the random number seed */
               n=&N            /* sample size */
               nrep=&NSamples  /* number of samples */ 
               momentreps      /* output moments for each simulated sample */
               plot(only)=mrmap;/* draw a MR diagram */
   /* specify a grid of moments */ 
   momentgrid skewness = 0 to 2.5 by 0.25
              kurtosis = 1.5 to 8   by 0.5;
   ods select SimulationInfo JohnsonMap;
   ods output Moments=Moments(where=(SimIndex in (22, 18, 62, 108) & Replicate=1));  /* output a few samples to WORK */
   OUTPUT out=WORK.SimData(where=(SimIndex in (22, 18, 62, 108) & REP=1));
run;

/* visualize the distributions of a few simulated data samples:
   SimIndex Skew   Kurt
    18      0.25   3
    22      0.25   5
    62      1      4 
   108      1.75   6
*/
proc print data=Moments;
   var SimIndex Skewness Kurtosis;    
run;

/* visualize some of the Johnson distributions */
ods graphics / push width=250px height=175px;
proc sgplot data=WORK.SimData;
    by SimIndex;
    histogram Variate;
run;
ods graphics / pop;
