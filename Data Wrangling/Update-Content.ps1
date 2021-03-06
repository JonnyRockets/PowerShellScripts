function Update-Content{
<#
    .SYNOPSIS
        Insert text on a new line after the line matching the StartPattern or replace text between start- and end Pattern within a file
        
    .DESCRIPTION
		This is a function to insert new text within the body of a text file using regular expression replace substitution. 
		The insertion points are identified by the provided StartPattern and the optional EndPattern which can be normal strings or regular expressions.
		In case no EndPattern is provided the new text is appended on a new line after the line matching the StartPattern. 
		In case both patterns are provided the new text is inserted between the line matching the StartPattern and the EndPattern 
		replacing any existing text between the lines matching the patterns.
		
    .PARAMETER Path
        Path to the file to be updated
	
	.PARAMETER StartPattern
		pattern of the start line where the new Content is appended
	
	.PARAMETER EndPattern
		pattern of the end line where the new Content is inserted
		
	.PARAMETER Content
		text to be inserted
		
    .EXAMPLE  
		#replace text between the lines starting with "//start" and "//end"
		##text before:
		#some text
		#//start
		#text
		#text
		#//end
		
		Update-Content $Path "^//start" "^//end" "this is new stuff"
		
		##text afterwards:
		#some text
		#//start
		#this is new stuff
		#//end
        
    .EXAMPLE  
		#append text on a new line after the line starting with "//start"
		##text before:
		#some text
		#//start
		#text
		#text
	
		Update-Content $Path "^//start" "new text"
		
		##text before:
		#some text
		#//start
		#new text
		#text
		#text
	
#>
[CmdletBinding()] 
param(
	$Path,
	$StartPattern,
	$EndPattern,
	$Content
)
	if ($EndPattern){
		[regex]::Replace(([IO.File]::ReadAllText($Path)),"($StartPattern)([\s\S]*)($EndPattern)","`$1`n$Content`n`$3",[Text.RegularExpressions.RegexOptions]::Multiline) | 
			Set-Content $Path
	}
	else{
		#$& refers to the match when using replace
    	[regex]::Replace(([IO.File]::ReadAllText($Path)),"$StartPattern","$&`n$Content",[Text.RegularExpressions.RegexOptions]::Multiline) | 
			Set-Content $Path
	}
}
