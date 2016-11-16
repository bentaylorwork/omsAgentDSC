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
	Import-DSCResource -ModuleName omsAgentWorkSpace
	Import-DSCResource -ModuleName omsAgentProxy

	Node $AllNodes.NodeName {
		omsAgentInstall Agent
		{
			ensure     = 'Present'
			sourcePath = 'C:\install\MMASetup-AMD64.exe'
		}

		omsAgentWorkSpace WorkSpace
		{
			ensure       = 'Present'
			workSpaceID  = '12323123-345345gdfgdfg-dfgdfg34-3434gdg-dfgdfg'
			workSpaceKey = Get-Credential -Message 'Work Space Key' -UserName 'workSpaceKey'
			dependsOn    = '[omsAgentInstall]Agent'
		}

		omsAgentProxy proxy
		{
			ensure       = 'Present'
			url          = 'proxy.local:443'
			credential   = Get-Credential -Message 'OMS Agent Proxy Credential'
			dependsOn    = '[omsAgentInstall]Agent'
		}
	}
}

omsAgent -ConfigurationData $configurationData -Verbose
Start-DscConfiguration omsAgent -Wait -Verbose