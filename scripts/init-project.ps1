# ============================================
# Antigravity Life OS - Project Initializer (Windows)
# ============================================
# Usage: .\init-project.ps1 -ProjectName "my-app" -Type "dev" -Template "user-mgmt"
#        .\init-project.ps1 -ListTemplates

param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("dev", "creative", "life")]
    [string]$Type = "dev",
    
    [Parameter(Mandatory=$false)]
    [string]$Template,
    
    [switch]$ListTemplates
)

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$WorkspaceRoot = Join-Path $RepoRoot "projects"
$TemplatesJson = Join-Path $RepoRoot "library\config\templates.json"

# List templates function
function Show-Templates {
    Write-Host "📦 Available Templates:" -ForegroundColor Blue
    Write-Host ""
    if (Test-Path $TemplatesJson) {
        $config = Get-Content $TemplatesJson | ConvertFrom-Json
        foreach ($key in $config.templates.PSObject.Properties.Name) {
            $tmpl = $config.templates.$key
            Write-Host "  $key: $($tmpl.description)"
        }
    } else {
        Write-Host "  (No templates configured)"
    }
    Write-Host ""
    exit 0
}

# Copy template files with overlay
function Copy-Template {
    param(
        [string]$TemplateName,
        [string]$TargetPath
    )
    
    if (-not (Test-Path $TemplatesJson)) {
        Write-Host "Error: templates.json not found" -ForegroundColor Red
        exit 1
    }
    
    $config = Get-Content $TemplatesJson | ConvertFrom-Json
    $tmpl = $config.templates.$TemplateName
    
    if (-not $tmpl) {
        Write-Host "Error: Template '$TemplateName' not found" -ForegroundColor Red
        exit 1
    }
    
    $templatePath = Join-Path $RepoRoot $tmpl.path
    
    if (-not (Test-Path $templatePath)) {
        Write-Host "Error: Template directory not found: $templatePath" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "📋 Applying template: $TemplateName" -ForegroundColor Blue
    
    # Copy src/ directly
    $srcPath = Join-Path $templatePath "src"
    if (Test-Path $srcPath) {
        Copy-Item -Path "$srcPath\*" -Destination (Join-Path $TargetPath "src") -Recurse -Force
        Write-Host "✓ Copied src/ (implementation base)" -ForegroundColor Green
    }
    
    # Copy spec/ to spec/BASE_REFERENCE/
    $specPath = Join-Path $templatePath "spec"
    if (Test-Path $specPath) {
        $baseRef = Join-Path $TargetPath "spec\BASE_REFERENCE"
        New-Item -ItemType Directory -Path $baseRef -Force | Out-Null
        Get-ChildItem $specPath -File | ForEach-Object {
            if ($_.Name -ne ".gitkeep") {
                Copy-Item $_.FullName $baseRef
            }
        }
        Write-Host "✓ Copied spec/ → spec/BASE_REFERENCE/" -ForegroundColor Green
    }
    
    # Copy research/ to research/BASE_REFERENCE/
    $researchPath = Join-Path $templatePath "research"
    if (Test-Path $researchPath) {
        $baseRef = Join-Path $TargetPath "research\BASE_REFERENCE"
        New-Item -ItemType Directory -Path $baseRef -Force | Out-Null
        Get-ChildItem $researchPath -File | ForEach-Object {
            if ($_.Name -ne ".gitkeep") {
                Copy-Item $_.FullName $baseRef
            }
        }
        Write-Host "✓ Copied research/ → research/BASE_REFERENCE/" -ForegroundColor Green
    }
    
    # Copy learning/ directly
    $learningPath = Join-Path $templatePath "learning"
    if (Test-Path $learningPath) {
        $targetLearning = Join-Path $TargetPath "learning"
        New-Item -ItemType Directory -Path $targetLearning -Force | Out-Null
        Copy-Item -Path "$learningPath\*" -Destination $targetLearning -Recurse -Force
        Write-Host "✓ Copied learning/ (technical guides)" -ForegroundColor Green
    }
    
    # Generate TEMPLATE_README.md
    $templateReadme = @"
# Template Base: $TemplateName

このプロジェクトは ``$TemplateName`` テンプレートをベースに作成されました。

## テンプレートから引き継いだファイル

| パス | 説明 | 使い方 |
|------|------|--------|
| ``src/`` | 実装ベース | そのまま使用・拡張可能 |
| ``spec/BASE_REFERENCE/`` | 設計・実装プラン資料 | 参照用（新規は spec/ 直下に作成） |
| ``research/BASE_REFERENCE/`` | 技術調査資料 | 参照用 |
| ``learning/`` | 技術解説ドキュメント | 学習・参照用 |

## エージェント向けガイド

1. **PRP作成**: ``docs/PRP.md`` に新プロジェクトの要件を記載
2. **設計参照**: ``spec/BASE_REFERENCE/`` の既存設計を参考に
3. **新規設計**: 新しい実装プランは ``spec/implementation_plan.md`` に作成
4. **実装**: ``src/`` を拡張・改修

## テンプレート情報

- **Template**: $TemplateName
- **Applied**: $(Get-Date -Format "yyyy-MM-dd")
- **Config**: library/config/templates.json
"@
    $templateReadme | Out-File -FilePath (Join-Path $TargetPath "TEMPLATE_README.md") -Encoding UTF8
    Write-Host "✓ Generated TEMPLATE_README.md" -ForegroundColor Green
}

# Handle --list-templates
if ($ListTemplates) {
    Show-Templates
}

# Validate project name
if (-not $ProjectName) {
    Write-Host "Error: Project name is required" -ForegroundColor Red
    Write-Host "Usage: .\init-project.ps1 -ProjectName <name> [-Type dev|creative|life] [-Template <name>]"
    Write-Host "       .\init-project.ps1 -ListTemplates"
    exit 1
}

$ProjectPath = Join-Path $WorkspaceRoot $ProjectName

Write-Host "🚀 Initializing project: $ProjectName" -ForegroundColor Blue
Write-Host "   Type: $Type"
if ($Template) {
    Write-Host "   Template: $Template" -ForegroundColor Yellow
}
Write-Host "   Path: $ProjectPath"
Write-Host ""

# Create project structure
$folders = @("src", "tests", "docs", "spec", "research", "resources\mockups", "tracks")
foreach ($folder in $folders) {
    $path = Join-Path $ProjectPath $folder
    New-Item -ItemType Directory -Path $path -Force | Out-Null
}
Write-Host "✓ Created directory structure" -ForegroundColor Green

# Copy appropriate template
$libraryPath = Join-Path $RepoRoot "library"
switch ($Type) {
    "dev" {
        Copy-Item (Join-Path $libraryPath "dev-templates\PRP_TEMPLATE.md") (Join-Path $ProjectPath "docs\PRP.md")
        Write-Host "✓ Copied PRP template" -ForegroundColor Green
    }
    "creative" {
        Copy-Item (Join-Path $libraryPath "creative-templates\CONTENT_TEMPLATE.md") (Join-Path $ProjectPath "docs\CONTENT.md")
        Write-Host "✓ Copied Content template" -ForegroundColor Green
    }
    "life" {
        Copy-Item (Join-Path $libraryPath "life-templates\WEEKLY_PLANNER.md") (Join-Path $ProjectPath "docs\PLANNER.md")
        Write-Host "✓ Copied Planner template" -ForegroundColor Green
    }
}

# Copy CLAUDE.md
$claudeTemplate = Join-Path $libraryPath "claude-templates\CLAUDE.md"
if (Test-Path $claudeTemplate) {
    Copy-Item $claudeTemplate (Join-Path $ProjectPath "CLAUDE.md")
    Write-Host "✓ Copied CLAUDE.md" -ForegroundColor Green
}

# Apply template overlay if specified
if ($Template) {
    Copy-Template -TemplateName $Template -TargetPath $ProjectPath
}

# Create README
$templateNote = if ($Template) { "`n**Template:** $Template" } else { "" }
$readme = @"
# $ProjectName

**Type:** $Type
**Created:** $(Get-Date -Format "yyyy-MM-dd")
**Status:** Initial$templateNote

---

## Overview
[プロジェクトの概要をここに記載]

## Structure
``````
$ProjectName/
├── src/              # ソースコード
├── tests/            # テスト
├── docs/             # PRP等ドキュメント
├── spec/             # 実装プラン
├── research/         # 調査結果
├── resources/mockups # デザイン
└── tracks/           # 並列実行トラック
``````

## Quick Start
1. ``docs/PRP.md`` に要件を記載
2. PMに設計依頼
3. 並列実装開始

---
*Generated by Antigravity Life OS*
"@

$readme | Out-File -FilePath (Join-Path $ProjectPath "README.md") -Encoding UTF8
Write-Host "✓ Created README.md" -ForegroundColor Green

# Create .gitkeep files (only if directories are empty)
$gitkeepFolders = @("src", "tests", "spec", "research", "tracks")
foreach ($folder in $gitkeepFolders) {
    $folderPath = Join-Path $ProjectPath $folder
    if (-not (Get-ChildItem $folderPath -Force | Where-Object { $_.Name -ne ".gitkeep" })) {
        $keepPath = Join-Path $folderPath ".gitkeep"
        New-Item -ItemType File -Path $keepPath -Force | Out-Null
    }
}

Write-Host ""
Write-Host "✅ Project initialized successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. cd $ProjectPath"
Write-Host "  2. Edit docs\PRP.md with your requirements"
if ($Template) {
    Write-Host "  3. Review TEMPLATE_README.md for template details"
    Write-Host "  4. Start development with Agent Guild"
} else {
    Write-Host "  3. Start development with Agent Guild"
}
