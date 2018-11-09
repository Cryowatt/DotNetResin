[cmdletbinding()]
param(
    # Resin device name
    [Parameter(Mandatory = $true)]
    [string]
    $DeviceName)

Write-Progress -Activity "Building resin docker containers." -CurrentOperation "Downloading releases metadata." -Id 1
$releases = Invoke-RestMethod https://raw.githubusercontent.com/dotnet/core/master/release-notes/releases.json
$releases = $releases | Where-Object { $_.'runtime-linux-arm-x32' -ne $null }
$releaseCount = 0
$versions = @{}
$versionPrefix = "cryowatt/resin-dotnet:$DeviceName"

docker pull resin/${DEVICE_NAME}-debian:stretch

foreach($release in $releases) {
    $version = [System.Management.Automation.SemanticVersion]$release.'version-runtime'
    $versionTag = "$versionPrefix-$version"
    $downloadBlob = [uri]::new([uri]$release.'blob-runtime', $($release.'runtime-linux-arm-x32'))
    $percentDone = (($releaseCount++ / $releases.Count) * 100)
    Write-Progress -Activity "Building resin docker containers." -Status "$releaseCount/$($releases.Count) ($([int]$percentDone)%)" -Id 1 -PercentComplete $percentDone
    
    if (-not $TagOnly) {
        Write-Progress -Activity "Building container for dotnet $versionTag" -CurrentOperation "Downloading checksums" -ParentId 1
        $checksums = Invoke-RestMethod $release.'checksums-runtime'
        if($checksums -match "(?<SHA>[a-f0-9]{128})\s+dotnet-runtime-.*?-linux-arm.tar.gz") {
            $dotnetChecksum = $Matches["SHA"]
        }
        else{
            throw "Checksum not found."
        }

        Write-Progress -Activity "Building container for dotnet $versionTag" -CurrentOperation "Building container" -ParentId 1

        Write-Verbose DEVICE_NAME=$DeviceName 
        Write-Verbose DOTNET_VERSION=$version
        Write-Verbose DOTNET_PACKAGE=$downloadBlob
        Write-Verbose DOTNET_SHA512=$dotnetChecksum
        docker pull $versionTag | Write-Verbose
        docker build `
            --cache-from $versionTag `
            --build-arg DEVICE_NAME=$DeviceName `
            --build-arg DOTNET_VERSION=$version `
            --build-arg DOTNET_PACKAGE=$downloadBlob `
            --build-arg DOTNET_SHA512=$dotnetChecksum `
            --tag $versionTag `
            . | Write-Verbose

        Write-Progress -Activity "Building container for dotnet $versionTag" -CurrentOperation "Pushing container" -ParentId 1
		docker push $versionTag

        if (-not $?) {
            throw "Failed to build container $versionTag"
        }
    }

    $versions.Add($version, $versionTag)
}

### Tag latest release majors
Write-Progress -Activity "Tagging major versions" -ParentId 1

$versions.Keys | Group-Object -Property Major | ForEach-Object {
    $topVersion = $_.Group | Where-Object { $_.PreReleaseLabel -eq $null } | Sort-Object -Descending | Select-Object -First 1

    if($topVersion -eq $null) {
        $topVersion = $_.Group | Sort-Object -Descending | Select-Object -First 1      
    }
    
    Write-Verbose "Tagging $($versions[$topVersion]) <- $versionPrefix-$($topVersion.Major)"
    docker tag $($versions[$topVersion]) $versionPrefix-$($topVersion.Major) | Write-Verbose
	docker push $versionPrefix-$($topVersion.Major)
    
    if (-not $?) {
        throw "Tagging failed $($versions[$topVersion]) <- $versionPrefix-$($topVersion.Major)"
    }
}

### Tag latest release minors
Write-Progress -Activity "Tagging minor versions" -ParentId 1

$versions.Keys | Group-Object -Property Major, Minor | ForEach-Object {
    $topVersion = $_.Group | Where-Object { $_.PreReleaseLabel -eq $null } | Sort-Object -Descending | Select-Object -First 1

    if($topVersion -eq $null) {
        $topVersion = $_.Group | Sort-Object -Descending | Select-Object -First 1      
    }
    
    Write-Verbose "Tagging $($versions[$topVersion]) <- $versionPrefix-$($topVersion.Major).$($topVersion.Minor)"
    docker tag $versions[$topVersion] $versionPrefix-$($topVersion.Major).$($topVersion.Minor)
	docker push $versionPrefix-$($topVersion.Major).$($topVersion.Minor)
    
    if (-not $?) {
        throw "Tagging failed $($versions[$topVersion]) <- $versionPrefix-$($topVersion.Major).$($topVersion.Minor)"
    }
}

### Tag latest release
Write-Progress -Activity "Tagging latest version" -ParentId 1

$topVersion = $versions.Keys | Where-Object { $_.PreReleaseLabel -eq $null } | Sort-Object -Descending | Select-Object -First 1
if($null -eq $topVersion) {
    $topVersion = $_.Group | Sort-Object -Descending | Select-Object -First 1      
}

Write-Verbose "Tagging $($versions[$topVersion]) <- $versionPrefix"
docker tag $versions[$topVersion] $versionPrefix
docker push $versionPrefix

if (-not $?) {
    throw "Tagging failed $($versions[$topVersion]) <- $versionPrefix"
}