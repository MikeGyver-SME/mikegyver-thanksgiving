# Pushes Thanksgiving Countdown v1.0.4 to GitHub and tags it.
# The TestFlight workflow is workflow_dispatch: run it by hand from
# the Actions tab after pushing (a tag push does not start it).
#
# 1. Create an EMPTY repo on GitHub first: MikeGyver-SME/mikegyver-thanksgiving
#    (no README, no .gitignore — this script supplies both).
# 2. Save this script AND thanksgiving-countdown-v1.0.4.zip in E:\Downloads.
# 3. Run (after the Apple portal + GitHub secrets steps, see README.md):
#      powershell -ExecutionPolicy Bypass -File E:\Downloads\push-thanksgiving.ps1
#
# If the repo folder already exists with a .git folder, the script overlays
# the zip onto it instead of re-initialising. Either way it tags v1.0.4.
# If v1.0.4 already exists, stop: bump CURRENT_PROJECT_VERSION in
# project.yml and re-zip before tagging again (TestFlight rejects a
# duplicate version/build pair).

param(
    [string]$RepoPath = ""
)

$ErrorActionPreference = 'Stop'

$downloads = if (Test-Path 'E:\Downloads') { 'E:\Downloads' } else { "$env:USERPROFILE\Downloads" }
$zip  = Join-Path $downloads 'thanksgiving-countdown-v1.0.4.zip'
$repo = if ($RepoPath) { $RepoPath } elseif ($args.Count -ge 1) { $args[0] } else { Join-Path $downloads 'mikegyver-thanksgiving' }

if (-not (Test-Path $zip)) { throw "Zip not found: $zip" }

$isNew = -not (Test-Path (Join-Path $repo '.git'))
if ($isNew) {
    New-Item -ItemType Directory -Force -Path $repo | Out-Null
    Expand-Archive -Path $zip -DestinationPath $repo -Force
    Set-Location $repo
    git init -b main
    git remote add origin https://github.com/MikeGyver-SME/mikegyver-thanksgiving.git
} else {
    Expand-Archive -Path $zip -DestinationPath $repo -Force
    Set-Location $repo
}

$status = git status --porcelain
if (-not $status -and -not $isNew) { Write-Host "Nothing changed - working tree already has v1.0.4."; exit 0 }

if (git tag --list 'v1.0.4') { throw "Tag v1.0.4 already exists. Bump CURRENT_PROJECT_VERSION in project.yml and re-zip first." }

git add -A
git commit -m "MG Holiday Countdown v1.0.4: CarPlay/phone small tile clipping fix" | Out-Null
if ($isNew) {
    git push -u origin main
    if ($LASTEXITCODE -ne 0) {
        # Windows PowerShell does not throw on a failing native command,
        # so check the exit code explicitly. (v1.0.2 lesson: the old
        # try/catch around git push never fired, the tag pushed, and
        # main was silently never updated.)
        Write-Host "Initial push rejected (remote probably has a README) - pulling and retrying..."
        git pull --rebase origin main
        if ($LASTEXITCODE -ne 0) { throw "git pull --rebase failed - resolve conflicts, then re-run." }
        git push -u origin main
        if ($LASTEXITCODE -ne 0) { throw "git push failed after rebase - main was NOT updated." }
    }
} else {
    git push
    if ($LASTEXITCODE -ne 0) { throw "git push failed - main was NOT updated. Do not tag; fix the push first." }
}
git tag v1.0.4
git push origin v1.0.4
if ($LASTEXITCODE -ne 0) { throw "git push origin v1.0.4 (tag) failed." }

Write-Host ""
Write-Host "Pushed v1.0.4 - now run the TestFlight workflow BY HAND:"
Write-Host "GitHub repo -> Actions -> 'Thanksgiving Countdown - Signed TestFlight' -> Run workflow."
Write-Host "Pushing a tag does NOT start it (it is workflow_dispatch, manual only)."
Write-Host "Watch it at: https://github.com/MikeGyver-SME/mikegyver-thanksgiving/actions"
Write-Host "Before that workflow can succeed, set the repo secrets ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_P8, TEAM_ID,"
Write-Host "and create the App IDs in the Apple Developer portal (see README.md section 3)."
