
#USE: 
#   open powershell
#  run . .\parse-logfile.ps1 
#  the function Parse-LogFile will be available to run, just supply the parameters required. 
#  an example of the parameters to supply is below under .EXAMPLES

#12/19/2017
#Public Domain
#AIC - arrayltd.net
#Powershell 5.


#hash is for storing key = date, value = array of log entries. Stores them by date for counting later.
Function BuildHash($hash, $date, $item){

    $logarray = $hash.get_item($date)
    $logarray += , $item
    $hash.set_item($date, $logarray)
    return $hash

}


function Get-CountUniqueValuesInLogEntries([array]$file, [string]$delimiter, [int]$element, [int]$SubstrStart, [int]$SubstrEnd){
      
       $LogArray =@()
       $LogArrayFullLines = @()
       if($substrend -eq "-1"){
            $substrend = $tokenize[$element].length
            
       }   
              
        foreach ($f in $file){
           
           $tokenize = $f.split($delimiter)
          
          
        $linecheck =  $tokenize[$element].substring($substrstart, $substrend)
     
        
        #put the mac in the array $logarray if it doesn't already exist
        if ($logarray -notcontains $linecheck){
            $logarray += $linecheck
            $LogArrayFullLines += $f   
          
          
            
        }
      
        }
   return  $logarrayfulllines
      
   
      
      
}


function Parse-LogFile{

<# 
    .SYNOPSIS 
   Parse logs by searching for a string. Send email with found entries, count of found entries, and first and last entries.
    .DESCRIPTION 
    Reads a single log file and selects entries based on supplied parameters.
    
    .EXAMPLE 
    
   
   Displaying full log output from 365 days ago through today. Remove -testing switch to send results via email
   Parse-LogFile -startday 365 -endday 0  -smtpserver smtp.gmail.com -username user@gmail.com -password "password" -recipient recipient@gmail.com -sender user@gmail.com -subject "Log file for Server" -logpath "C:\Users\Administrator\Downloads\12-10-library" -logname "server*.log" -fieldtofind "authorized by no authentication" -delimiter ' ' -element 9 -substrstart 6 -substrend 17 -briefLinesCounted "sessions" -briefElementDescription "devices"  -testing $true  -log_title_to_display "Connected Devices Report" -display_current_datetime $true -fulloutput $true -log_to_select_by_date 0 -display_all_messages $true -display_unique_count $true -display_unique_lines $true -display_total_count $true -display_first_and_last_entry $true -date_element_in_entry_array 0 -date_begin_substring_of_element 1 -date_end_substring_of_element 10
   


    #>



Param(
 
 [Parameter(Mandatory=$true,
            HelpMessage="Number of days to subtract from current date. This will the the day the log is filtered on. 0 for today, 1 for yesterday, ...")]
            [string]$StartDay,
 [Parameter(Mandatory=$true,
            HelpMessage="SMTP Server Address")]
            [string]$smtpserver,
 [Parameter(Mandatory=$true,
            HelpMessage="SMTP Username.")]
            [string]$username,
 [Parameter(Mandatory=$true,
            HelpMessage="SMTP password.")]
            [string]$password,
 [Parameter(Mandatory=$true,
            HelpMessage="SMTP recipient")]
            [string]$recipient,
 [Parameter(Mandatory=$true,
            HelpMessage="SMTP Sender to display. Usually the same as SMTP username.")]
            [string]$sender,
 [Parameter(Mandatory=$true,
            HelpMessage="Email Subject.")]
            [string]$subject,

 
 [Parameter(
            HelpMessage="The element of the log entry to select for selecting the date")]
            [int]$date_element_in_entry_array,
            
 [Parameter(
            HelpMessage="Within date_element_in_entry_array, this integer defines the beginning character of the substring to get the date, 
            Which should be in a form that powershell can convert to a datetime object")]
            [string]$date_begin_substring_of_element,
            
 [Parameter(
            HelpMessage="This integer is the ending character place of the substring to select the date from the log. Default is empty which will
            cause the substring to extend to the end of the element")]
            [string]$date_end_substring_of_element,

 [Parameter(
            HelpMessage="SMTP Port.")]
            [string]$smtpport = 587,

 [Parameter(Mandatory=$true,
            HelpMessage="The folder in which the log resides")]
            [string]$logpath,

 [Parameter(Mandatory=$true,
            HelpMessage="The name of the log. Example: server*.log")]
            [string]$logname,

 [Parameter(
            HelpMessage="Display all selected log messages in email body.")]
            [string]$display_all_messages = $true,

 [Parameter(
            HelpMessage="Display first and last selected log entries in email body")]
            [string]$display_first_and_last_entry = $true,

 [Parameter(
            HelpMessage="Display total count of selected log entries in the email body.")]
            [string]$display_total_count = $true,
 [Parameter(
            HelpMessage="Display total count of selected log entries in the email body.")]
            [string]$fulloutput = $false,
 [Parameter(Mandatory=$true,
            HelpMessage="The string to search for in the log entry.")]
            [string]$fieldtofind,
 [Parameter(
            HelpMessage="The delimiter to use when searching for unique.")]
            [string]$delimiter,
 [Parameter(
            HelpMessage="The element of the tokenized log string to select for uniqueness.")]
            [string]$element,
 [Parameter(
            HelpMessage="Used to select start of a substring of Element parameter.")]
            [string]$SubstrStart = 0,
 [Parameter(
            HelpMessage="Used to select stop of a substring of Element parameter.")]
            [string]$SubstrEnd = -1,
             [Parameter(
            HelpMessage="Display unique log values?.")]
            [string]$display_unique_lines = $false,
[Parameter(
            HelpMessage="Display unique values count?.")]
            [string]$display_unique_count = $false,
[Parameter(
            HelpMessage="Switch to disable email and just output to the console")]
            [string]$testing = $false,
[Parameter(
            HelpMessage="This will output a one line summary instead of all the log details")]
            [string]$briefoutput = $false,
[Parameter(
            HelpMessage="When true this will show the brief output fo reach date in the date range")]
            [string]$briefexpandedoutput = $false,
            
[Parameter(
            HelpMessage="When using brief output option, this will determine what word goes in place of sessions here: On 12/15/2016, there were 0 sessions logged, across 0 unique devices.")]
            [string]$briefLinesCounted,
[Parameter(
            HelpMessage="When using brief output option, this will determine what word goes in place of devices here: On 12/15/2016, there were 0 sessions logged, across 0 unique devices.")]
            [string]$briefElementDescription,
[Parameter(
            HelpMessage="Display Current Time?")]
            [string]$display_current_datetime,
[Parameter(
            HelpMessage="The title to display in the body of the email")]
            [string]$log_title_to_display,
[Parameter(
            HelpMessage="If you want a log in the past, you can specify an integer value. 0 is the current log. 1 is the next oldest log.
            Selecting a number that exceeds the number of available logs -1 you will get an error. Logs are sorted by LastWriteTime")]
            [string]$log_to_select_by_date = 0,
            
[Parameter(
            HelpMessage="Set end day to filter on. 0 is today, 1 is yesterday, etc...")]
            [string]$EndDay
	    	    
	     
 )



#Mail Server credential variables
$secstr = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr


#Select most recent log file.
$logfilename = (Get-ChildItem -path $logpath\$logname |sort LastWriteTime)[$log_to_select_by_date]


#Add each line of the log as a string to a new element of an array
$filenotfound =""

try{$logfile = get-content "$logfilename" -ErrorAction SilentlyContinue}
catch{$filenotfound = $true}

#initialize array to store the output
$selectedlines = @()

#initialize hash table to store logs by date for briefexpanded output
$log_ht = @{}

#loop through logfile and add any elements found to $selectedlines array

foreach ($line in $logfile){
    if($line.Contains("$fieldtofind")){
        $Date = $line.split(" ")
        
        $DateInLogPosition = $date[$($date_element_in_entry_array)]
        
        $DateinLogSubstring = $DateInLogPosition.Substring($($date_begin_substring_of_element),$($date_end_substring_of_element))
        
        $dateinlog = [datetime]$DateinLogSubstring
        $StartDate = ($(get-date).date.adddays(-$StartDay))
       
        
        if($endday -ne ""){
            $EndDate = ($(get-date).date.adddays(-$EndDay +1).AddSeconds(-1))
        }
        
        else{
            $EndDate = $StartDate
        }
        
        
        if(($dateinlog -ge $startdate) -and ($dateinlog -le $endDate) ){
           $selectedlines += $line
           $log_ht = buildhash $log_ht $dateinlog $line
          
           

        } 
        
   }
}



#build the email message


if($filenotfound){
    $body += "Unable to open log." + "`r`n`r`n"
    $body += "Details: Error opening log. Log might not exist." + "`r`n`r`n"
    $subject += ": Unable to open log"
    
    }
   
if(!$filenotfound){
    $StartDateDisplay = $($startdate.date).tostring("MM/dd/yyyy")
    $EndDateDisplay = $($enddate.date).tostring("MM/dd/yyyy")
    [string]$EndDateDisplayForBriefBody = " through " + " $EndDateDisplay"

    #Get Total number of Unique log entries
    $uniquelines = Get-CountUniqueValuesInLogEntries $selectedlines $delimiter $element $substrstart $substrend
    $uniquecount = $uniquelines.count
    
    #display log title
    if($log_title_to_display -ne ""){
        $body += "$($log_title_to_display)" +
        "`r`n`r`n"
    }
    
    #display current time
    if($display_current_datetime -eq $true) {
       $now = (get-date)
       $body += "Current Date: $($now)" +
       "`r`n`r`n"
    }
  
    #display Date selected / Date Range selected
    if($startdate -eq $enddate){
        [string]$body += "Date Selected: $startDateDisplay" + "`r`n`r`n"
    }
    
    if($startdate -ne $enddate){
        [string]$body += "Date Range Selected: $StartDateDisplay"  +  " through " + "$EndDateDisplay" + "`r`n`r`n"
    }
  
    if($briefoutput -eq $true){
        $body = "On $StartDateDisplay" + (&{If(($EndDatedisplay -eq "") -or($startdate -eq $enddate)) {("")} Else {"$EndDateDisplayforbriefBody"}}) + 
             ", there were" +
             " $(($selectedlines).count) $briefLinesCounted logged" + 
             ", across $uniquecount unique $briefElementDescription" +
             "."
    }

    if($briefexpandedoutput -eq $true){
         $body += "Brief output expanded to show each day in range: " + "`r`n`r`n"
         foreach($kvp in $log_ht.getenumerator()){
            $body += "On $(([datetime]$kvp.key).toString("MM/dd/yyyy"))" + 
            ", there were" + 
            " $($kvp.value.count) $briefLinesCounted logged" +
            ", across $((Get-CountUniqueValuesInLogEntries $kvp.value $delimiter $element $substrstart $substrend).count) unique $briefElementDescription" +
            "." +
            "`r`n"
            
            
         } 
         $body += "`r`n"
    }


    if($fulloutput -eq $true){


    
        [string]$body += "Log file: " + [string]$logfilename + "`r`n`r`n"
    

        if($display_total_count -eq $true){
            $body += "Total number of filtered entries from log / total entries in log : $($selectedlines.count) / $($logfile.count)" + "`r`n`r`n" 
        }
    
        if($display_unique_count -eq $true){
    	    $body += "Total number of unique filtered entries from log: $uniquecount"  + "`r`n`r`n"
        }
        
        if($display_first_and_last_entry -eq $true){
            $body += "Most recent Log entry: " + $selectedlines[0] + "`r`n"
            $body += "Oldest Log entry:      " + $selectedlines[-1] +  "`r`n`r`n"
        }
    
        if($display_unique_lines -eq $true){
            #call the function to get the unique values, as opposed to all the values.

            $uniquelines = Get-CountUniqueValuesInLogEntries $selectedlines $delimiter $element $substrstart $substrend
            $uniquecount = $uniquelines.count
            $body += "Unique Messages:" + "`r`n`r`n"
            foreach($line in $uniquelines){
                $body += $line + "`r`n"
            }
            $body += "`r`n"
        }

        if($display_all_messages -eq $true){
            $body += "All Log Messages:" + "`r`n`r`n"
    
            foreach($line in $selectedlines){
                $body += $line + "`r`n"
            }
            
            $body += "`r`n"
        }
    }
}



#send the email message or output to console
if($testing -eq $false){
    Send-MailMessage -from $sender -to $recipient -smtpserver $smtpserver -port $smtpport -subject $subject -body $body  -Credential $cred -UseSsl -Verbose
}
if($testing -eq $true){
    $body


    

  
}

#cleanup
$logfile = ""
$body = ""
$subject = ""
$startday = ""
$endday = ""
$endDateStr = ""
$EndDateDisplay = ""



   
}
