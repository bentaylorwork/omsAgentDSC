enum Ensure
{
	Absent
	Present
}

[DscResource()]
class omsAgentProxy
{
	[DscProperty(Mandatory)]
	[Ensure]
	$ensure

	[DscProperty(Key)]
	[string]
	$Url

	[DscProperty()]
	[psCredential]
	$Credential

	# Sets OMS Agent Proxy desired state.
	[void] Set()
	{
		try 
		{
			if ($this.Ensure -eq [Ensure]::'Present') 
			{
				$this.setOmsAgentProxy()
			}
			else
			{
				$this.removeOmsAgentProxy()
			}
		}
		catch
		{
			Write-Error $_
		}
	}

	# Tests OMS Agent Proxy is in the DesiredState.
	[bool] Test()
	{

		$omsObj = $this.getOmsAgentObject()

		if ($this.Ensure -eq [Ensure]::Present)
		{
			$present = $false

			if($omsObj.proxyUrl -ne $this.url)
			{
				$present = $true

				if($this.Credential)
				{
					 if($omsObj.proxyUsername -ne $this.getUserNameFromCredential($this.Credential))
					 {
						$present = $false
					 }
				}
				else
				{
					if($omsObj.proxyUsername)
					{
						$present = $false
					}
				}
			}
		}
		else
		{
			if($omsObj.proxyUsername -or $omsObj.proxyUrl)
			{
				$present = $false
			}
			else
			{
				$present = $true
			}
		}

		return $present
	}

	# Gets OMS Agent Proxy current state.
	[omsAgentProxy] Get()
	{
		if ($this.testOmsAgentProxy()) 
		{
			$this.Ensure = [Ensure]::Present
		} 
		else 
		{
			$this.Ensure = [Ensure]::Absent
		}

		return $this
	}

	[void] setOmsAgentProxy()
	{
		Write-Verbose 'Setting OMS Agent Proxy'

		try
		{
			$omsObj = $this.getOmsAgentObject()
			$omsObj.setProxyUrl($this.Url)

			if($this.Credential)
			{
				$omsObj.SetProxyCredentials($this.getUserNameFromCredential($this.Credential), $this.getPlainPasswordFromCredential($this.Credential))
			}
			else
			{
				$omsObj.SetProxyCredentials('', '')
			}
		}
		Catch
		{
			Write-Error $_
		}
	}

	#removes the oms Agent Proxy URL and Credential
	[void] removeOmsAgentProxy()
	{
		Write-Verbose 'Removing OMS Agent Proxy'

		try
		{
			$omsObj = $this.getOmsAgentObject()
			$omsObj.SetProxyInfo('', '', '')
		}
		Catch
		{
			Write-Error $_
		}
	}

	# Create a OMS Agent WorkSpace Object
	[object] getOmsAgentObject()
	{
		try
		{
			return New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg' -ErrorAction Stop
		}
		Catch
		{
			Throw $_
		}
	}

	#convert a securestring to a plain text username
	[string] getUserNameFromCredential($secureStringToConvert)
	{
		return $secureStringToConvert.userName
	}

	#convert a securestring to a plain text password
	[string] getPlainPasswordFromCredential($secureStringToConvert)
	{
		return $secureStringToConvert.GetNetworkCredential().Password
	}
}