/* SAS program to accompany the presentation 
   "Beyond the Histogram: Moment-Ratio Diagrams for Modeling Distributions"
   by Rick Wicklin
   August 2025

   This program shows how to visualize relationships between common distributions on the M-R diagram.
*/

%include "MR_Macros.sas";

/* Add the new curve to the existing set of curves and regions: */
data Full_MR;
  set MR_Beta_Region MR_LN_Curve MR_Gamma_Curve
      MR_Weibull_Curve MR_IGauss_Curve MR_Boundary
      MR_Points(where=(Label not in ('G','SU','SB')));
run;

data EmptyDS;
Skew = 0; kurt = 0;
run;

/* Draw the new moment-ratio diagram with the Weibull curve */
title "A Basic Moment-Ratio Diagram";
%PlotMRDiagram(EmptyDS, Full_MR, transparency=1);

