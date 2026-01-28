Write-Host "Checking Hive Files After Fix..." -ForegroundColor Green

$hivePath = "$env:USERPROFILE\Documents\hive_data"
Write-Host "Hive Path: $hivePath"

if (Test-Path $hivePath) {
    Write-Host "SUCCESS: Hive directory exists!" -ForegroundColor Green
    
    $files = Get-ChildItem -Path $hivePath -ErrorAction SilentlyContinue
    Write-Host "Total files: $($files.Count)"
    
    if ($files.Count -gt 0) {
        Write-Host ""
        Write-Host "Files found:" -ForegroundColor Cyan
        foreach ($file in $files) {
            if ($file.PSIsContainer) {
                Write-Host "  [DIR]  $($file.Name)" -ForegroundColor Blue
            } else {
                $sizeKB = [math]::Round($file.Length / 1KB, 2)
                $lastWrite = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                Write-Host "  [FILE] $($file.Name) - $sizeKB KB - $lastWrite" -ForegroundColor White
            }
        }
        
        # Check specifically for mass_state files
        $massFiles = $files | Where-Object { $_.Name -like "*mass_state*" }
        if ($massFiles.Count -gt 0) {
            Write-Host ""
            Write-Host "Mass State Files:" -ForegroundColor Yellow
            foreach ($file in $massFiles) {
                $sizeKB = [math]::Round($file.Length / 1KB, 2)
                $lastWrite = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                Write-Host "  SUCCESS: $($file.Name) - $sizeKB KB - $lastWrite" -ForegroundColor Green
            }
        } else {
            Write-Host ""
            Write-Host "No mass_state files found yet" -ForegroundColor Yellow
        }
    } else {
        Write-Host "No files found yet - app may still be initializing" -ForegroundColor Yellow
    }
} else {
    Write-Host "Hive directory not created yet" -ForegroundColor Red
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green 