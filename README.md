# Moment-Ratio Diagrams for Modeling Distributions 

## Overview
This repo contains SAS programs to accompany the presentation
"Beyond the Histogram: Moment-Ratio Diagrams for Modeling Distributions"
by Rick Wicklin, 
created August 2025. First presented 23Sep2025 at SESUG 2025, Cary NC.

## Contents
The moment-ratio diagram (MR diagram) is a graphical tool that enables you to visualize how different distributions relate to each other and to sample data. This presenation shows:
* How to construct a MR diagram in SAS.
* How to use a MR diagram to identify candidate distributions to model univariate data. 
  The diagram shows common distributions such as normal, lognormal, gamma, beta, etc. 
* How to use a MR diagram and a system of flexible distributions to plan a simulation 
  study in which the dimulated data exhibit a wide range of shapes.

This GitHub repo contains the following files:

* **MR_Macros.sas**: Defines macros related to creating a moment-ratio diagram in SAS. You should %INCLUDE the full path to this file, such as  
`%INCLUDE "\<path/\>MR_Macros.sas";`  
The primary macros are as follows:
  * `%MR_Define_Anno`: Automatically runs when you %INCLUDE the file.
  * `%PlotMRDiagram(DS, annoDS, Transparency=, Symbol=)`: Execute every time you want to create a moment-ratio diagram. The arguments are:
    * `DS`: The data set that contains sample statistics or bootstrap statistics. These are plotted as markers in a scatter plot. The dataset must contain variables `SKEW` and `KURT`.
    * `AnnoDS`: The annotation data set that contains the M-R diagram curves and regions.
    * `Transparency`: A value in `[0,1]` for the DS markers, where `0=Fully Opaque` and `1=Fully Transparent`. The default value is `0`.
    * `Symbol`: The symbol to use for the DS markers. The default value is `Circle`.
* **01_MR_Empty.sas**: Create a basic moment-ratio diagram.
* **02_MR_Gamma.sas**: Demonstrate how the skewness and kurtosis changes as you vary the shape parameter in a Gamma distribution.
* **03_MR_Beta.sas**: Show distributions for some points in the Beta region of the MR diagram.
* **04_MR_All.sas**: Create a MR diagram that relates common distributions.
* **05_Fit_Univariate.sas**: Use `PROC UNIVARIATE` to fit common distributions to data.
* **06_Fit_Severity.sas**: Use `PROC SEVERITY` to fit common distributions to data. This program requires a license for SAS/ETS.
* **07_MR_Data.sas**: Overlay sample statistics on a basic MR diagram.
* **08_MR_Bootstrap.sas**: Overlay a bootstrap distribution on a basic MR diagram.
* **09_Simsystem_Demo.sas**: Use `PROC SIMSYSTEM` to create a grid of skewness-kurtosis values on a moment-ratio diagram. This program requires a license for SAS Viya and Visual Statistics.
* **10_Simsystem_Study.sas**: Use `PROC SIMSYSTEM` to create a grid of skewness-kurtosis values. For each Johnson distribution in the grid, simulate B data sets of size N. Estimate the coverage probability for a CI formula. This program requires a license for SAS Viya and Visual Statistics.

## Further Reading

* Chapter 16 of [_Simulating Data with SAS_](https://support.sas.com/en/books/authors/rick-wicklin.html). (Wicklin, 2013)
* [The moment-ratio diagram](https://blogs.sas.com/content/iml/2020/01/15/moment-ratio-diagram.html). Published 15JAN2020.
* [Use the moment-ratio diagram to visualize the sampling distribution of skewness and kurtosis](https://blogs.sas.com/content/iml/2024/04/22/moment-ratio-skew-kurt.html). Published 04APR2022.
* [Introducing PROC SIMSYSTEM in SAS Viya](https://blogs.sas.com/content/iml/2024/11/11/proc-simsystem-sas-viya.html). Published 11NOV2024.
* [On using flexible distributions to fit data](https://blogs.sas.com/content/iml/2024/02/26/fit-flexible-distribution.html). Published 26FEB2024.
* [How to add a curve to a moment-ratio diagram](https://blogs.sas.com/content/iml/2025/06/23/add-curve-moment-ratio.html). Published 23JUN2025.
