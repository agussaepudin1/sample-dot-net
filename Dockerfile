# Use the official image as a parent image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Use the SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["MvcMovie.csproj", "./"]
RUN dotnet restore "MvcMovie.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "MvcMovie.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "MvcMovie.csproj" -c Release -o /app/publish

# Use the base image to run the app
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY certs/cert.pfx /https/cert.pfx

ENV ASPNETCORE_URLS=https://+:443;http://+:80
ENV ASPNETCORE_Kestrel__Certificates__Default__Password=""
ENV ASPNETCORE_Kestrel__Certificates__Default__Path=/https/cert.pfx

ENTRYPOINT ["dotnet", "MvcMovie.dll"]
