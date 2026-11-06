<#
Applies gameupdate\deltas\*.xdelta (VCDIFF) to the game's original archives.
Originals are kept as Data\<Name>.wolf.bak. Run again safely; -Restore puts the originals back.
#>
param([string]$Root = (Split-Path -Parent $PSScriptRoot), [switch]$Restore)
$ErrorActionPreference = 'Stop'
if (-not ('GameUpdateVcdiff' -as [type])) {
Add-Type -TypeDefinition @'
using System;using System.IO;
public static class GameUpdateVcdiff {
  static long V(byte[] b, ref long p){ long r=0; while(true){ byte c=b[p++]; r=r*128+(c&127); if((c&128)==0) return r; } }
  public static byte[] Apply(byte[] src, byte[] d){
    if(d[0]!=0xD6||d[1]!=0xC3||d[2]!=0xC4||d[3]!=0||d[4]!=0) throw new InvalidDataException("Unsupported patch file.");
    long p=5; MemoryStream o=new MemoryStream();
    while(p<d.Length){
      byte w=d[p++]; if(w!=1) throw new InvalidDataException("Unsupported patch window.");
      long sl=V(d,ref p), sp=V(d,ref p); V(d,ref p); long tl=V(d,ref p);
      if(d[p++]!=0) throw new InvalidDataException("Unsupported patch compression.");
      long dl=V(d,ref p), il=V(d,ref p), al=V(d,ref p);
      long dp=p, ip=dp+dl, ap=ip+il, end=ap+al, iend=ap; byte[] t=new byte[tl]; long n=0;
      while(ip<iend){
        byte c=d[ip++]; long sz=V(d,ref ip);
        if(c==1){ Array.Copy(d,dp,t,n,sz); dp+=sz; n+=sz; }
        else if(c==19){ long a=V(d,ref ap); if(a+sz>sl) throw new InvalidDataException("Bad copy."); Array.Copy(src,sp+a,t,n,sz); n+=sz; }
        else throw new InvalidDataException("Unsupported patch instruction.");
      }
      if(n!=tl) throw new InvalidDataException("Patch size mismatch.");
      o.Write(t,0,t.Length); p=end;
    }
    return o.ToArray();
  }
}
'@
}
function Get-Sha([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
$deltas = Join-Path $Root 'gameupdate\deltas'
$data = Join-Path $Root 'Data'
$lines = @(Get-Content -LiteralPath (Join-Path $deltas 'deltas.txt') | Where-Object { $_.Trim() })
# Check every archive first, so a wrong game version changes nothing at all.
if (-not $Restore) {
    foreach ($line in $lines) {
        $name, $sourceSha, $targetSha = $line.Trim() -split '\s+'
        $wolf = Join-Path $data "$name.wolf"; $bak = "$wolf.bak"
        if ((Test-Path -LiteralPath $wolf) -and (Get-Sha $wolf) -eq $targetSha) { continue }
        $source = if (Test-Path -LiteralPath $bak) { $bak } else { $wolf }
        if (-not (Test-Path -LiteralPath $source)) { throw "Missing Data\$name.wolf. Run this from the game folder." }
        if ((Get-Sha $source) -ne $sourceSha) { throw "Data\$([IO.Path]::GetFileName($source)) is not the expected original game file (version 2.01). Nothing was changed." }
    }
}
foreach ($line in $lines) {
    $name, $sourceSha, $targetSha = $line.Trim() -split '\s+'
    $wolf = Join-Path $data "$name.wolf"; $bak = "$wolf.bak"; $tmp = "$wolf.tmp"
    if ($Restore) {
        if (Test-Path -LiteralPath $bak) { Move-Item -LiteralPath $bak -Destination $wolf -Force; Write-Host "Restored $name.wolf" }
        continue
    }
    if ((Test-Path -LiteralPath $wolf) -and (Get-Sha $wolf) -eq $targetSha) { Write-Host "$name.wolf is already patched"; continue }
    $source = if (Test-Path -LiteralPath $bak) { $bak } else { $wolf }
    $out = [GameUpdateVcdiff]::Apply([IO.File]::ReadAllBytes($source), [IO.File]::ReadAllBytes((Join-Path $deltas "$name.xdelta")))
    [IO.File]::WriteAllBytes($tmp, $out)
    if ((Get-Sha $tmp) -ne $targetSha) { Remove-Item -LiteralPath $tmp -Force; throw "Patched $name.wolf failed its check. Nothing was changed for it." }
    if ($source -eq $wolf) { Move-Item -LiteralPath $wolf -Destination $bak }
    Move-Item -LiteralPath $tmp -Destination $wolf -Force
    Write-Host "Patched $name.wolf"
}
