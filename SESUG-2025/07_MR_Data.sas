/* SAS program to accompany the presentation 
   "Beyond the Histogram: Moment-Ratio Diagrams for Modeling Distributions"
   by Rick Wicklin
   August 2025

   This program shows how to visualize sample statistics on the M-R diagram. 
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


/* the MR diagram can help you find help? */
proc means data=MyData Skew Kurtosis ndec=3;
   var y;
   output out=Sample_SK skew=Skew kurt=Kurt;
run;

/* Add the new curve to the existing set of curves and regions: */
data Full_MR;
  set MR_Beta_Region MR_LN_Curve MR_Gamma_Curve
      MR_Weibull_Curve MR_IGauss_Curve MR_Boundary
      MR_Points(where=(Label not in ('G','SU','SB')));
run;

/* Draw the moment-ratio diagram with the sample statistics */
title "Moment-Ratio Diagram and Sample Statistics";
%PlotMRDiagram(Sample_SK, Full_MR, transparency=0, symbol=Star);

/* enlarge the region near the sample statistics */
ods graphics / push width=1280px height=960px;
%PlotMRDiagram(Sample_SK, Full_MR, transparency=0, Symbol=Star);
ods graphics / pop;
