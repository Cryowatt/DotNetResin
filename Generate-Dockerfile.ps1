$tags = @("2.0.5-runtime-stretch-arm32v7", "2.0-runtime-stretch-arm32v7", "2.0.5-runtime", "2.0-runtime", "2-runtime", "runtime")
$resinMachines = @('raspberry-pi','raspberry-pi2','beaglebone-black','intel-edison','intel-nuc','via-vab820-quad',
    'zc702-zynq7','odroid-c1','odroid-xu4','parallella','nitrogen6x','hummingboard','ts4900','colibri-imx6dl',
    'apalis-imx6q','ts7700','raspberrypi3','artik5','artik10','beaglebone-green-wifi','qemux86','qemux86-64',
    'beaglebone-green','cybertan-ze250','artik710','am571x-evm','up-board','kitra710','imx6ul-var-dart','kitra520',
    'jetson-tx2','iot2000','jetson-tx1')

$resinMachines | % {
    $resinMachine = $_   
    $depsImage = "cryowatt/$resinMachine-dotnet-deps"
    $runtimeImage = "cryowatt/$resinMachine-dotnet"

    New-Item -ItemType Directory -Path "devices\$resinMachine" -Force

    Get-Content -Path .\deps.Dockerfile | 
        ForEach-Object { $_ -replace "%%RESIN_MACHINE_NAME%%", $resinMachine} | 
        Set-Content -Path "devices\$resinMachine\deps.Dockerfile"

    Get-Content -Path .\runtime.Dockerfile | 
        ForEach-Object { $_ -replace "%%RESIN_MACHINE_NAME%%", $resinMachine} | 
        Set-Content -Path "devices\$resinMachine\runtime.Dockerfile"
}