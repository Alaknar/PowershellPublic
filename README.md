# PowershellPublic

Tthis is my repository of functions I feel might be worth sharing.

Please let me know if find stupid things or just feel like something could be done better.

## Write-Log
Writes a message with a timestamp to a log file while also being able to display it as a Verbose Message in the console.
### Description
`Write-Log` is an easy to use tool to writing log files. Any text received will receive a timestamp, formatting (according to the chosen options) and then will be added to a chosen log file.
The log file will be created automatically if it doesn't exist.

Note: no naming convention checks are being performed so make sure you remember about setting the file name correctly and with an extension.

Non-powershell commands (e.g. `dir` or `tsm`) can be also used with Write-Log. Test it beforehand and remember to redirect stderr to stdout (see example 2).

### Formatting

Write-Log allows for three formatting options for any message.

<ins>Normal</ins>

```
"$time"+": "+"$Message"`
```

<ins>Emphasis</ins>

```
"$time"+" === "+"$Message"+" ==="
```

<ins>Header</ins>

```
"`n === "+"$Message"+" === "+$time+" ==="
```

<ins>Ending the log</ins>

You can also end the log with `-Message "EndLog"` which adds the following line:
```
"`n`n ==== LOG FILE ENDED on $time ===="
```

## Get-PCSpecs

Displays the specs of the machine it's run on.

### Example

```powershell
> Get-PCSpecs

HARDWARE:

MoBo : ASUSTeK COMPUTER INC. H97-PRO
CPU  : CPU0 | Intel(R) Core(TM) i7-4790 CPU @ 3.60GHz
GPU  : NVIDIA GeForce RTX 2060 | 4GB | Driver version: 30.0.14.9649 (published date: 10/20/2021 02:00:00)
RAM  : 32GB in 4 sticks


MONITORS:

Serial        Manufacturer Name
------        ------------ ----
XXXXXX        DEL          DELL U2xxxHM
XXXXXX        IVM          xx2xxxQ

STORAGE:

DeviceID VolumeName TotalSize FreeSpaceGB
-------- ---------- --------- -----------
C:       SYSTEM     249 GB    107 GB
D:       xxxxxx     233 GB    164 GB
E:       yyyyyy     224 GB    61 GB
G:       zzzzzz     682 GB    56 GB

```

### Note

Might throw errors on laptops as it seems at least some of them have the UserFriendlyName value blank. Will pull all the other data just fine, though.

## Send-PasswordExpiryEmail

Gets a list of all accounts from a specified OU that are not already disabled and their `PasswordNeverExpires` is set to `$False`.

Filters out two groups - accounts whose passwords will expire in 14 days and those that will expire in 7 or less days.

The first group receives an email once. The second group will receive an email daily.

## Move-Recursively

Recursively moves files of a designated type between locations. I'm pretty sure I found this script online, but no clue where or who from...

`$OrgPath` is the source path.

`$NewPath` is the destination path.

`$FileType` is the file type (e.g. '.mp3'). Include the fullstop.

## Find-UninstallString

Looks through the Uninstall keys in the Registry (both standard and Wow6432Node) and returns all elements that match the provided string.

### Example

```powershell
> Find-UninstallString git

DisplayName UninstallString                     DisplayVersion
----------- ---------------                     --------------
Git         "C:\Program Files\Git\unins000.exe" 2.37.1
```

## Install-MicroTextEditor

Downloads the latest version of the [Micro Text Editor](https://github.com/zyedidia/micro/blob/master/README.md) to C:\Temp, unpacks the zip and copies `micro.exe` to `$env:WinDir`.

Admin rights needed. The C:\Temp folder must exist prior to running the script.