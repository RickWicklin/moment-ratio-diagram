/* SAS program to accompany the presentation 
   "Beyond the Histogram: Moment-Ratio Diagrams for Modeling Distributions"
   by Rick Wicklin
   August 2025

   This program shows how to visualize a bootstrap distribution of sample statistics on the M-R diagram.
*/

%include "MR_Macros.sas";

/* data modified from PROC UNIVARIATE documentation
   Gaps (in mm) between welded plates. */
data MyData;
   input y @@;
   label y = 'Plate Gap in mm';
   datalines;
 7.46   3.57   3.76   3.27   4.85 17.41   2.41   7.77   7.68   4.09
 2.52   5.12   5.34  16.56   7.42  3.78   7.14  11.21   5.97   2.31
 5.41   8.05   6.82   4.18   5.06  5.01   2.47   9.22   8.80   3.44
 5.19  13.02   2.75   6.01   3.88  4.50   8.45   3.19   4.86   5.29
15.47   6.90   6.76   3.14   7.36  6.43   4.83   3.52   6.36  10.80
;

/* A point estimate isn't sufficient. Use bootstrap to determine variance of estimates.
   The Essential Guide to Bootstrapping in SAS
   https://blogs.sas.com/content/iml/2018/12/12/essential-guide-bootstrapping-sas.html
   Use SURVEYSELECT to generate bootstrap resamples */
%let NumBoot = 500;
proc surveyselect data=MyData out=BootSamp noprint
           seed=123 method=urs rep=&NumBoot rate=1;
run;

proc means data=BootSamp noprint;
   by Replicate;
   freq NumberHits;
   var y;
   output out=MomentsBoot skew=Skew kurt=Kurt;
run;

ods layout gridded columns=1 advance=table;
proc print data=MomentsBoot(obs=5) noobs;
   var Replicate Skew Kurt;
run;
proc print data=MomentsBoot(firstobs=496) noobs;
   var Replicate Skew Kurt;
run;
ods layout end;

data Full_MR;
  set MR_Beta_Region MR_LN_Curve MR_Gamma_Curve
      MR_Weibull_Curve MR_IGauss_Curve MR_Boundary
      MR_Points(where=(Label not in ('G','SU','SB')));
run;

title "Moment-Ratio Diagram";
title2 "&NumBoot Bootstrap Resamples, N=&N";
%PlotMRDiagram(MomentsBoot, Full_MR, Transparency=0.4);


