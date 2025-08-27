/* SAS program to accompany the presentation 
   "Beyond the Histogram: Moment-Ratio Diagrams for Modeling Distributions"
   by Rick Wicklin
   August 2025
*/

/* This file creates annotation data sets for visualizing the moment-ratio diagram.
   The coordinates are the (x1,y1) variables.
   The data sets are:
   MR_Boundary : The boundary between the valid and invalid region
   MR_Points : Distributions that are points (Normal, Uniform, Exponential, T5, T6, T7. T8,...
   MR_Beta_Region: The (skew, kurt) region that corresponds to the Beta(a,b) distribution
   MR_LN_Curve: The (skew, kurt) curve that corresponds to the Lognormal(sigma) distribution
   MR_Gamma_Curve: The (skew, kurt) curve that corresponds to the Gamma(alpha) distribution
   MR_Weibull_Curve: The (skew, kurt) curve that corresponds to the Weibull(k) distribution
   MR_IGauss_Curve: The (skew, kurt) curve that corresponds to the IGamma(lambda) distribution
*/

/*********** BEGIN MACRO SECTION ***********/
/* Define useful helper macros for the M-R diagram */
/* Macro to convert between full kurtosis and excess kurtosis */
%macro Ex2Full(k); ((&k)+3)  %mend;
%macro Full2Ex(k); ((&k)-3)  %mend;
/* All computations are in terms of EXCESS kurtosis. Use Y2AXIS for FULL kurtosis axis. */
%let xL = -2.4; %let xR =  2.4;    /* range of skewness is [xL, xR] */
%let yB = -2.0; %let yT = 10.0;    /* range of kurtosis is [yB, yT] */
%let yB2 = %sysevalf(&yB+3);       /* range for full kurtosis (Y) axis */
%let yT2 = %sysevalf(&yT+3);
%let xL2 = %sysevalf(&xL-0.1);     /* range for skewness (X) axis */
%let xR2 = %sysevalf(&xR+0.1);


/* Main macro: Plot the moment-ratio diagram for a given data set and a
   given annotation data set. By default, the (skew, kurt) scatter plot
   is fully opaque, but you can set the transparency in the macro call. 
   DS: The data set that contains sample statistics or bootstrap statistics. 
       These are plotted as markers in a scatter plot.
   AnnoDS: The annotation data set that contains the M-R diagram curvers and regiona
   Transparency: A value in [0,1] for the DS markers, where 0=Fully Opaque and 1=Fully Transparent. Default=0.
   Symbol: The symbol to use for the DS markers (default=Circle)
*/
%macro PlotMRDiagram(DS, annoDS, Transparency=0, Symbol=Circle);
/* given a data set that contains variables KURT and SKEW, this macro
   adds the FULLKURT variable and labels for the three variables */
data _&DS;
   set &DS;
   FullKurt = %Ex2Full(Kurt);
   label Kurt="Excess Kurtosis"
      FullKurt="Full Kurtosis"
      Skew="Skewness";
run;

proc sgplot data=_&DS sganno=&annoDS noautolegend;
   scatter x=Skew y=Kurt / markerattrs=(symbol=&Symbol) transparency=&Transparency;
   scatter x=Skew y=FullKurt / y2axis transparency=1;  /* invisible */
   refline 0 / axis=x transparency=0.2;
   xaxis grid values=(&xL2 to &xR2 by 0.5);
   yaxis  reverse grid values=(&yB  to &yT);
   y2axis reverse grid values=(&yB2 to &yT2);
run;
%mend PlotMRDiagram;


/* This is the public macro to create the annotation data sets. The end of this file
   contains the call 
   %MR_Define_Anno
   which results in writing the annotation data sets.
   The data sets are only written the first time the macro is called.
   Subsequent times, the macro does nothing.
   You can force the macro to re-create the annotation data sets by calling it as
   MR_Define_Anno(force=1);
*/
%macro MR_Define_Anno(force=);
   %if %symexist(MR_FirstRun) = 0 %then %do;
      %global MR_FirstRun;
      %let MR_FirstRun = 1;
   %end;

   /* Check if the FORCE parameter has been provided and is not empty. */
   %if %length(&force) > 0 %then %do;
      *%put NOTE: The FORCE parameter was specified.;
      %let MR_FirstRun = 1;
   %end;

   /* Check if the global macro variable MR_FirstRun exists and is not equal to 1. */
   %if &MR_FirstRun eq 1 %then %do;
      %MR_Define_Anno_DS;
      %let MR_FirstRun = 0;
   %end;
   /* If _FirstRun=0 and FORCE was not specified, do nothing. */
%mend MR_Define_Anno;
/*********** END MACRO SECTION ***********/


/*********** BEGIN WRITING ANNOTATION DATA SETS USED BY %MR_Define_Anno ***********/
%macro MR_Define_Anno_DS;
/* MR_Boundary : The boundary between the valid and invalid region */
data MR_Boundary(drop=x);
length function $12 Curve $12 LineColor $20;
retain DrawSpace "DataValue"
       LineColor "Black"
       Curve "Boundary";
function = "POLYLINE"; 
x1=&xL; y1=1+x1**2; y1=%Full2Ex(y1); output;
function = "POLYCONT";
do x = &xL to &xR by 0.1;
   x1=x; y1=1+x1**2;  y1=%Full2Ex(y1);
   output;
end;
run;

/* MR_Points : Distributions that are points in the moment-ratio diagram.
   Points for the exponential, normal, Gumbel, SU, SB, and t distribution with 
   DOF 5,6,7,8,10,11,12. Also text that marks the invalid region. 
   The coordinates are (x1,y1).
*/
data MR_Points(drop=nu);
retain DrawSpace "DataValue";
length function $12 Label $24 Curve $12;
function = "TEXT"; 
Label="E";  x1 = 2;    y1= 6;   Curve="Exponential"; output;
Label="N";  x1 = 0;    y1= 0;   Curve="Normal";      output;
Label="G";  x1 = 1.14; y1= 2.4; Curve="Gumbel";      output;
Label="SU"; x1 = 0.75; y1= 5;   Curve="SU";          output;
Label="SB"; x1 = 2;    y1= 4;   Curve="SB";          output;
Curve="T";
do nu=5 to 8;
   Label=cats("T",nu); x1=0; y1 = 6/(nu-4);          output;
end;
do nu=10 to 12;                              /* plot ellipses marks */
   Label="."; x1=0; y1 = 6/(nu-4);                   output;
end;
Curve="Region";
do x1=-2, 2;
  function="TEXT"; TextSize=10; Label="Invalid Region"; y1=-1; output;
end;
run;

/* MR_Beta_Region: The (skew, kurt) region that corresponds to the Beta(a,b) distribution */
data MR_Beta_Region(drop=x);
length function $12 Curve $12 Label $24 LineColor $20;
retain DrawSpace "DataValue"
       Display "All"
       LineColor "LightGray" 
       Curve "Beta";
function = "TEXT"; Anchor="Left ";
label = "Beta";
x1=&xL; y1=2+x1**2; y1=%Full2Ex(y1); output;
Transparency = 0.5; FillTransparency = 0.5;
FillColor = "LightGray";
function = "POLYGON"; 
x1=&xL; y1=1+x1**2; y1=%Full2Ex(y1); output;
function = "POLYCONT";
n=1;
do x = &xL to &xR+0.05 by 0.1;
   x1=x; y1=1+x1**2; y1=%Full2Ex(y1);
   output;
end;
do x = &xR to &xL-0.05 by -0.1;
   x1=x; y1=3+1.5*x1**2; y1=%Full2Ex(y1);
   output;
end;
run;

/* MR_LN_Curve: The (skew, kurt) curve that corresponds to the Lognormal(sigma) distribution */
data MR_LN_Curve;
length function $12 Label $24 Curve $12 LineColor $20;
retain DrawSpace "DataValue"
       LineColor "DarkGreen"
       Curve "LogNormal";
function = "TEXT"; Anchor="Right";
label = "LogN";
drop var var0;
var0 = 0.355; var=var0;
x1= (exp(var)+2)*sqrt(exp(var)-1);
y1 = exp(4*var) + 2*exp(3*var) + 3*exp(2*var) - 6;
output;
function = "POLYLINE"; Anchor=" ";
output;
function = "POLYCONT";
do var = Var0 to 0.005 by -0.005;
   x1= (exp(var)+2)*sqrt(exp(var)-1);
   y1 = exp(4*var) + 2*exp(3*var) + 3*exp(2*var) - 6;
   output;
end;
x1=0; y1=0;output;
run;

/* MR_Gamma_Curve: The (skew, kurt) curve that corresponds to the Gamma(alpha) distribution */
data MR_Gamma_Curve;
retain DrawSpace "DataValue";
length function $12 Label $24 Curve $12 LineColor $20;
retain LineColor "Magenta" Curve "Gamma";
drop a a0 dx N i;
function = "TEXT"; Anchor="Right";
label = "Gam";
a0 = (2/&xR)**2;
a = a0;
x1 = 2/sqrt(a); y1= 6/a; output;
Transparency = 0.5;
function = "POLYLINE"; Anchor=" ";  output;
dx=0.1; N=floor(&xR/dx);
function ="POLYCONT";
do i = 2 to N;
   a = (2/(2/sqrt(a) - 0.1))**2;
   x1 = 2/sqrt(a); y1= 6/a;
   if (&xL<= x1 <=&xR) & (&yB <= y1 <= &yT) then output;
end;
x1=0; y1=0; output;
run;

/* MR_Weibull_Curve: The (skew, kurt) curve that corresponds to the Weibull(k) distribution */
/* First, write SAS versions of the formulas for skewness and kurtosis from Wikipedia:
   https://en.wikipedia.org/wiki/Weibull_distribution
*/
%macro Weib_SkewExKurt(k);
   mu = Gamma(1 + 1/k);                         /* mean (lambda=1) */
   var = (Gamma(1 + 2/k) - Gamma(1 + 1/k)**2);  /* variance */
   sigma = sqrt(var);                           /* std dev */
   skew = ( Gamma(1 + 3/k) - 3*mu*var - mu**3 ) / sigma**3;
   x1 = skew;                                   /* x1=skew; y1=excess kurt */
   y1 = ( Gamma(1 + 4/k) - 4*mu*sigma**3*skew - 6*mu**2*var - mu**4 ) / var**2;
   y1 = y1 - 3;                                 /* excess kurtosis */
%mend;

/* MR_Weibull_Curve: Annotation data set. The (skew, kurt) curve that corresponds to the Weibull(k) distribution */

data MR_Weibull_Curve;
length function $12 Label $24 Curve $12 LineColor $20 ;
retain DrawSpace "DataValue"
       LineColor "Brown"
       Curve     "Weibull";
drop k0 k_infin k mu var sigma skew;
k0 = 0.9; 
k_infin = 1000;
k = k0;
%Weib_SkewExKurt(k);
function = "POLYLINE"; Anchor="     ";
output;
function = "POLYCONT";
do k = 1 to 1.9 by 0.1, 
       2 to 5 by 0.25, 
       6 to 12,
       15, 20, 25, 50, 100, k_infin;
   %Weib_SkewExKurt(k);
   output;
end;
label = "Weibull"; function = "TEXT"; Anchor="Left ";
output;
run;

/* First, write SAS versions of the formulas for skewness and kurtosis from Wikipedia:
   https://en.wikipedia.org/wiki/Inverse_Gaussian_distribution
*/
%macro IG_SkewExKurt(lambda);
   /* standardize to have unit variance by moving the mu parameter: Var = mu**3/lambda */
   mu = lambda**(1/3);                          /* SET mu */
   var = mu**3 / lambda;                        /* variance = 1 */
   /* skew = 3*sqrt(mu/lambda), but we can substiture mu and reduce this term! */
   skew = 3/lambda**(1/3);
   x1 = skew;                                   /* x1=skew; y1=excess kurt */
   y1 = 15*mu/lambda;                           /* excess kurtosis */
%mend;

/* MR_IGauss_Curve: The (skew, kurt) curve that corresponds to the IGamma(lambda) distribution */
data MR_IGauss_Curve;
length function $12 Label $24 Curve $12 LineColor $20 ;
retain DrawSpace "DataValue"
       LineColor "Gray"
       Curve     "IGauss";
drop lambda0 lambda mu var  skew;
lambda0 = 2.0;
lambda = lambda0;
%IG_SkewExKurt(lambda0);
function = "POLYLINE"; Anchor="     ";
output;
function = "POLYCONT";
do lambda = 1.8 to 5 by 0.2, 
       10 to 50 by 5,
       100, 500, 1000, 5000, 10000;
   %IG_SkewExKurt(k);
   output;
end;
lambda = .I; x1 = 0; y1 = 0; output;
lambda = 2;
%IG_SkewExKurt(lambda);
label = "IGauss"; function = "TEXT"; Anchor="Right";
output;
run;
%mend MR_Define_Anno_DS;
/*********** END WRITING ANNOTATION DATA SETS USED BY %MR_Define_Anno ***********/

/* CREATE THE ANNOTATION DATA SETS */
%MR_Define_Anno;
