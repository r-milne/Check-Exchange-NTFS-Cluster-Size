# Check Exchange NTFS Cluster Size
 Check Exchange NTFS Cluster Size
 
 
.SYNOPSIS

Purpose of this script to review the NTFS allocation size on all disks which are attached to Exchange servers.  WMI is used to query for the the volume information.
This allows it to query remote servers.  There is logic to loop through multiple Exchange servers, and all the disks attached to each server. 

 

 

The output format to the CSV file will have one line per disk.  Each line will have the ServerName and the selected disk attributes.
The CSV file can be easily opened, sorted and filtered in Excel. 
   
Filters can be adjusted to suit the particular task that is required.  There are multiple examples here:
https://blog.rmilne.ca/2014/03/24/exchange-powershell-filtering-examples/

An empty array is declared that will be used to hold the data gathered during each iteration.
This allows for the additional information to be easily added on, and then either echo it to the screen or export to a CSV file
A custom PSObject is used so that we can add data to it from various sources, Get-Mailbox, Get-MailboxStatistics, Get-ADUser etc.
There is no limit to your creativity! 
The CSV is created in the $PWD which is the Present Working Directory, i.e. where the script is saved.  
Please refer to this post for additional details:

https://blog.rmilne.ca/2014/03/24/exchange-powershell-filtering-examples/

 

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
