param (
    [string]$DomainName = "jcmh.loc"
)

# WuFB (Intune Managed Updates) conflicting registry key paths
$KeyPaths = @(
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\NoAutoUpdate",
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\WUServer",
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\DoNotConnectToWindowsUpdateInternetLocations",
    "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\DisableDualScan"
)
$Conflicts = @()

function Show-GpoUpdateConflicts() {
    Write-Host "Starting conflict checks for WuFB (Intune Managed Updates)..."

    foreach ($KeyPath in $KeyPaths) {
        # Check the registry keys for conflicts with WuFB
        try {
            $RegistryValue = Get-ItemProperty -Path $KeyPath -ErrorAction Stop
            if ($RegistryValue) {
                # Add the detected conflict to the Conflicts array
                $Conflicts += [PSCustomObject]@{
                    KeyPath = $KeyPath
                    Value   = $RegistryValue
                }
            }
        } catch {
            # Write OK to the console if the registry key does not exist.
            Write-Host "[OK] No registry key found at path: $KeyPath"
        }
    }

    # If any conflicts are detected, output the details of the conflicts.
    if ($Conflicts.Count -gt 0) {
        Write-Host "[ERROR] WuFB conflicts detected. Please review and migrate the GPO managed update policies listed above." `
        -ForegroundColor Red `
        -BackgroundColor Black
        
        foreach ($Conflict in $Conflicts) {
            Write-Host "Conflicting Policy: $($Conflict.KeyPath)"
            Write-Host "Value: $($Conflict.Value)"
        }
    }
    else {
        Write-Host "[SUCCESS] Common WuFB checks passed." -ForegroundColor Green -BackgroundColor White
    }
}

Show-GpoUpdateConflicts