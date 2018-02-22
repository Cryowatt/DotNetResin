[cmdletbinding()]
param($Jwt)

$resinMachines = @(
    'raspberry-pi2','raspberrypi3','beaglebone-black','beaglebone-green','beaglebone-green-wifi','via-vab820-quad',
    'zynq-xz702','odroid-c1','odroid-xu4','parallella','nitrogen6x','hummingboard','colibri-imx6dl','apalis-imx6q',
    'ts4900','artik5','artik10','artik710','kitra710','imx6ul-var-dart','am571x-evm','kitra520','jetson-tx2')

$resinMachines | ForEach-Object {
    $ResinMachineName = $_
    $jobBody = $ExecutionContext.InvokeCommand.ExpandString((Get-Content .\AutomatedBuild.json | Out-String))
    #Invoke-RestMethod -Headers @{Authorization = "JWT $jwt"} -Method Delete https://hub.docker.com/v2/repositories/cryowatt/$ResinMachineName-dotnet/
    $jobBody -replace "`r|`n|`t|\s{2,}", ""
    Invoke-RestMethod -Headers @{Authorization = "JWT $jwt"} -Method Post -ContentType "application/json" https://hub.docker.com/v2/repositories/cryowatt/$ResinMachineName-dotnet/autobuild/ -Body $jobBody
}