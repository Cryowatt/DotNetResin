#### RUNTIME DEPS ####
ARG DEVICE_NAME
FROM resin/${DEVICE_NAME}-debian:stretch AS runtime-deps

RUN [ "cross-build-start" ]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \   
        \
# .NET Core dependencies
        libc6 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu57 \
        liblttng-ust0 \
        libssl1.0.2 \
        libstdc++6 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Configure Kestrel web server to bind to port 80 when present
ENV ASPNETCORE_URLS=http://+:80 \
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true
RUN [ "cross-build-end" ]


#### RUNTIME ####
FROM runtime-deps AS runtime

RUN [ "cross-build-start" ]
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Install .NET Core
ARG DOTNET_VERSION
ARG DOTNET_PACKAGE
ARG DOTNET_SHA512
ENV DOTNET_VERSION ${DOTNET_VERSION}
ENV DOTNET_PACKAGE ${DOTNET_PACKAGE}
ENV DOTNET_SHA512 ${DOTNET_SHA512}

RUN curl -SL --output dotnet.tar.gz ${DOTNET_PACKAGE} \
    && echo "${DOTNET_SHA512} dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
RUN [ "cross-build-end" ]
