<# 

.SYNOPSIS
	Purpose of this script to review the NTFS allocation size on all disks which are attached to Exchange servers.  WMI is used to query for the the volume information. 
    This allows it to query remote servers.  There is logic to loop through multiple Exchange servers, and all the disks attached to each server.  

    The output format to the CSV file will have one line per disk.  Each line will have the ServerName and the selected disk attributes.
    The CSV file can be easily opened, sorted and filtered in Excel.  
    
    Filters can be adjusted to suit the particular task that is required.  There are multiple examples here:
    http://blogs.technet.com/b/rmilne/archive/2014/03/24/powershell-filtering-examples.aspx

    An empty array is declared that will be used to hold the data gathered during each iteration. 
    This allows for the additional information to be easily added on, and then either echo it to the screen or export to a CSV file 

    A custom PSObject is used so that we can add data to it from various sources, Get-Mailbox, Get-MailboxStatistics, Get-ADUser etc.
    There is no limit to your creativity!  

    The CSV is created in the $PWD which is the Present Working Directory, i.e. where the script is saved

    Please refer to this post for details:
    https://blogs.technet.microsoft.com/rmilne/2017/07/21/script-to-check-exchange-ntfs-cluster-size/



.DESCRIPTION
	By default all disks attached to all Exchange servers will be reported upon.  This can be modified if required.  Edit the query if required.  

    The output format to the CSV file will have one line per disk.  Each line will have the ServerName and the selected disk attributes.
    The CSV file can be easily opened, sorted and filtered in Excel.  

    Replace this description with your own.  


.ASSUMPTIONS
	Script is being executed with sufficient permissions to access the server(s) targeted. 

	You can live with the Write-Host cmdlets :) 

	You can add your error handling if you need it.  

	

.VERSION
  
	1.0  29-05-2017 -- Initial script released to the scripting gallery 

    



This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, 
provided that You agree: 
(i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
This posting is provided "AS IS" with no warranties, and confers no rights. 

Use of included script samples are subject to the terms specified at http://www.microsoft.com/info/cpyright.htm.

#>


# Clean up screen 
Clear-Host

# Declare an empty array to hold the output
$Output = @()

# Declare a custom PS object. This is the template that will be copied multiple times. 
# This is used to allow easy manipulation of data from potentially different sources 
# Elements are arbitary names.  You can call them what you want.  Just use the name consistently.... 
$TemplateObject = New-Object PSObject | Select ServerName, DiskLabel, DiskBlockSize, DiskName 



#  
# Get a list of Exchange servers.  Sort this based on name to meet my OCD requirements...
# Can easily edit the query to tune Exchange 2010, 2013 etc... 
# This is an example for Exchange 2010
# $ExchangeServers = Get-ExchangeServer | Where-Object {$_.AdminDisplayVersion -match "^Version 14" -and $_.ServerRole -Match "ClientAccess" }  | Sort-Object  Name
#
# If required to review Exchange 2013 and 2016 servers: 
# $ExchangeServers = Get-ExchangeServer | Where-Object {$_.AdminDisplayVersion -match "^Version 15"} | Sort-Object  Name
# 
# In this case we will review all Exchange servers.  Again the filter can be modified to suit 
# For more filtering examples see: 
# http://blogs.technet.com/b/rmilne/archive/2014/03/24/powershell-filtering-examples.aspx 
#
$ExchangeServers = Get-ExchangeServer  | Sort-Object  Name



# Define the WQL query string which will be used 
$WMIQueryString = "SELECT Label, Blocksize, Name FROM Win32_Volume WHERE FileSystem='NTFS'" 



# Loop me baby! 
ForEach ($Server In $ExchangeServers)
{
	
    Write-Host "Processing Server: $Server" -ForegroundColor Magenta
	
    # Get a list of all disks on the current server.  Save this in the variable $ServerDisks and only take the label, BlockSize and Name attributes  
    $ServerDisks = Get-WmiObject -Query $WMIQueryString  -ComputerName $Server.Name | Select-Object Label, Blocksize, Name


    # Loop thorough all disks in the current server, and add this to the output 
    ForEach ($Disk IN $ServerDisks)
    { 

	    # Make a copy of the TemplateObject.  Then work with the copy...
    	$WorkingObject = $TemplateObject | Select-Object * 
	
    	# Populate the TemplateObject with the necessary details.
    	$WorkingObject.ServerName	 = $Server.name
    	$WorkingObject.DiskName	 	 = $Disk.Name 
    	$WorkingObject.DiskLabel 	 = $Disk.Label 
    	$WorkingObject.DiskBlockSize = $Disk.BlockSize  


    	# Display output to screen.  REM out if not reqired/wanted 
    	$WorkingObject

    	# Append  current results to final output
    	$Output += $WorkingObject


    }


    Write-Host 

}    

# Script is done looping at this point.  
# We can do something with the $Output.  

# Echo the compiled output to screen if desired.  Unrem the below command to make it so.
# $Output

# Or output to  below is an example of going to a  CSV file
# The Output.csv file is located in the same folder as the script.  This is the $PWD or Present Working Directory. 
$Output | Export-Csv -Path $PWD\Output.csv -NoTypeInformation 