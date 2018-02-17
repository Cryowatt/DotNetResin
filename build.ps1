$tags = @("2.0.5-runtime-stretch-arm32v7", "2.0-runtime-stretch-arm32v7", "2.0.5-runtime", "2.0-runtime", "2-runtime", "runtime")
$resinMachines = @('raspberry-pi','raspberry-pi2','beaglebone-black','via-vab820-quad',
    'zc702-zynq7','odroid-c1','odroid-xu4','parallella','nitrogen6x','hummingboard','ts4900','colibri-imx6dl',
    'apalis-imx6q','ts7700','raspberrypi3','artik5','artik10','beaglebone-green-wifi',
    'beaglebone-green','artik710','am571x-evm','kitra710','imx6ul-var-dart','kitra520')

$resinMachines | % {
    $resinMachine = $_   
    $depsImage = "cryowatt/$resinMachine-dotnet-deps"
    $runtimeImage = "cryowatt/$resinMachine-dotnet"

    docker build --file deps.DockerFile --tag $depsImage --build-arg RESIN_MACHINE_NAME=$resinMachine .
    docker build --file runtime.DockerFile --tag $runtimeImage --build-arg DEPS_IMAGE=$depsImage .

    $tags | % { 
        docker tag $depsImage ${depsImage}:$_
        docker push ${depsImage}:$_
        docker tag $runtimeImage ${runtimeImage}:$_
        docker push ${runtimeImage}:$_
    }
}