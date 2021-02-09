# PowershellPublic

This is gonna be mostly empty, but this is my repository of functions I feel might be worth sharing.

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

