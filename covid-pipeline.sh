#!/bin/bash
#Author: Vijay Nagarajan PhD
#American Academy For Biomedical Informatics
#License: GNU GPL

#source configuration info
source config.txt

#r library directory
mkdir -p ~/R/library
echo "R_LIBS=~/R/library" >> ~/.Renviron

#echo user data
printf "\n"
echo "Cytoscape Path: $cytoscape_path"
echo "JDK Path: $jdk_path"
echo "Input Data File: $input_confirmedcases"
echo "Input Attributes File: $input_regionattributes"

#remove old files
rm -rf images/covid-19-network.cys
rm -rf images/covid-19-transmission-similarity-dtw-network.svg
rm -rf images/covid-19-current-dtw-tree-meta.svg

#cp files to working directory
cp $input_confirmedcases data/time_series_current.csv
cp $input_regionattributes data/states-attributes.csv

#run meta data generation script
php scripts/covid-process-meta.php > data/time_series_current_meta.csv

#start cytoscape
printf "\n"
echo "waiting for cytoscape to start"
bash scripts/runcytoscape.sh &
sleep 60

#run rscript
Rscript scripts/covidapp.R
sleep 15

#close cytoscape and exit
xtermid=$(pgrep xterm)
kill $xtermid 
printf "\n"
echo -n "Run complete, your results are in images folder within this working directory: "
ls -lh images
printf "\n"
exit

