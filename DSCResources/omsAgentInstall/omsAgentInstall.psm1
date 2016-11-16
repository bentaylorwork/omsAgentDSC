enum Ensure
{
	Absent
	Present
}

[DscResource()]
class omsAgentInstall
{
	[DscProperty(Key)]
	[string]
	$sourcePath

	[DscProperty(Mandatory)]
	[Ensure]
	$ensure

	# Sets OMS Agent desired state.
	[void] Set()
	{
		$isOmsAgentInstalled = $this.testOmsAgentInstall()

		Try 
		{
			if ($this.Ensure -eq [Ensure]::'Present') 
			{
				if (-not $isOmsAgentInstalled) 
				{
					$this.installOmsAgent()
				}
			}
			else
			{
				if ($isOmsAgentInstalled) 
				{
					$this.removeOmsAgent()
				}
			}
		}
		Catch
		{
			Write-Verbose $_
		}
	}

	# Tests OMS Agent Install is in the DesiredState.
	[bool] Test()
	{
		$present = $this.testOmsAgentInstall()

		if ($this.Ensure -eq [Ensure]::Present)
		{
			return $present
		}
		else
		{
			return -not $present
		}
	}

	# Gets OMS Agent Install current state.
	[omsAgentInstall] Get()
	{
		if ($this.testOmsAgentInstall()) 
		{
			$this.Ensure = [Ensure]::Present
		} 
		else 
		{
			$this.Ensure = [Ensure]::Absent
		}

		return $this
	}

	#Installing Oms Agent
	[void] installOmsAgent()
	{
		Write-Verbose 'Installing OMS Agent'

		Start-Process $this.sourcePath -ArgumentList '/C:"setup.exe /qn AcceptEndUserLicenseAgreement=1"' -Wait
	}

	#Removing Oms Agent
	[void] removeOmsAgent()
	{
		Write-Verbose 'Un-installing OMS Agent'

		$omsAgent = $this.getRegistryUninstall()

		$msiArgs = @(
			"/X"
			($omsAgent).ToLower().Replace("/i", "").Replace("msiexec.exe", "")
			"/qn"
		)

		Start-Process 'msiexec.exe' -ArgumentList $msiArgs -Wait
	}

	[string] getRegistryUninstall() {
		$registryUninstallKey = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'

		if($env:PROCESSOR_ARCHITECTURE -eq 'x86')
		{
			$registryUninstallKey = 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
		}

		$unInstallString = Get-ItemProperty $registryUninstallKey | Where-Object { $_.displayName -eq 'Microsoft Monitoring Agent' } | Select-Object -ExpandProperty UninstallString

		if($unInstallstring)
		{
			return $unInstallString
		}

		return [string]::Empty
	}

	[boolean] testOmsAgentInstall() {
		$isInstalled = $false	

		if($this.getRegistryUninstall())
		{
			$isInstalled = $true
		}

		return $isInstalled
	}
}