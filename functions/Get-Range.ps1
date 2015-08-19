function Get-Range{
<#
    .SYNOPSIS
        Function to retrieve a continuous or stepwise range of integers,decimals,dates,month names, day names or chars. Simulating Haskell`s range operator
        
    .DESCRIPTION
		The function works similar to the built-in range operator (..). But adds functionality to retrieve stepwise ranges date, month name, day name and 
		character ranges like in Haskell.
		
    .PARAMETER range
        A string that represents the range. The range can be specified as START..END or as FIRST,SECOND..END where the difference between
		FIRST and SECOND (positive or negative) determines the step increment or decrement. The elements of the range can consist of only characters, integers,decimals,dates,month names,day names
		or special PowerShell notation like 1kb,1mb,1e6...
		
	.Example
		Set-Alias gr Get-Range
		#same as built-in
		gr 1..10

		#range of numbers from 1 to 33 with steps of .2
		gr 1,1.2..33

		#range of numbers from 10 to 40 with steps of 10
		gr 10,20..40

		#range of numbers from -2 to 1024 with steps of 6
		gr -2,4..1kb

		#range of numbers from 10 to 1 with steps of -2
		gr 10,8..1

		#range of characters from Z to A
		gr Z..A
		
		#range of date objects 
		gr 1/20/2014..1/1/2014
		
		#range of month names
		gr March..May
		
		#range of day names
		gr Monday..Wednesday
#>
   [cmdletbinding()] 
    param($range)
	#no step specified
	if ($range -is [string]) { 
		#check for month name or day name range
		$monthNames=(Get-Culture).DateTimeFormat.MonthNames
		$dayNames=(Get-Culture).DateTimeFormat.DayNames
		$enum=$null
		if ($monthNames -contains $range.Split("..")[0]){$enum=$monthNames}
		elseif ($dayNames -contains $range.Split("..")[0]){$enum=$dayNames}
		if ($enum){
			$start,$end=$range -split '\.{2}'
			$start=$enum.ToUpper().IndexOf($start.ToUpper()) 
			$end=$enum.ToUpper().IndexOf($end.ToUpper())
			$change=1
			if ($start -gt $end){ $change=-1 }
			while($start -ne $end){
				$enum[$start]
				$start+=$change
			}
			$enum[$end]
			return
		}
		#check for character range
		if ([char]::IsLetter($range[0])){
			[char[]][int[]]([char]$range[0]..[char]$range[-1])
			return
		}
		#check for date range
		if (($range -split '\.{2}')[0] -as [datetime]){
			[datetime]$start,[datetime]$end=$range -split '\.{2}'
			$change=1
			if ($start -gt $end){ $change=-1 }
			while($start -ne $end){
				write-host $start
				$start=($start).AddDays($change)
			}
			write-host $end
			return
		}
		Invoke-Expression $range
		return 
	}
	$step=$range[1].SubString(0,$range[1].IndexOf("..")) - $range[0]
	#use invoke-expression to support kb,mb.. and scientific notation e.g. 4e6
	[decimal]$start=Invoke-Expression $range[0]
	[decimal]$end=Invoke-Expression ($range[1].SubString($range[1].LastIndexOf("..")+2))
	$times=[Math]::Truncate(($end-$start)/$step)
	$start
	for($i=0;$i -lt $times ;$i++){
		($start+=$step)
	}
}
Set-Alias gr Get-Range

gr 1.1.2015..1.5.2015