param(
  [string]$Key,
  [string]$PlanPath = ".\plan.json",
  [string]$OutDir = ".\out"
)

$ErrorActionPreference = "Stop"

Write-Host "=== generate.ps1 starting ===" -ForegroundColor Cyan
Write-Host "PWD: $(Get-Location)" -ForegroundColor DarkCyan
Write-Host "Plan path: $PlanPath" -ForegroundColor DarkCyan
Write-Host "Out dir:   $OutDir" -ForegroundColor DarkCyan

if (-not $Key) { $Key = $env:GEMINI_KEY }
if (-not $Key) { throw "No API key. Pass -Key 'YOUR_KEY' or set `$env:GEMINI_KEY" }
Write-Host "API key detected (length=$($Key.Length))" -ForegroundColor DarkCyan

if (-not (Test-Path $PlanPath)) { throw "Plan file not found: $PlanPath" }
$planRaw = Get-Content $PlanPath -Raw
Write-Host "Plan file loaded (chars=$($planRaw.Length))" -ForegroundColor DarkCyan
$plan = $planRaw | ConvertFrom-Json

$model = if ($plan.model) { $plan.model } else { "gemini-2.0-flash" }
$batchCount = ($plan.batches | Measure-Object).Count
Write-Host "Model: $model" -ForegroundColor DarkCyan
Write-Host "Batches: $batchCount" -ForegroundColor DarkCyan

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
Write-Host "Output folder ready." -ForegroundColor DarkCyan

function Invoke-Gemini([string]$Model, [string]$Key, [string]$Prompt) {
  $body = @{
    contents = @(@{ role = "user"; parts = @(@{ text = $Prompt }) })
  } | ConvertTo-Json -Depth 6
  $uri = "https://generativelanguage.googleapis.com/v1beta/models/$Model`:generateContent?key=$Key"
  Write-Host "POST $uri" -ForegroundColor Gray
  Invoke-RestMethod -Method Post -Uri $uri -ContentType "application/json" -Body $body
}

function Build-Prompt([string]$topic, [string]$gradeBand, [int]$count, [string]$difficulty, [string]$type) {
@"
Return ONLY a JSON array of $count math problems for grade band "$gradeBand" on the topic "$topic".
Rules:
- Difficulty: $difficulty.
- Language: friendly and clear for $gradeBand.
- Vary numbers and sub-skills so questions arent repetitive.
- For each item include: "id" (string), "prompt" (string), "type" ("$type"), "answer" (string), "explanation" (13 sentence).
- If "type" is "mcq", also include "options": exactly 4 strings labeled A, B, C, D; "answer" must be one of A,B,C,D.
- No extra commentary or markdown  ONLY a JSON array.
"@
}

function Save-Json([string]$dir, [string]$gradeBand, [string]$topic, [string]$type, [string]$difficulty, [string]$jsonText) {
  $cleanGrade = ($gradeBand -replace '[^a-zA-Z0-9\-]+','_')
  $cleanTopic = ($topic -replace '[^a-zA-Z0-9\-]+','_')
  $timestamp  = (Get-Date).ToString('yyyyMMdd_HHmmss')

  $safeName = @(
    $cleanGrade
    $cleanTopic
    $type
    $difficulty
    $timestamp
  ) -join '__'

  $subdir = Join-Path $dir $cleanGrade
  New-Item -ItemType Directory -Force -Path $subdir | Out-Null

  $file = Join-Path $subdir "$safeName.json"
  $jsonText | Out-File -Encoding utf8 $file
  return $file
}


$i = 0
foreach ($b in $plan.batches) {
  $i++
  $grade = $b.gradeBand; $topic = $b.topic
  $type  = if ($b.type) { $b.type } else { "open" }
  $count = if ($b.count) { [int]$b.count } else { 5 }
  $difficulty = if ($b.difficulty) { $b.difficulty } else { $plan.defaultDifficulty }

  Write-Host "[${i}/${batchCount}] Generating: $grade | $topic | $type | $difficulty | $count" -ForegroundColor Cyan
  $prompt = Build-Prompt -topic $topic -gradeBand $grade -count $count -difficulty $difficulty -type $type

  try {
    $resp = Invoke-Gemini -Model $model -Key $Key -Prompt $prompt
    $text = $resp.candidates[0].content.parts[0].text
    if (-not $text) { throw "Empty response from API (no text)" }
    $file = Save-Json -dir $OutDir -gradeBand $grade -topic $topic -type $type -difficulty $difficulty -jsonText $text
    Write-Host " Saved: $file" -ForegroundColor Green
  } catch {
    Write-Host " Batch failed: $grade | $topic | $type | $difficulty" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.ErrorDetails.Message) { Write-Host $_.ErrorDetails.Message -ForegroundColor Red }
  }
}
Write-Host "All done. Output in: $(Resolve-Path $OutDir)" -ForegroundColor Cyan
