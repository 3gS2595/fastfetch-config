# flowerfetch.ps1 — PowerShell port: floral braille splash around fastfetch info.
# Layout: [logo]  [top spray] / [stem | info nuzzled in]
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ESC    = [char]27
$RESET  = "$ESC[0m"
$GREEN  = "$ESC[38;2;140;185;120m"   # floral / logo color
$PURPLE = "$ESC[38;2;175;120;225m"   # info text color
$dir    = Join-Path $HOME ".config\fastfetch"
$SEP_TXT_COL = 7
$STEM_START  = 9
$GAP = "  "

function Strip($s) { return ($s -replace "$ESC\[[0-9;]*m", "") }
function VLen($s)  { return (Strip $s).Length }

# info text only (no logo, no color); call the real exe so an alias can't recurse
$INFO = @(& fastfetch.exe --logo none --pipe)
$LOGO = @(Get-Content -Encoding UTF8 (Join-Path $dir "logo.txt"))
$SIDE = @(Get-Content -Encoding UTF8 (Join-Path $dir "floral_sep.txt"))
$GTOP = @(Get-Content -Encoding UTF8 (Join-Path $dir "garland_top.txt"))
$n = $INFO.Count

# stem segment with the info nuzzled against it
$STEMINFO = @()
for ($k = 0; $k -lt $n; $k++) {
  $idx  = $STEM_START + $k
  $srow = if ($idx -lt $SIDE.Count) { $SIDE[$idx] } else { "" }
  if ($srow.Length -ge $SEP_TXT_COL) { $stem = $srow.Substring(0, $SEP_TXT_COL) }
  else { $stem = $srow.PadRight($SEP_TXT_COL) }
  $STEMINFO += "$GREEN$stem$RESET$PURPLE$($INFO[$k])$RESET"
}

# stack: top spray, then stem+info
$MID = @()
foreach ($l in $GTOP) { $MID += "$GREEN$l$RESET" }
$MID += $STEMINFO
$total = $MID.Count

# logo & floral both centered against the taller column
$lw = ($LOGO | ForEach-Object { VLen $_ } | Measure-Object -Maximum).Maximum
$lr = $LOGO.Count
$canvas = [Math]::Max($total, $lr)
$ltop = [int](($canvas - $lr) / 2)
$mtop = [int](($canvas - $total) / 2)

for ($i = 0; $i -lt $canvas; $i++) {
  $li = $i - $ltop
  if ($li -ge 0 -and $li -lt $lr) {
    $ll  = $LOGO[$li]
    $pad = [Math]::Max(0, $lw - (VLen $ll))
    $logo = $ll + (' ' * $pad)
  } else { $logo = ' ' * $lw }
  $mi  = $i - $mtop
  $mid = if ($mi -ge 0 -and $mi -lt $total) { $MID[$mi] } else { "" }
  Write-Host "$GREEN$logo$RESET$GAP$RESET$mid"
}
