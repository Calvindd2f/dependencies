$dll = "logutil.dll";
$dllPath=(get-item$dll).FullName;
$dllPath=[regex]::replace($dllPath,'\\','\\');

$typeDefinition = @"
using System;
using System.Runtime.InteropServices;

public static class LogUtil
{
    [DllImport("$dllPath", CallingConvention = CallingConvention.Cdecl)]
    public static extern bool LogInfo(string shortMessage, bool detailedDescription);

    [DllImport("$dllPath", CallingConvention = CallingConvention.Cdecl)]
    public static extern bool LogError(string shortMessage, bool detailedDescription);

    [DllImport("$dllPath", CallingConvention = CallingConvention.Cdecl)]
    public static extern bool LogWarning(string shortMessage, bool detailedDescription);

    [DllImport("$dllPath", CallingConvention = CallingConvention.Cdecl)]
    public static extern bool LogVerbose(string shortMessage, bool detailedDescription);

    [DllImport("$dllPath", CallingConvention = CallingConvention.Cdecl)]
    public static extern bool LogDebug(string shortMessage, bool detailedDescription);
}
"@
Add-Type -TypeDefinition $typeDefinition -Language CSharp

function Test-LoggingPerformance {
    param (
        [int]$iterations = 100  # Number of log entries to generate for each method
    )

    $sampleMessages = 1..$iterations | ForEach-Object { "Test message $_" }

    $writeHostTime = Measure-Command {
        foreach ($msg in $sampleMessages) {
            Write-Host $msg -ForegroundColor Yellow
        }
    }

    if ($PSVersionTable.PSEdition -eq 'Core') {
        $consoleWriteTime = Measure-Command {
            foreach ($msg in $sampleMessages) {
                [Console]::WriteLine($msg)
            }
        }
    } else {
        $consoleWriteTime = "Not applicable in Windows PowerShell"
    }

    $loggerTime = Measure-Command {
        foreach ($msg in $sampleMessages) {
            [Logger]::LogInfo($msg, $false)
        }
    }

    Write-Output "Execution time for logging $iterations entries:"
    Write-Output "Write-Host: $($writeHostTime.TotalMilliseconds) ms"
    #if ($consoleWriteTime -is [System.Diagnostics.Stopwatch]) {
        Write-Output "Console.WriteLine: $($consoleWriteTime.TotalMilliseconds) ms"
    #} else {
        #Write-Output "Console.WriteLine: $consoleWriteTime"
    #}
    Write-Output "[Logger]::LogInfo: $($loggerTime.TotalMilliseconds) ms"
}
Test-LoggingPerformance -iterations 100
