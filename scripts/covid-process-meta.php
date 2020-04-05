<?php
#Author - Vijay Nagarajan
#Parse covid data

#some column data missing, have this to suppress notice about missing objects
error_reporting(E_ALL & ~E_NOTICE);
set_time_limit(0);
ini_set("memory_limit","100000M");
error_reporting(E_ALL & ~E_NOTICE);

#load the file content as array
$lines = file('data/time_series_current.csv');

#loop through each line
foreach($lines as $line)
	{ 
	$line=rtrim($line);
#get rid of the first heading line
	if(strpos($line, "Province") !== false OR strpos($line, "Grand") !== false OR strpos($line, "Diamond") !== false)
		{
#print out states head
		#echo "States","\n";		
		}
	else
		{
#explode data by ,
		$data = explode(",",$line);
#print out state name
		#echo $data[0],",";
		$data=array_unique($data);
		$numarray=array();
#initiate i for skipping last ,		
		$i=1;
		$count=count($data);
		#echo $count;
		
#loop through data and print only non-zero number		
		foreach ($data as $dat)
			{
			if($i<$count)
				{
				if((int)$dat == $dat && $dat != 0)
					{
					#echo trim($dat),",";
					$numarray[] = trim($dat);
					}
				++$i;
				}
			else
				{
				if((int)$dat == $dat && $dat != 0)
					{
					#echo trim($dat);
					$numarray[] = trim($dat);
					}
				++$i;
				}
			
			}
		#echo "\n";
		#print_r($numarray);
		
#get the daily data counts		
		$newnumarray=array();
		$newnumarray[]=$numarray[0];
		
		for($k=0; $k<(count($numarray)-1); $k++)
			{
				$firstnum=$numarray[$k];
				$secondnum=$numarray[$k+1];
				$newnum=$secondnum-$firstnum;
				$newnumarray[]=$newnum;
				#echo $newnum,",";
			}
		#print_r($newnumarray);
		#echo "\n";
		
		$j=1;
		$count2=count($newnumarray);
		#echo $count2,"\t";

		if($count2 > 1)
			{
			echo $data[0],",";		
			foreach($newnumarray as $newnumarrayitem)
				{
				if($j<$count2)
					{
					echo $newnumarrayitem,",";
					++$j;
					}
				else
					{
					echo $newnumarrayitem;
					++$j;
					}
				}
				echo "\n";
			}			
		}
	}

?>
