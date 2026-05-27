# Rebuilds app.bundle.js from the editable .jsx source.
# Concatenates the components (in load order) + app.jsx, then compiles JSX ->
# plain JS with esbuild (classic runtime; React/ReactDOM are global UMD vendors).
#
# Usage:  pwsh -NoProfile -File build.ps1
# Requires: Node/npx on PATH (esbuild is fetched on demand via `npx -y`).

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

$order = @(
  'components/MarketingNav.jsx'
  'components/Hero.jsx'
  'components/FeatureGrid.jsx'
  'components/BrowserMatrix.jsx'
  'components/PhasesTimeline.jsx'
  'components/MarketingFooter.jsx'
  'app.jsx'
)

$tmp = '_build_src.jsx'
Get-Content $order -Raw | Set-Content $tmp -NoNewline

try {
  & npx -y esbuild@0.24.0 $tmp `
      --jsx=transform `
      --jsx-factory=React.createElement `
      --jsx-fragment=React.Fragment `
      --minify `
      --outfile=app.bundle.js
  if ($LASTEXITCODE -ne 0) { throw "esbuild failed ($LASTEXITCODE)" }
  Write-Host "Built app.bundle.js"
} finally {
  Remove-Item $tmp -ErrorAction SilentlyContinue
}
