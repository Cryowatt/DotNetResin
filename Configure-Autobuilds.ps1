[cmdletbinding()]
param($Jwt)

$resinMachines = @('raspberry-pi','raspberry-pi2','beaglebone-black','intel-edison','intel-nuc','via-vab820-quad',
    'zc702-zynq7','odroid-c1','odroid-xu4','parallella','nitrogen6x','hummingboard','ts4900','colibri-imx6dl',
    'apalis-imx6q','ts7700','raspberrypi3','artik5','artik10','beaglebone-green-wifi','qemux86','qemux86-64',
    'beaglebone-green','cybertan-ze250','artik710','am571x-evm','up-board','kitra710','imx6ul-var-dart','kitra520',
    'jetson-tx2','iot2000','jetson-tx1')

$resinMachines | ForEach-Object {
    $ResinMachineName = $_
    Invoke-RestMethod -Headers @{Authorization = "JWT $jwt"} -Method Delete https://hub.docker.com/v2/repositories/cryowatt/$ResinMachineName-dotnet-deps/
    Invoke-RestMethod -Headers @{Authorization = "JWT $jwt"} -Method Delete https://hub.docker.com/v2/repositories/cryowatt/$ResinMachineName-dotnet/ 
    $ImageSuffix = "dotnet-deps"
    $DockerFile = "deps.Dockerfile"
    $jobBody = $ExecutionContext.InvokeCommand.ExpandString((Get-Content .\AutomatedBuild.json | Out-String))
    $jobBody
    Invoke-RestMethod -Headers @{Authorization = "JWT $jwt"} -Method Post -ContentType "application/json" https://hub.docker.com/v2/repositories/cryowatt/raspberry-pi-dotnet/autobuild/ -Body $jobBody
}