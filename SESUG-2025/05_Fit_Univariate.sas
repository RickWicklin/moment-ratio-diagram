/* SAS program to accompany the presentation 
   "Beyond the Histogram: Moment-Ratio Diagrams for Modeling Distributions"
   by Rick Wicklin
   August 2025

   Show how to fit distributions to data by using PROC UNIVARIATE.
*/

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


title;footnote;
ods graphics/reset;
title "Sample Data (N=50)";
proc sgplot data=MyData noautolegend;
   histogram y;
   fringe y; 
run;

/***************************/

proc univariate data=MyData;
   histogram y / normal lognormal gamma weibull
                 odstitle="A Few Possible Models";
   ods select Moments Histogram ParameterEstimates GoodnessOfFit; 
   ods output GoodnessOfFit=GoF ParameterEstimates=PE;
run;

title "Candidate Distributions (PROC UNIVARIATE)";
proc print data=GoF noobs;
   where pValue >= 0.05;
   ID Distribution;
   var Test pValue;
run;

title "Parameter Estimates for Candidate Distributions (PROC UNIVARIATE)";
proc print data=PE noobs;
   where Distribution in ('Lognormal','Gamma') and
         not missing(Symbol) and Parameter^="Threshold";
   ID Distribution;
   var Parameter Symbol Estimate;
run;
