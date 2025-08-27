/* SAS program to accompany the presentation 
   "Beyond the Histogram: Moment-Ratio Diagrams for Modeling Distributions"
   by Rick Wicklin
   August 2025

   This program visualizes some beta distributions on the M-R diagram. See
   https://blogs.sas.com/content/iml/2024/04/15/beta-skewness-kurtosis.html 

   THIS PROGRAM REQUIRES A LICENSE FOR SAS IML.
*/

%include "MR_Macros.sas";


/* specify values in the moment-ratio diagram for which
   the Beta distribution has a variety of (s,k) values */
data SKBetaParms;
array skew[3] _temporary_ (0.1, 1, 1);
array kurt[3] _temporary_ (2.0, 2.25, 3.25);
do i = 1 to dim(skew);
   s = skew[i]; k = kurt[i]; 
   output;
end;
run;

proc iml;
/* Helper: return the skewness of the Beta(a,b) distribution */
start SkewBeta(a,b);
   return ( 2*(b-a)#sqrt(a+b+1) ) /
          ( (a+b+2)#sqrt(a#b) );
finish;
/* Helper: return the full kurtosis of the Beta(a,b) distribution */
start KurtBeta(a,b);
   return 3 + 6* ( (a-b)##2 # (a+b+1) - a#b#(a+b+2) ) /
                 ( a#b#(a+b+2)#(a+b+3) );
finish;
/* 1. Define a function takes an (a,b) value and returns an (s,k) value */
start SKBetaFun(a,b);
   return ( SkewBeta(a,b) || KurtBeta(a,b) );  /* return a ROW vector */
finish;
 
/* 2. Define a function that evaluates the vector-valued function M(a,b) - (s,k) */
start VecFun(param) global(g_skewTarget, g_kurtTarget);
   a = param[1]; b = param[2];
   target = g_skewTarget || g_kurtTarget;
   return( SKBetaFun(a,b) - target );
finish;
 
/* 3. Define a function that takes a vector of (s,k) values
   and calls the NLPHQN subroutine in SAS IML to obtain 
   (a,b) values that minimize the norm of the VecFun function */ 
start SolveForBetaParam(skew, kurt, printLevel=0) global(g_skewTarget, g_kurtTarget);
   /*     a     b constraints. Lower bounds in 1st row; upper bounds in 2nd row */
   con = {1e-6  1e-6,        /* a > 0 and b > 0 */
            .   .    };
   x0 = {1 1};               /* initial guess */
   optn = 2 //               /* solve least square problem that has 2 components */
          printLevel;        /* amount of printing */
   ab = j(nrow(skew), 2, .); /* return the a and b vectors as columns in matrix */
   do i = 1 to nrow(skew);
      g_skewTarget = skew[i]; g_kurtTarget = kurt[i];
      call nlphqn(rc, Soln, "VecFun", x0, optn) blc=con; /* solve for LS soln */
      if rc>0 then 
         ab[i,] = Soln;
   end;
   return( ab );
finish;

/* 4. use values of (skew, kurt) that are in the middle of the Beta region. Solve for (a,b) parameters. */
use SKBetaParms; read all var {'s' 'k'}; close;
Soln = SolveForBetaParam(s, k);
a = Soln[,1]; b = Soln[,2];
print s k a[F=5.2] b[F=5.2];
/* what do the curves look like? */
create Params var {'s' 'k' 'a' 'b'}; append; close;
QUIT;
 
data PDF;
set Params;
/* https://blogs.sas.com/content/iml/2018/08/08/plot-curves-two-categorical-variables-sas.html */
Group = catt("(skew,kurt) = (", putn(s,5.2)) || "," || catt(putn(k,5.2)) || ")";
do x = 0.001, 0.005, 0.01 to 0.99 by 0.01, 0.999;
   PDF = pdf("Beta", x, a,b);
   output;
end;
run;
 
ods graphics / push width=250px height=250px;

options nobyline;
title "Beta Distribution";
title2 "#byval1"; 
proc sgplot data=PDF;
  by group;
  series x=x y=PDF;
  xaxis grid;
  yaxis grid min=0 max=2.5;
run;
options byline;

ods graphics / pop;

/*************************************/

data BetaPts;
set SKBetaParms(rename=(s=skew));
kurt = %Full2Ex(k);
run;

data Beta_MR;
  set MR_Beta_Region MR_Gamma_Curve MR_Boundary 
      MR_Points(where=(Label not in ('E' 'G' 'SU' 'SB')));
run;

title "Moment-Ratio Diagram with Beta Region"; 
%PlotMRDiagram(BetaPts, Beta_MR);

/**************************/

