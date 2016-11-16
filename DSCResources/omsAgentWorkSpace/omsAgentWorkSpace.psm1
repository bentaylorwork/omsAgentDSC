enum Ensure
{
	Absent
	Present
}

[DscResource()]
class omsAgentWorkSpace
{
	[DscProperty(Mandatory)]
	[Ensure]
	$ensure

	[DscProperty(Key)]
	[string]
	$workSpaceID

	[DscProperty(Mandatory)]
	[psCredential]
	$workSpaceKey

	# Sets OMS Agent WorkSpace desired state.
	[void] Set()
	{
		try 
		{
			if ($this.Ensure -eq [Ensure]::'Present') 
			{
				$this.addOmsAgentWorkSpace()
			}
			else
			{
				$this.removeOmsAgentWorkSpace()
			}
		}
		catch
		{
			Write-Error $_
		}
	}

	# Tests OMS Agent WorkSpace is in the DesiredState.
	[bool] Test()
	{
		$present = $this.testOmsAgentWorkSpace()

		if ($this.Ensure -eq [Ensure]::Present)
		{
			return $present
		}
		else
		{
			return -not $present
		}
	}

	# Gets OMS Agent WorkSpace current state.
	[omsAgentWorkSpace] Get()
	{
		if ($this.testOmsAgentWorkSpace) 
		{
			$this.Ensure = [Ensure]::Present
		} 
		else 
		{
			$this.Ensure = [Ensure]::Absent
		}

		return $this
	}

	[void] addOmsAgentWorkSpace()
	{
		Write-Verbose 'Adding OMS Agent Work Space'

		try
		{
			if(-not ($this.testOmsAgentWorkSpace()))
			{
				$omsObj = $this.getOmsAgentObject()
				$omsObj.AddCloudWorkspace($this.workSpaceID, ($this.getPlainPasswordFromCredential($this.workSpaceKey)))
				$omsObj.ReloadConfiguration()

				if($this.testOmsAgentWorkSpace())
				{
					Write-Verbose 'OMS workspace added succesfully'
				}
				else 
				{
					Write-Error 'OMS workspace not added correctly'
				}

			} else {
				Write-Error 'Workspace allready exists. WorkSpace key has to be unique.'
			}
		}
		Catch
		{
			Write-Error $_
		}
	}

	[void] removeOmsAgentWorkSpace()
	{
		Write-Verbose 'Removing OMS Agent Work Space'

		try
		{
			if($this.testOmsAgentWorkSpace())
			{
				Write-Verbose 'Removing OMS Workspace'

				$omsObj = $this.getOmsAgentObject()
				$omsObj.RemoveCloudWorkspace($this.workSpaceID)

				#To Get around $omsObj.ReloadConfiguration() hanging when no work-spaces remaining
				if('' -ne $omsObj.GetCloudWorkspaces())
				{
					$omsObj.ReloadConfiguration()
				}

				
				if($this.testOmsAgentWorkSpace())
				{
					Write-Error 'OMS workspace not removed correctly'
				}
				else 
				{
					Write-Verbose 'OMS workspace removed succesfully'
				}
			}
			else
			{
				Write-Verbose 'No OMS Workspace found so in correct state'
			}
		}
		Catch
		{
			Write-Error $_
		}
	}

	#Testing testOmsAgentWorkSpace
	[bool] testOmsAgentWorkSpace()
	{
		$present = $true

		$omsObj = $this.getOmsAgentObject()
		$isOmsWorkSpace = $omsObj.GetCloudWorkspace($this.workSpaceID)

		if (-not $isOmsWorkSpace)
		{
			$present = $false
		}

		return $present
	}

	# Create a OMS Agent WorkSpace Object
	[object] getOmsAgentObject() {
		try
		{
			return New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg' -ErrorAction Stop
		}
		Catch
		{
			Throw $_
		}
	}

	#convert a securestring to a plain text password
	[string] getPlainPasswordFromCredential($secureStringToConvert)
	{
		return $secureStringToConvert.GetNetworkCredential().Password
	}
}