# omsAgent

## Requirements
* PowerShell Version 5
* Windows O\S

## Resources
* **omsAgentInstall**   Allows for easy installing and uninstalling of the OMS Agent.
* **omsAgentWorkSpace** Allows for easy adding and removing a OMS Agent workspace.
* **omsAgentProxy** Allows for the easy adding and removing of a proxy.

### omsAgentInstall
* **sourcePath** OMS Agent installer path
* **ensure**     Should the OMS Agent be installed

### omsAgentWorkSpace
* **workSpaceID**  OMS workspace ID
* **workSpaceKey** OMS workspace Key [pscredential] - Only password used
* **ensure**       Should the OMS Agent workspace exist

### omsAgentProxy
* **url**:       Proxy URL\IP - Correct Format: proxy.local:443 || Incorrect Format: https://proxy.local
* **credential** Proxy Credential if required
* **ensure**     Should the Proxy exist

## Versions

### 1.0.0.0
* Initial release with the following resources:
	* omsAgentInstall
	* omsAgentWorkSpace
	* omsAgentProxy

## Known Limitations
* No updating of OMS Agent workspace keys
* No updating of OMS Agent Proxy password without changing the User Name as well
* No tests implemented

## Contributors
* Ben Taylor