$tags = @("2.0.5-runtime-stretch-arm32v7", "2.0-runtime-stretch-arm32v7", "2.0.5-runtime", "2.0-runtime", "2-runtime", "runtime")
$resinMachines = @('raspberry-pi','raspberry-pi2','beaglebone-black','intel-edison','intel-nuc','via-vab820-quad',
    'zc702-zynq7','odroid-c1','odroid-xu4','parallella','nitrogen6x','hummingboard','ts4900','colibri-imx6dl',
    'apalis-imx6q','ts7700','raspberrypi3','artik5','artik10','beaglebone-green-wifi','qemux86','qemux86-64',
    'beaglebone-green','cybertan-ze250','artik710','am571x-evm','up-board','kitra710','imx6ul-var-dart','kitra520',
    'jetson-tx2','iot2000','jetson-tx1')

$resinMachines | % {
    $ResinMachineName = $_
    $depsImage = "cryowatt/$ResinMachineName-dotnet-deps"
    $runtimeImage = "cryowatt/$ResinMachineName-dotnet"

    New-Item -ItemType Directory -Path "devices\$ResinMachineName" -Force

    $ExecutionContext.InvokeCommand.ExpandString((Get-Content .\deps.Dockerfile | Out-String)) |
        Set-Content -Path "devices\$ResinMachineName\deps.Dockerfile"

        $ExecutionContext.InvokeCommand.ExpandString((Get-Content .\runtime.Dockerfile | Out-String)) |
        Set-Content -Path "devices\$ResinMachineName\runtime.Dockerfile"
}