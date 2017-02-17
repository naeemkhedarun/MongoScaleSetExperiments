chrConfiguration Main
{

Param ( [string] $nodeName )

Import-DscResource -ModuleName PSDesiredStateConfiguration

Node $nodeName
  {
   <# This commented section represents an example configuration that can be updated as required.
    WindowsFeature WebServerRole
    {
      Name = "Web-Server"
      Ensure = "Present"
    }
    WindowsFeature WebManagementConsole
    {
      Name = "Web-Mgmt-Console"
      Ensure = "Present"
    }
    WindowsFeature WebManagementService
    {
      Name = "Web-Mgmt-Service"
      Ensure = "Present"
    }
    WindowsFeature ASPNet45
    {
      Name = "Web-Asp-Net45"
      Ensure = "Present"
    }
    WindowsFeature HTTPRedirection
    {
      Name = "Web-Http-Redirect"
      Ensure = "Present"
    }
    WindowsFeature CustomLogging
    {
      Name = "Web-Custom-Logging"
      Ensure = "Present"
    }
    WindowsFeature LogginTools
    {
      Name = "Web-Log-Libraries"
      Ensure = "Present"
    }
    WindowsFeature RequestMonitor
    {
      Name = "Web-Request-Monitor"
      Ensure = "Present"
    }
    WindowsFeature Tracing
    {
      Name = "Web-Http-Tracing"
      Ensure = "Present"
    }
    WindowsFeature BasicAuthentication
    {
      Name = "Web-Basic-Auth"
      Ensure = "Present"
    }
    WindowsFeature WindowsAuthentication
    {
      Name = "Web-Windows-Auth"
      Ensure = "Present"
    }
    WindowsFeature ApplicationInitialization
    {
      Name = "Web-AppInit"
      Ensure = "Present"
    }
    Script DownloadWebDeploy
    {
        TestScript = {
            Test-Path "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
        }
        SetScript ={
            $source = "https://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi"
            $dest = "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
            Invoke-WebRequest $source -OutFile $dest
        }
        GetScript = {@{Result = "DownloadWebDeploy"}}
        DependsOn = "[WindowsFeature]WebServerRole"
    }
    Package InstallWebDeploy
    {
        Ensure = "Present"  
        Path  = "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
        Name = "Microsoft Web Deploy 3.6"
        ProductId = "{ED4CC1E5-043E-4157-8452-B5E533FE2BA1}"
        Arguments = "ADDLOCAL=ALL"
        DependsOn = "[Script]DownloadWebDeploy"
    }
    Service StartWebDeploy
    {                    
        Name = "WMSVC"
        StartupType = "Automatic"
        State = "Running"
        DependsOn = "[Package]InstallWebDeploy"
    } #>

	Script DownLoadMongoMsi
    {
        TestScript = {
            Test-Path "C:\mongodb-win32-x86_64-2008plus-ssl-3.4.1-signed.msi"
        }
        SetScript ={
            $source = "https://fastdl.mongodb.org/win32/mongodb-win32-x86_64-2008plus-ssl-3.4.1-signed.msi"
            $dest = "C:\mongodb-win32-x86_64-2008plus-ssl-3.4.1-signed.msi"
            Invoke-WebRequest $source -OutFile $dest
        }
        GetScript = {@{Result = "DownloadWebDeploy"}}
	}

	Script InstallMongo
    {
        TestScript = {
            (get-service MongoDB -ErrorAction silentlyContinue) -ne $null
        }
        SetScript ={            
            $source = "C:\mongodb-win32-x86_64-2008plus-ssl-3.4.1-signed.msi"
            Start-Process C:\Windows\System32\msiexec.exe -ArgumentList @("/q", "/i C:\mongodb-win32-x86_64-2008plus-ssl-3.4.1-signed.msi", 'INSTALLLOCATION="C:\Program Files\MongoDB\Server\3.4.1\"', "ADDLOCAL=all") -wait
			mkdir c:\data\db
			mkdir c:\data\log
			Set-Content -Path C:\mongod.cfg -Value @"
systemLog:
    destination: file
    path: c:\data\log\mongod.log
storage:
    dbPath: c:\data\db
"@
			& "C:\Program Files\MongoDB\Server\3.4.1\bin\mongod.exe" --config "C:\mongod.cfg" --install
        }
        GetScript = {@{Result = "DownloadWebDeploy"}}
		DependsOn = "[Script]DownLoadMongoMsi"
	}
	  
Service StartMongo
    {                    
        Name = "MongoDB"
        StartupType = "Automatic"
        State = "Running"
        DependsOn = "[Script]InstallMongo"
    }
  }
}