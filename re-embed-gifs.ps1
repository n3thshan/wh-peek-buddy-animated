# Re-embeds GIF files from gifs/ into peek-buddy-animated.wh.cpp as base64.
#
# Usage:
#   .\re-embed-gifs.ps1
#
# The script works from any directory. It scans every file in gifs/:
#   - The six existing GIFs keep their exact array names:
#       cloud 1.gif     -> kGifCloud1B64
#       cloud 2.gif     -> kGifCloud2B64
#       cloud 3.gif     -> kGifCloud3B64
#       sephiroth 1.gif -> kGifSeph1B64
#       sephiroth 2.gif -> kGifSeph2B64
#       tifa.gif        -> kGifTifaB64
#   - Any other .gif gets a new array created automatically, e.g.
#       barret.gif      -> kGifBarretB64
#     and the script prints the exact line to add to kGifs[] in the source.
#
# Only real GIFs (signature GIF87a or GIF89a) are embedded. Non-GIF files are
# warned about and skipped. A summary is printed and the script exits
# non-zero if anything fails.
#
# Wraps base64 at 120 characters per line to match the existing style.

$ErrorActionPreference = 'Stop'

# Resolve paths relative to this script so it works from any directory.
# Candidate directories: the script's own folder, then the current location.
# Pick the first one that actually contains the source and the gifs folder.
function Find-ProjectRoot {
    $candidates = New-Object System.Collections.Generic.List[string]
    if ($PSCommandPath) {
        $d = Split-Path -Parent $PSCommandPath
        $candidates.Add($d)
    }
    if ($PSScriptRoot) { $candidates.Add($PSScriptRoot) }
    $candidates.Add((Get-Location).Path)
    foreach ($cand in $candidates) {
        if (-not $cand) { continue }
        $src = Join-Path $cand 'peek-buddy-animated.wh.cpp'
        $g = Join-Path $cand 'gifs'
        $ok1 = Test-Path -LiteralPath $src
        $ok2 = Test-Path -LiteralPath $g
        if ($ok1 -and $ok2) {
            return $cand
        }
    }
    return $null
}

$scriptDir = Find-ProjectRoot
if (-not $scriptDir) {
    $msg = "Could not find peek-buddy-animated.wh.cpp and gifs/ next to the script or in the current folder."
    Write-Error $msg
    exit 1
}
$source = Join-Path $scriptDir 'peek-buddy-animated.wh.cpp'
$gifsDir = Join-Path $scriptDir 'gifs'

if (-not (Test-Path -LiteralPath $source)) {
    $msg = "Source file not found: " + $source
    Write-Error $msg
    exit 1
}
if (-not (Test-Path -LiteralPath $gifsDir)) {
    $msg = "GIFs folder not found: " + $gifsDir
    Write-Error $msg
    exit 1
}

$content = [System.IO.File]::ReadAllText($source)

# Friendly GIF file name -> embedded array variable name (kept exactly).
$map = @{}
$map['cloud 1.gif'] = 'kGifCloud1B64'
$map['cloud 2.gif'] = 'kGifCloud2B64'
$map['cloud 3.gif'] = 'kGifCloud3B64'
$map['sephiroth 1.gif'] = 'kGifSeph1B64'
$map['sephiroth 2.gif'] = 'kGifSeph2B64'
$map['tifa.gif'] = 'kGifTifaB64'

# Turns a file base name into a deterministic array name, e.g. "barret" ->
# "kGifBarretB64". Keeps only letters and digits, then title-cases.
function Get-ArrayName($baseName) {
    $id = $baseName -replace '[^A-Za-z0-9]', ''
    if ($id.Length -eq 0) { $id = 'gif' }
    $id = $id.Substring(0, 1).ToUpper() + $id.Substring(1).ToLower()
    return 'kGif' + $id + 'B64'
}

# Sanitizes a base name into a kGifs id, e.g. "barret" -> "barret".
function Get-GifId($baseName) {
    return ($baseName -replace '[^A-Za-z0-9]', '').ToLower()
}

# Wraps base64 at 120 chars per line, each line quoted.
function New-B64Block($b64) {
    $lines = New-Object System.Collections.Generic.List[string]
    for ($i = 0; $i -lt $b64.Length; $i += 120) {
        $chunk = $b64.Substring($i, [Math]::Min(120, $b64.Length - $i))
        $lines.Add('"' + $chunk + '"')
    }
    return [string]::Join("`n", $lines)
}

# Extracts the raw base64 (no quotes/newlines) currently stored in an array.
function Get-CurrentB64($match) {
    $body = $match.Groups['body'].Value
    $parts = $body -split "`n"
    $clean = $parts | ForEach-Object { $_ -replace '^"|"$', '' }
    return [string]::Join('', $clean)
}

$gifs = Get-ChildItem -LiteralPath $gifsDir -Filter '*.gif' -File |
    Sort-Object -Property Name

$embedded = 0
$unchanged = 0
$skipped = 0
$failed = 0
$newArrays = New-Object System.Collections.Generic.List[pscustomobject]
$anchor = 'static const GifAsset kGifs[] = {'

foreach ($file in $gifs) {
    $fileName = $file.Name
    $bytes = $null
    try {
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    } catch {
        $errMsg = $_.Exception.Message
        $msg = "Failed to read " + $fileName + ": " + $errMsg
        Write-Warning $msg
        $failed++
        continue
    }

    # Validate GIF signature.
    if ($bytes.Length -lt 6) {
        $msg = "Skipping " + $fileName + ": too small to be a GIF"
        Write-Warning $msg
        $skipped++
        continue
    }
    $sig = [System.Text.Encoding]::ASCII.GetString($bytes, 0, 6)
    if ($sig -ne 'GIF87a' -and $sig -ne 'GIF89a') {
        $msg = "Skipping " + $fileName + ": not a GIF (signature '" + $sig + "')"
        Write-Warning $msg
        $skipped++
        continue
    }

    $b64 = [Convert]::ToBase64String($bytes)

    # Determine the array name.
    if ($map.ContainsKey($fileName)) {
        $varName = $map[$fileName]
    } else {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        $varName = Get-ArrayName $baseName
    }

    # Does the array already exist in the source?
    $pattern = [regex]::Escape($varName) + '\[\]\s*=\s*(?<body>.*?);'
    $regex = [regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $match = $regex.Match($content)

    if ($match.Success) {
        $currentB64 = Get-CurrentB64 $match
        if ($currentB64 -eq $b64) {
            $msg = "Unchanged " + $fileName + " -> " + $varName + " (" + $bytes.Length + " bytes)"
            Write-Host $msg
            $unchanged++
            continue
        }
        # Replace the existing array body, keeping the prefix and trailing ";".
        $oldBody = $match.Groups['body'].Value
        $newBlock = New-B64Block $b64
        $bodyIndex = $match.Groups['body'].Index
        $content = $content.Substring(0, $bodyIndex) +
                   $newBlock +
                   $content.Substring($bodyIndex + $oldBody.Length)
        $msg = "Re-embedded " + $fileName + " -> " + $varName + " (" + $bytes.Length +
               " bytes, " + $b64.Length + " base64 chars)"
        Write-Host $msg
        $embedded++
    } else {
        # New array: remember it, insert before kGifs[].
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        $gifId = Get-GifId $baseName
        $newBlock = New-B64Block $b64
        $newArrayText = "static const char " + $varName + "[] =" + "`n" + $newBlock + "`n;" + "`n"
        $obj = New-Object pscustomobject
        $obj | Add-Member -MemberType NoteProperty -Name VarName -Value $varName
        $obj | Add-Member -MemberType NoteProperty -Name Id -Value $gifId
        $obj | Add-Member -MemberType NoteProperty -Name Text -Value $newArrayText
        $newArrays.Add($obj)
        $msg = "Created array " + $varName + " for " + $fileName + " (" + $bytes.Length +
               " bytes, " + $b64.Length + " base64 chars)"
        Write-Host $msg
        $embedded++
    }
}

# Insert newly created arrays right before the kGifs[] declaration.
if ($newArrays.Count -gt 0) {
    $idx = $content.IndexOf($anchor)
    if ($idx -lt 0) {
        $msg = "Could not find kGifs[] declaration in source; cannot insert new arrays."
        Write-Error $msg
        $failed += $newArrays.Count
    } else {
        $insertText = ""
        foreach ($a in $newArrays) { $insertText += $a.Text }
        $content = $content.Substring(0, $idx) + $insertText + $content.Substring($idx)
    }
}

$currentContent = [System.IO.File]::ReadAllText($source)
if ($content -ne $currentContent) {
    # UTF-8 without BOM, LF line endings.
    [System.IO.File]::WriteAllText($source, $content)
}

# Print the kGifs line(s) to add for newly created arrays.
if ($newArrays.Count -gt 0) {
    Write-Host "`n--- Add these lines to kGifs[] in peek-buddy-animated.wh.cpp ---"
    foreach ($a in $newArrays) {
        $line = '    {L"' + $a.Id + '", ' + $a.VarName + ', 0, L"ff7"},  // NEW: set quoteSet/pack as needed'
        Write-Host $line
    }
    Write-Host "--- Also add the pack to the settings `pack` options if it is new ---"
}

$msg = "Done. Embedded: " + $embedded + ", unchanged: " + $unchanged +
       ", skipped: " + $skipped + ", failed: " + $failed + "."
Write-Host "`n" + $msg

if ($failed -gt 0) {
    exit 1
}
