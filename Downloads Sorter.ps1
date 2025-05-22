
$downloadsFolder = "$($HOME)\Downloads"
$logFile = "$downloadsFolder\MoverLogFile.txt"
if (-not (Test-Path $logFile)){
    New-Item -Path $logFile -ItemType File | Out-Null
    Add-Content -Path $logFile -Value "Created log file on $(Get-Date)"
}

$allItems = Get-ChildItem -Path $downloadsFolder -File 

foreach ($file in $allItems){
    write-Host "Current file is $($file.Name)"
    $extension = if ($file.Extension) {
        $file.Extension.TrimStart(".").ToUpper()
    } else {
        continue
    }

    if ($file.Name -eq "MoverLogFile.txt"){
        continue
    }

    $extensionDirectory = "$downloadsFolder\All $($extension) files"
    if (-not (Test-Path $extensionDirectory)){
        New-Item -Path $extensionDirectory -ItemType Directory
    }

    $destinationPath = "$($extensionDirectory)\$($file.Name)"
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $ext = $file.Extension
    $counter = 1
    while (Test-Path $destinationPath){
        $newFileName = "$baseName($counter)$($ext)"
        $destinationPath = "$($extensionDirectory)\$($newFileName)"
        $counter ++
    }

    try {
        Move-Item -Path $file.FullName -Destination $destinationPath -ErrorAction Stop
        Add-Content -Path $logFile -Value "$(Get-Date) - Moved file '$($file.Name)' to '$destinationPath'"
    } catch {
        Add-Content -Path $logFile -Value "$(Get-Date) - ERROR moving '$($file.Name)': $_"
    }
}
