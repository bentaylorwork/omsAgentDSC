$configurationData = @{
	AllNodes = @(
		@{
			NodeName = '*'
			PSDscAllowPlainTextPassword = $true
		 }
		@{
			NodeName = 'localhost'
		 }
	)
}

Configuration omsAgent
{
	Import-DscResource –ModuleName PSDesiredStateConfiguration
	Import-DSCResource -ModuleName omsAgentInstall

	Node $AllNodes.NodeName {
		omsAgentInstall omsAgent
		{
			ensure     = 'Present'
			sourcePath = 'C:\install\MMASetup-AMD64.exe'
		}
	}
}

omsAgent -ConfigurationData $configurationData -Verbose
Start-DscConfiguration omsAgent -Wait -Verbose