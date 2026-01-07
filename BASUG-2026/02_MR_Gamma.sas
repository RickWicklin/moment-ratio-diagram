/* SAS program to accompany the presentation 
   "Beyond the Histogram: Moment-Ratio Diagrams for Modeling Distributions,"
   by Rick Wicklin
   August 2025

   This program shows how the skewness and kurtosis changes as you vary 
   the alpha (shape) parameter in s Gamm(alpha) distribution 
*/

%include "MR_Macros.sas";

/* gamma curve */
data GammaPanel;
length text $24;
do alpha = 1, 2, 4, 50;
   xt=.; yt=.; text=" "; output;
   /* variance = alpha*theta**2; standardize so that var = 1 */
   theta = sqrt(1 / alpha);
   skew = 2 / sqrt(alpha);
   ExKurt = 6 / alpha;
   do x = 0 to 10 by 0.1;
      PDF = pdf("gamma", x, alpha, theta);
      output;
   end;
   if alpha=1 then do;
      x=.; xt=4; yt=0.6; text="Gamma(1) = Exponential"; output;
   end;
   else if alpha=50 then do;
      x=.; xt=4; yt=0.6; text="Gamma(alpha) -> normal"; output;
   end;
end;
label PDF = "Density";
run;

ods graphics/reset;
ods graphics / push width=480px height=480px ;
title "Shape of Gamma(alpha) distributions";
proc sgpanel data=GammaPanel noautolegend;
   panelby alpha / columns=1 onepanel;
   series x=x y=PDF;
   text x=xt y=yt text=text / textattrs=(size=10) strip;
   rowaxis offsetmin=0.01;
   colaxis min=0 max=10 offsetmin=0 offsetmax=0;
run;
ods graphics / pop;


/* The skewness and (excess) kurtosis for a GAMMA(alpha) distribution 
   (Standardize so that the variance is 1.)
*/
%let xL = -2.4; %let xR =  2.4;    /* range of skewness is [xL, xR] */
%let yB = -2.0; %let yT = 10.0;    /* range of kurtosis is [yB, yT] */

data GammaCurve;
xR = &xR;  
a0 = (2/&xR)**2;
alpha = a0;
skewness = 2/sqrt(alpha); kurtosis= 6/alpha; output;
dx=0.1; N=floor(&xR/dx);
do i = 2 to N;
   alpha = (2/(2/sqrt(alpha) - 0.1))**2;
   skewness = 2/sqrt(alpha); kurtosis= 6/alpha;
   if (&xL<= skewness <=&xR) & (&yB <= kurtosis <= &yT) then output;
end;
skewness=0; kurtosis=0; alpha=.I; output;
keep alpha skewness kurtosis; 
run;


title "Parametric image of alpha in [0.7, infinity)";
proc sgplot data=GammaCurve;
   label alpha = "alpha" skewness="skewness" kurtosis="Excess Kurtosis";
   format alpha best3.;
   series x=skewness y=kurtosis / markers datalabel=alpha;
   refline 0 / axis=x transparency=0.2;
   xaxis grid values=(-2.5 to 2.5 by 0.5);
   yaxis  reverse grid values=(-2 to 10);
   y2axis reverse grid values=( 1 to 13);
run;

ods graphics / push width=250px height=250px;
title;
proc sgplot data=GammaPanel noautolegend;
   by alpha;
   where alpha in (1,2,50);
   series x=x y=PDF;
   yaxis grid offsetmin=0.01 max=1;
   xaxis grid min=0 max=10 offsetmin=0 offsetmax=0;
run;
ods graphics / pop;

/***************************************/

data Gamma_MR;
  set MR_Points(where=(Label in ('U','N','.','T8','T7','T6','T5','Invalid Region'))) 
      MR_Boundary MR_Gamma_curve;
run;
data EmptyDS;
Skew = 0; kurt = 0;
run;

title "Moment-Ratio Diagram with Gamma Distribution";
%PlotMRDiagram(EmptyDS, Gamma_MR, Transparency=1);
