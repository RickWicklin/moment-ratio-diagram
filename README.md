# Moment-Ratio Diagrams for Modeling Distributions 
A common task in statistics is to model univariate data by fitting parameters in a probability distribution such as normal, lognormal, gamma, beta, etc. Given the data, how should you choose the model? While various statistical criteria can be used, the moment-ratio diagram (MR diagram) is a graphical tool that enables you to understand how different distributions relate to the data and to each other."

This repo contains SAS programs to accompany the presentation
by Rick Wicklin, 
August 2025.

The files in this GitHub repo are as follows:

* **MR_Macros.sas**: Defines macros related to creating a moment-ratio diagram in SAS. You should %INCLUDE the full path to this file, such as  
`%INCLUDE "\<path/\>MR_Macros.sas";`  
The primary macros are as follows:
  * `%MR_Define_Anno`: Automatically runs when you %INCLUDE the file.
  * `%PlotMRDiagram(DS, annoDS, Transparency=, Symbol=)`: Execute every time you want to create a moment-ratio diagram. The arguments are:
    * `DS`: The data set that contains sample statistics or bootstrap statistics. These are plotted as markers in a scatter plot. The dataset must contain variables `SKEW` and `KURT`.
    * `AnnoDS`: The annotation data set that contains the M-R diagram curves and regions.
    * `Transparency`: A value in `[0,1]` for the DS markers, where `0=Fully Opaque` and `1=Fully Transparent`. The default value is `0`.
    * `Symbol`: The symbol to use for the DS markers. The default value is `Circle`.
* **01_Fit_Univariate.sas**: Use `PROC UNIVARIATE` to fit common distributions to data.
* **02_Fit_Severity.sas**: Use `PROC SEVERITY` to fit common distributions to data. This program requires a license for SAS/ETS.
* **03_Viz_Gamma.sas**: Demonstrate how the skewness and kurtosis changes as you vary the shape parameter in a Gamma distribution.
* **04_Empty_MR.sas**: Create a basic moment-ratio diagram.
* **05_Viz_Beta.sas**: Show distributions for some points in the Beta region of the MR diagram.
* **06_Viz_All.sas**: Create a MR diagram that relates common distributions.
* **07_Viz_Data_MR.sas**: Overlay sample statistics on a basic MR diagram.
* **08_Viz_Bootstrap_MR.sas**: Overlay a bootstrap distribution on a basic MR diagram.
* **09_Simsystem_Demo.sas**: Use `PROC SIMSYSTEM` to create a grid of skewness-kurtosis values on a moment-ratio diagram. This program requires a license for SAS Viya and Visual Statistics.
