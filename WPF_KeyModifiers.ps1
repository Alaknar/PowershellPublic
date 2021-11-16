<#
Found on Stackoverflow, made by "Stephan":
https://stackoverflow.com/questions/62743526/wpf-keyboard-and-mouse-click-at-the-same-time

My modification: added the `$global:ctrl = $false` bit to all button-press actions to reset the key-press state. 
Otherwise Ctrl+Clicking while showing an external window would lock the Ctrl key as pressed.
#>

$title = "test"

Add-Type -AssemblyName PresentationFramework

# GUI
[xml]$xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="Window_GuiManagement" Title="$title" WindowStartupLocation = "CenterScreen" 
        Width = "Auto" Height = "350.000" Visibility="Visible" WindowStyle="ToolWindow" ResizeMode="NoResize" SizeToContent="WidthAndHeight" >
    <Grid>
        <DockPanel Margin="5">
            <StackPanel DockPanel.Dock="Bottom" >
                <Button Name="button_1" Content="Button 1" />
                <Button Name="button_2" Content="Button 2"  />
            </StackPanel>
        </DockPanel>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Declare objects
$button_1 = $window.FindName("button_1")
$button_2 = $window.FindName("button_2")


$global:ctrl = $false

$button_1.Add_Click({ Write-Host "Button 1 clicked" })

$button_2.Add_Click({
        if($global:ctrl){
            Write-Host "do more" $ctrl
            $global:ctrl = $false   #not necessary here as this only sends input into console, but if external windows are showing, Ctrl's state will lock. Have to clear it.
        } else {
            Write-Host "do standard" $ctrl
            $global:ctrl = $false   #not necessary here as this only sends input into console, but if external windows are showing, Ctrl's state will lock. Have to clear it.
        }
})

$window.add_KeyDown{
    param
    (
      [Parameter(Mandatory)][Object]$sender,
      [Parameter(Mandatory)][Windows.Input.KeyEventArgs]$e
    )
    #Write-Host $e.Key
    if($e.Key -eq "LeftCtrl")
    {
        return ($global:ctrl = $true)
    }
}

$window.add_KeyUp{
    param
    (
      [Parameter(Mandatory)][Object]$sender,
      [Parameter(Mandatory)][Windows.Input.KeyEventArgs]$e
    )
    #Write-Host $e.Key
    if($e.Key -eq "LeftCtrl")
    {
        return ($global:ctrl = $false)
    }
}

$Window.ShowDialog() | Out-Null
