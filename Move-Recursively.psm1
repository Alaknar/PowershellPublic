function Move-Recursively {

$OrgPath = Read-host "Enter Source Path"
$NewPath = Read-host "Enter Destination Folder"
$FileType = Read-host "Provide the file type (e.g. '.mp3'). Include the fullstop"
$files = get-childitem -recurse -file | Where-Object {$_.extension -match "$filetype"}

Foreach($file In $files)
    {
        $Directory = ($file.fullname.split("\")[0..($file.fullname.split("\").count -2)] -join "\").replace("$OrgPath","$NewPath")
        if((Test-path -path $Directory) -eq $False)
        {
            new-item $Directory -type directory
        }
        Move-Item -path $File.fullname -destination $directory
    }
}