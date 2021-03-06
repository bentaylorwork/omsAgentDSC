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
	Import-DSCResource -ModuleName omsAgentProxy

	Node $AllNodes.NodeName {
		omsAgentProxy proxy
		{
			ensure       = 'Present'
			url          = 'https://proxy.local'
		}
	}
}

omsAgent -ConfigurationData $configurationData -Verbose
Start-DscConfiguration omsAgent -Wait -Verbose