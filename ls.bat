@echo off
powershell -NoProfile -Command ^
  "$path = Get-Location; " ^
  "Write-Host \"`n [!] ANALYZING STORAGE: $path\" -ForegroundColor Cyan; " ^
  "Write-Host ' ----------------------------------------------------------------------'; " ^
  "$items = Get-ChildItem; " ^
  "$total = $items.Count; $current = 0; $data = @(); " ^
  "foreach ($obj in $items) { " ^
    "$current++; $percent = [math]::Round(($current / $total) * 100); " ^
    "Write-Host (\"`r [*] Scanning: $percent%% [$current/$total] \" + $obj.Name.PadRight(30).Substring(0,30)) -NoNewline -ForegroundColor Gray; " ^
    "if ($obj.PSIsContainer) { " ^
      "$size = (Get-ChildItem $obj.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum; " ^
      "if (!$size) { $size = 0 }; " ^
      "$data += [PSCustomObject]@{Type='[DIR] '; Name=$obj.Name; RawSize=$size; Color='Yellow'; SizeCol='DarkYellow'} " ^
    "} else { " ^
      "$data += [PSCustomObject]@{Type='[FILE]'; Name=$obj.Name; RawSize=$obj.Length; Color='Green'; SizeCol='Gray'} " ^
    "} " ^
  "} " ^
  "Write-Host \"`r [v] SCAN COMPLETE. SORTING DATA...                         \" -ForegroundColor Cyan; " ^
  "Write-Host ' ----------------------------------------------------------------------'; " ^
  "$data | Sort-Object RawSize -Descending | ForEach-Object { " ^
    "$name = $_.Name; if ($name.Length -gt 35) { $name = $name.Substring(0, 32) + '..' }; " ^
    "$fmtSize = if ($_.RawSize -ge 1GB) { '{0:N2} GB' -f ($_.RawSize / 1GB) } elseif ($_.RawSize -ge 1MB) { '{0:N2} MB' -f ($_.RawSize / 1MB) } else { '{0:N2} KB' -f ($_.RawSize / 1KB) }; " ^
    "Write-Host (\" $($_.Type) \") -ForegroundColor $_.Color -NoNewline; " ^
    "Write-Host (' {0,-35}' -f $name) -NoNewline; " ^
    "Write-Host ('[{0,9}]' -f $fmtSize) -ForegroundColor $_.SizeCol " ^
  "}; " ^
  "Write-Host ' ----------------------------------------------------------------------'"
