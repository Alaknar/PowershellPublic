function Send-PasswordExpiryEmail {
  <#
  .SYNOPSIS
  Gathers a list of AD accounts whose passwords are near expiry (14 days) and sends an email notification to them.

  .DESCRIPTION
  Gets a list of all accounts from a specified OU that are not already disabled and their PasswordNeverExpires is set to $False.
  Filters out two groups - accounts whose passwords will expire in 14 days and those that will expire in 7 or less days.
  The first group receives an email once. The second group will receive an email daily.

  .EXAMPLE
  Send-PasswordExpirationEmail -WhatIf
  What if: Performing the operation "Send-MailMessage" on target "John.Doe@domain.com - password expires on 14/02/2018 17:12:59".
  What if: Performing the operation "Send-MailMessage" on target "Jane.Doe@domain.com - password expires on 14/02/2018 09:12:17".

  .NOTES
  By Alaknár
  #>
  [cmdletbinding(SupportsShouldProcess=$True)]
  Param()

  $date = Get-Date
  Write-Verbose 'The date is $date'

  # GET A LIST OF ALL NOT-EXPIRED USERS WITH EXPIRING PASSWORDS
  Write-Verbose 'Gathering all not-expired users whose passwords are set to expire'
  $properties = "GivenName","Surname","SamAccountName","msDS-UserPasswordExpiryTimeComputed","EmailAddress"
  $searchBase = 'OU=Users,OU=Stuff,DC=domain,DC=com'
  $allUsers = Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -Properties $properties -SearchBase $searchBase | Select-Object -Property "GivenName","Surname","SamAccountName","EmailAddress",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}
  Write-Verbose 'Done'

  # FILTERS, FILTERS
  ## List of users whose passwords will expire in two weeks
  $users14 = $allUsers | Where-Object {$_.ExpiryDate.AddDays(-14).Date -eq $date.Date}

  ## List of users whose passwords will expire in less than 8 days
  $users7 = $allUsers | Where-Object {$_.ExpiryDate.AddDays(-7).Date -le $date.Date -and $_.ExpiryDate.Date -gt $date.Date}

  $usersToBeEmailed = @()
  $usersToBeEmailed += $users14
  $usersToBeEmailed += $users7

  # SPECIFY SENDER DETAILS
  $mailFrom = #sender.mail@domain.com
  $mailSubject = 'Your password will expire soon'
  $mailSmtpServer = #smtp.domain.com

  Write-Verbose 'ForEach loop start'
  ForEach ($user in $usersToBeEmailed) {
    $userName = ($user.GivenName).ToString()
    $userPassExpiryDate = ($user.ExpiryDate).ToString('dd-MMM-yyyy')
    
    $mailTo = $user.EmailAddress
    $mailBody = Get-Content #Put the path to your HTML template here. In the template use {0} and {1} and for the variables passed. Or was it {1} and {2}? Can't remember, it's been a while.

    # SEND THE EMAIL
    ## I know Send-MailMessage is obsolete, but it wasn't when I wrote that and since it's all internal comms, I don't think it's that big of a deal. Let me know if you now a better, more up to date method.
    If ($PSCmdlet.ShouldProcess("$mailTo - password expires on $userPassExpiryDate","Send-MailMessage")){
      Send-MailMessage -BodyAsHtml ($mailBody -f $userName, $userPassExpiryDate) -To $mailTo -From $mailFrom -Subject $mailSubject -SmtpServer $mailSmtpServer
    }
}
  Write-Verbose 'ForEach loop stop'
}

Send-PasswordExpiryEmail