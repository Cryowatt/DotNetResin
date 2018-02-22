$resinMachines = @(
    'raspberry-pi2','raspberrypi3','beaglebone-black','beaglebone-green','beaglebone-green-wifi','via-vab820-quad',
    'zynq-xz702','odroid-c1','odroid-xu4','parallella','nitrogen6x','hummingboard','colibri-imx6dl','apalis-imx6q',
    'ts4900','artik5','artik10','artik710','kitra710','imx6ul-var-dart','am571x-evm','kitra520','jetson-tx2')

$resinMachines | % {
    $ResinMachineName = $_
    New-Item -ItemType Directory -Path "devices\$ResinMachineName" -Force

    $ExecutionContext.InvokeCommand.ExpandString((Get-Content .\deps.Dockerfile | Out-String)) |
        Set-Content -Path "devices\$ResinMachineName\deps.Dockerfile"

        $ExecutionContext.InvokeCommand.ExpandString((Get-Content .\runtime.Dockerfile | Out-String)) |
        Set-Content -Path "devices\$ResinMachineName\runtime.Dockerfile"
}