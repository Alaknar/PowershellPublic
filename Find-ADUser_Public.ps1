function Find-ADUser {

    <#
    .SYNOPSIS
        Returns some of the most often used account details.
    .DESCRIPTION
        Find users in AD by inputing Name, UPN or SamAccountName to return a list of most usefull account details.
        
        == L2UsernameInAD ==
        Value taken frmo the AD parameter 'extensionAttribute9'.
    
        == msRTCSIP-OptionFlags ==
        The msRTCSIP-OptionFlags value is calculated using this switch:
                SWITCH ($UserObject.msRTCSIPOptionFlags) {
                "385" { $phoneSystem = $UserObject.msRTCSIPOptionFlags.ToString()+" (Enterprise Voice)" }
                "257" { $phoneSystem = $UserObject.msRTCSIPOptionFlags.ToString()+" (Other Telephony System)" }
                Default {}
            }
        
        == AccountLocked ==
        Value taken from the AD parameter 'LockedOut'.
    
        == AccountEnabled ==
        Value taken from the AD parameter 'Enabled'.
    
        == StartDate ==
        Value taken frmo the AD parameter 'extensionAttribute2'.
    .PARAMETER SearchString
        
        Accepts any string and will try matching using LDAPfilter as long as ExactSearch isn't selected. Can return multiple results.
    .PARAMETER ExactSearch
        Tries matching the SearchString to 'samAccountName'. If failed, tries matching 'Name'. Mostly used to remove '-1' accounts from results.
    .PARAMETER AllProperties
        Will display all AD properties EXCLUDING 'jpegPhoto'.
    .EXAMPLE
        Find-ADUser
    
        cmdlet Find-ADUser at command pipeline position 1
        Supply values for the following parameters:
        SearchString: jdoe
        Multiple users found
    
        GivenName Surname   SamAccountName Name              EmailAddress             PasswordLastSet     Enabled PasswordExpir
                                                                                                                            ed
        --------- -------   -------------- ----              ------------             ---------------     ------- -------------
        John      Doe       jdoe           John Doe          John.Doe@Contoso.com     2020-04-29 10:55:27    True         False
        Jane      Doe       jdoe1          Jane Doe          Jane.Doe@Contoso.com     2020-07-05 19:00:49    True         False
    
        Type in just the function name and you will be prompted to provide the User Name (default parameter).
    .EXAMPLE
       Find-ADUser zabrzea -exactSearch
    
        Name                 : John Doe
        WorkdayName          : John Doe
        UserPrincipalName    : John.Doe@Contoso.com
        SamAccountName       : jdoe
        Title                : Totally Not Getting Shafted
        L2UsernameInAD       :
        EmployeeNumber       : #####
        Description          : Handome
        AccountEnabled       : True
        PasswordLastSetDate  : 2020-04-29 10:55
        PasswordState        : Password expires in: 30 days (2020-10-28 10:55)
        EmailAddress         : John.Doe@Contoso.com (Online)
        AccountLocked        : False
        OfficePhone          : #####
        msRTCSIP-OptionFlags : 385 (Enterprise Voice)
        Company              : Contoso
        Office               : California
        CanonicalName        : contoso.local/Contoso/Contoso Users/John Doe
        StartDate            : 1900-08-01
    
        Using the '-exactSearch' switch will prevent multiple results from showing.
    .NOTES
        Author: Andrzej Zabrzeski
        Last Change: 2021-01-11
        Version 2.5
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$SearchString,
        [Parameter(Mandatory = $false)]
        [Switch]$allProperties,
        [Parameter(Mandatory = $false)]
        [Switch]$exactSearch
    )

    switch ($allProperties.IsPresent) {
        $true {
            switch ($exactSearch.IsPresent) {
                $true { 
                    TRY {
                        Get-ADUser $SearchString -Properties * | Select-Object -Property * -ExcludeProperty jpegPhoto
                    }
                    CATCH {
                        Get-ADUser -Filter { Name -like $SearchString } -Properties * | Select-Object -Property * -ExcludeProperty jpegPhoto
                    } 
                }
                Default {
                    Get-ADUser -LDAPFilter "(anr=$SearchString)" -Properties * | Select-Object -Property * -ExcludeProperty jpegPhoto
                }
            }
        }
        Default {
            $MaxPasswordAgePolicy = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days
            
            $properties = "GivenName", "Surname", "SamAccountName", "Name", "EmailAddress", "PasswordLastSet", "Enabled", "PasswordExpired", "LockedOut", "OfficePhone", "Office", "CanonicalName", "UserPrincipalName", "EmployeeNumber", "Description", "Manager", "Title", "Department", "Company", "employeeType", "extensionAttribute9", "msRTCSIP-OptionFlags", "homeMDB", "extensionAttribute2", "AccountExpirationDate"
            $selectedProperties = "GivenName", "Surname", "SamAccountName", "Name", "EmailAddress", "PasswordLastSet", "Enabled", "PasswordExpired", "LockedOut", "OfficePhone", "Office", "CanonicalName", "UserPrincipalName", "EmployeeNumber", "Description", "Manager", "Title", "Department", "Company", "employeeType", "extensionAttribute9", @{Name = "msRTCSIPOptionFlags"; Expression = { $_."msRTCSIP-OptionFlags" } }, "homeMDB", "extensionAttribute2", "AccountExpirationDate"
            $UserObject = `
                switch ($exactSearch.IsPresent) {
                $true { 
                    TRY {
                        Get-ADUser $SearchString -Properties $properties | Select-Object -Property $selectedProperties
                    }
                    CATCH {
                        Get-ADUser -Filter { Name -like $SearchString } -Properties $properties | Select-Object -Property $selectedProperties
                    }
                }
                Default {
                    Get-ADUser -LDAPFilter "(anr=$SearchString)" -Properties $properties | Select-Object -Property $selectedProperties
                }
            }
        
            IF ($null -eq $UserObject) {
                Write-Host "No user found, please doublecheck the search query" -ForegroundColor Red -BackgroundColor Black
                BREAK
            }
        
            IF ($UserObject.count -gt 1) {
                Write-Host "Multiple users found"
                $UserObject | Select-Object $properties | Format-Table -AutoSize
            }
            ELSE {
                ##Password expiry check
                $today = Get-Date
        
                $PassExpiryDate = ($UserObject.PasswordLastSet.AddDays($MaxPasswordAgePolicy))
                $PassExpiresIn = (New-TimeSpan -start $today -end $PassExpiryDate).Days
                $PassExpiryDateFormatted = $PassExpiryDate.ToString("yyyy-MM-dd HH:mm")
                IF ($UserObject.PasswordExpired -eq $false) {
                    $PassState = "Password expires in: $PassExpiresIn days ($PassExpiryDateFormatted)"
                }
                ELSE {
                    $PassState = "Password expired"
                }

                ##Office online vs on-prem check
                IF ($null -eq $UserObject.homeMDB) {
                    $exchangeState = "Online"
                }
                ELSE {
                    $exchangeState = "On-prem"
                }

                SWITCH ($UserObject.msRTCSIPOptionFlags) {
                    "385" { $phoneSystem = $UserObject.msRTCSIPOptionFlags.ToString() + " (Enterprise Voice)" }
                    "257" { $phoneSystem = $UserObject.msRTCSIPOptionFlags.ToString() + " (Avaya)" }
                    Default {}
                }

                $Manager = ((Get-ADUser $UserObject.SamAccountName -Properties Manager).Manager | Get-ADUser).Name
                
                $obj_UserPropertiesOutput = [ordered]@{
                    Name                   = $UserObject.Name;
                    WorkdayName            = $UserObject.GivenName + " " + $UserObject.Surname;
                    UserPrincipalName      = $UserObject.UserPrincipalName;
                    EmailAddress           = $UserObject.EmailAddress + " (" + $exchangeState + ")";
                    SamAccountName         = $UserObject.SamAccountName;
                    L2UsernameInAD         = $UserObject.extensionAttribute9;
                    EmployeeNumber         = $UserObject.EmployeeNumber;
                    Title                  = $UserObject.Title;
                    Description            = $UserObject.Description;
                    Department             = $UserObject.Department;
                    Company                = $UserObject.Company;
                    Manager                = $Manager;
                    EmployeeType           = $UserObject.employeeType
                    AccountEnabled         = $UserObject.Enabled;
                    AccountLocked          = $UserObject.LockedOut;
                    PasswordLastSetDate    = '{0:yyyy-MM-dd HH:mm}' -f $UserObject.PasswordLastSet; 
                    PasswordState          = $PassState
                    OfficePhone            = $UserObject.OfficePhone;
                    "msRTCSIP-OptionFlags" = $phoneSystem;
                    Office                 = $UserObject.Office;
                    StartDate              = $UserObject.extensionAttribute2;
                    AccountExpirationDate  = $UserObject.AccountExpirationDate;
                    CanonicalName          = $UserObject.CanonicalName
                }
        
                New-Object PSObject -Property $obj_UserPropertiesOutput
        
                $SearchString = $null
                $UserObject = $null
            }
        }
    }
}
