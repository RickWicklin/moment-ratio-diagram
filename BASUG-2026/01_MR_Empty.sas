/* SAS program to accompany the presentation 
   "Beyond the Histogram: Moment-Ratio Diagrams for Modeling Distributions"
   by Rick Wicklin
   August 2025

   This program shows a basic moment-ratio diagram with markers for certain symmetric distributions.
*/

%include "MR_Macros.sas";

data Minimal_MR;
  set MR_Points(where=(Label in ('U','N','.','T8','T7','T6','T5','Invalid Region'))) 
      MR_Boundary ;
run;
data EmptyDS;
Skew = 0; kurt = 0;
run;

title "Simple Moment-Ratio Diagram";
%PlotMRDiagram(EmptyDS, Minimal_MR, Transparency=1);
