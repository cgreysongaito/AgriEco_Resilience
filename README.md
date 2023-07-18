Resilience of incremental productivity versus sustainability in crop farms
=========

#### Authors
Christopher J. Greyson-Gaito<sup>*1.</sup>, Aaron Delaporte<sup>2.</sup>, Alfons Weersink<sup>2.</sup>, Kevin S. McCann<sup>1.</sup>
----------

### Affiliations
*Corresponding Author - christopher@greyson-gaito.com

1. Department of Integrative Biology, University of Guelph, Guelph, ON, Canada, N1G 2W1
2. Department of Food, Agriculture & Resource Economics, University of Guelph, Guelph, ON, Canada, N1G 2W1

## ORCID
* CJGG &ndash; [0000-0001-8716-0290](https://orcid.org/0000-0001-8716-0290)
* AW &ndash; [0000-0001-5081-3593](https://orcid.org/0000-0001-5081-3593)
* KSM &ndash; [0000-0001-6031-7913](https://orcid.org/0000-0001-6031-7913)

## Julia scripts and datasets

### Folder and file structure
* figs &ndash; empty folder for figures to be placed (created in bacteriophage_figures.jl)
* scripts
    * packages.jl &ndash; list of packages required (file used in other scripts)
* .gitignore &ndash; file containing files and folders that git should ignore
* LICENSE.txt &ndash; CC by 4.0 License for this repository
* README.md &ndash; this file

### Instructions

1. Download the GitHub/Zenodo repo
2. Open the repo in Visual Studio Code (if you haven't already done so, set up [Julia in Visual Studio Code](https://www.julia-vscode.org/))
3. Most of the analysis here requires multiple cores. Thus to set up multiple cores on your computer, in Visual Studio Code find the Julia: Num Threads setting in the Extension Settings of the Visual Studio Code Julia Extension. Change this setting to at most the number of logical cores in your computer. Restart Julia. All parallel computing will run automatically regardless of the number of cores selected.
4. Run AgriEco_positivefeedbacks.jl and AgriEco_timedelay.jl to create the date required for AgriEco_figures.jl. Note, depending on the number of cores in your computer, this may take a some time.
5. Run scripts/AgriEco_figures.jl to produce the figures in the manuscript.
