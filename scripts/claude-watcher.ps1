# =============================================================================
# claude-watcher.ps1 - Claude出力監視・通知スクリプト (Windows)
# =============================================================================
# PMエージェント起動時にユーザー確認が発生した場合、通知で知らせる
#
# 使用方法:
#   .\claude-watcher.ps1 [claude引数...]
#
# 例:
#   .\claude-watcher.ps1
#   .\claude-watcher.ps1 -p "あなたはPMです..."
# =============================================================================

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$ClaudeArgs
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigFile = Join-Path $ScriptDir "..\..\library\config\notification.env"

# Default values
$SlackWebhookUrl = $null
$NotificationEnabled = $true

# Load config if exists
if (Test-Path $ConfigFile) {
    Get-Content $ConfigFile | ForEach-Object {
        if ($_ -match "^([^#=]+)=(.*)$") {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim().Trim('"')
            switch ($key) {
                "SLACK_WEBHOOK_URL" { $SlackWebhookUrl = $value }
                "NOTIFICATION_ENABLED" { $NotificationEnabled = $value -eq "true" }
            }
        }
    }
} else {
    Write-Host "⚠️  設定ファイルが見つかりません: $ConfigFile" -ForegroundColor Yellow
    Write-Host "   notification.env を作成してください"
}

# Notification patterns
$NotifyPatterns = @(
    "(y/n)",
    "(Y/n)",
    "?",
    "【ユーザー確認】",
    "approval",
    "waiting for",
    "Please confirm",
    "続行しますか",
    "よろしいですか"
)

# Send notification
function Send-Notification {
    param([string]$Message)
    
    if (-not $NotificationEnabled) { return }
    
    # Slack notification
    if ($SlackWebhookUrl) {
        try {
            $body = @{ text = "🤖 Claude確認依頼:`n```$Message```" } | ConvertTo-Json
            Invoke-RestMethod -Uri $SlackWebhookUrl -Method Post -Body $body -ContentType "application/json" -ErrorAction SilentlyContinue
        } catch {
            # Ignore errors
        }
    }
    
    # Windows Toast Notification
    try {
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        $template = [Windows.UI.Notifications.ToastTemplateType]::ToastText02
        $xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($template)
        $text = $xml.GetElementsByTagName("text")
        $text[0].AppendChild($xml.CreateTextNode("Claude確認依頼")) | Out-Null
        $text[1].AppendChild($xml.CreateTextNode($Message.Substring(0, [Math]::Min(100, $Message.Length)))) | Out-Null
        $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Claude Watcher").Show($toast)
    } catch {
        # Fallback: System beep
        [System.Console]::Beep(800, 300)
    }
}

# Check if line matches notification pattern
function Test-ShouldNotify {
    param([string]$Line)
    
    foreach ($pattern in $NotifyPatterns) {
        if ($Line -like "*$pattern*") {
            return $true
        }
    }
    return $false
}

# Main
Write-Host "🔔 Claude Watcher 起動" -ForegroundColor Cyan
Write-Host "   Slack通知: $(if ($SlackWebhookUrl) { '有効' } else { '無効（URL未設定）' })"
Write-Host "   Windows通知: 有効"
Write-Host "---"

# Run Claude and monitor output
$claudeCmd = "claude"
if ($ClaudeArgs) {
    $claudeArgs = $ClaudeArgs -join " "
}

try {
    $process = Start-Process -FilePath $claudeCmd -ArgumentList $ClaudeArgs -NoNewWindow -PassThru -RedirectStandardOutput "claude_output.tmp" -RedirectStandardError "claude_error.tmp"
    
    # Monitor output file
    while (-not $process.HasExited) {
        if (Test-Path "claude_output.tmp") {
            $content = Get-Content "claude_output.tmp" -Tail 10 -ErrorAction SilentlyContinue
            foreach ($line in $content) {
                Write-Host $line
                if (Test-ShouldNotify -Line $line) {
                    Send-Notification -Message $line
                }
            }
        }
        Start-Sleep -Milliseconds 500
    }
    
    # Final output
    if (Test-Path "claude_output.tmp") {
        Get-Content "claude_output.tmp"
        Remove-Item "claude_output.tmp" -ErrorAction SilentlyContinue
    }
    if (Test-Path "claude_error.tmp") {
        Get-Content "claude_error.tmp"
        Remove-Item "claude_error.tmp" -ErrorAction SilentlyContinue
    }
} catch {
    Write-Host "Error running Claude: $_" -ForegroundColor Red
    
    # Fallback: Run directly without monitoring
    Write-Host "Falling back to direct execution..." -ForegroundColor Yellow
    & claude $ClaudeArgs
}
