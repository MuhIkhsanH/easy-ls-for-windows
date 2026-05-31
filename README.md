# 📂 Windows Storage Analyzer (`ls.bat`)

An interactive batch script wrapper that enhances the standard Windows Command Prompt (CMD) experience. By leveraging PowerShell under the hood, this script scans the current directory, recursively calculates folder sizes (a feature natively missing from CMD's `dir`), and displays the results sorted from largest to smallest with intuitive color-coding.

---

## ✨ Features

* **Real-Time Scan Progress:** Displays a live percentage counter and the currently scanned item while processing files and folders.
* **Recursive Folder Sizing:** Calculates the actual total size of directories (`[DIR]`), including all sub-folders and nested files.
* **Automatic Sorting:** Automatically sorts the final output by size in descending order (largest items first).
* **Human-Readable Formats:** Automatically converts byte sizes into cleanly formatted **KB**, **MB**, or **GB**.
* **Color-Coded Console Output:** * `[DIR]` is highlighted in **Yellow** 🟨
  * `[FILE]` is highlighted in **Green** 🟩
* **Smart Truncation:** Automatically truncates long file or folder names (>35 characters) with `..` to preserve a clean and aligned table layout.

---

## 🚀 Installation & Setup

To make this script accessible from any directory in your Command Prompt (just like the native `ls` command in Linux), follow these steps:

### Step 1: Create the Batch File
1. Create a new text file named `ls.bat`.
2. Paste the following code inside it and save:

```batch
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
