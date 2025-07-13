#!rsc by RouterOS
# RouterOS script: duckdns-update
# default-interval=5m
# Updates Duck DNS with the current WAN IP
# Copyright (c) 2023-2025 DakingRT

:global GlobalFunctionsReady
:while ($GlobalFunctionsReady != true) do={ :delay 200ms }

:global GlobalConfigReady
:while ($GlobalConfigReady != true) do={ :delay 200ms }

# Variables definidas por el usuario en el overlay
:global DuckDnsWanInterface
:global DuckDnsDomain
:global DuckDnsToken

:local ScriptName "duckdns-update"
:global SendNotification2
:global SymbolForNotification
:global LogPrint

:local resFile "duckdns-result.txt"
:local ipFile  "ipstore.txt"

# Obtener IP actual
:local ip [/ip/address/get [find where interface=$DuckDnsWanInterface] value-name=address]
:set ip [:pick $ip -1 [:find $ip "/" -1]]

# Crear ipstore.txt si no existe
:if ([/file/print count-only where name=$ipFile] = 0) do={
    /file/print file=$ipFile
    :delay 1
    /file/set [/file/find name=$ipFile] contents="0.0.0.0"
}

:local old [/file/get [/file/find name=$ipFile] contents]

:if ($ip != $old) do={
    $LogPrint info $ScriptName ("Duck DNS: " . $old . " -> " . $ip)

    /tool/fetch mode=https host=www.duckdns.org port=443 keep-result=yes \
        dst-path=$resFile \
        src-path=("/update?domains=$DuckDnsDomain&token=$DuckDnsToken&ip=" . $ip)

    :delay 4
    :local api [/file/get [/file/find name=$resFile] contents]
    /file/remove $resFile
    /file/set [/file/find name=$ipFile] contents=$ip

    :local msg ($api = "OK" ? ("Duck DNS updated to " . $ip) : ("Duck DNS update FAILED (" . $api . ")"))
    $LogPrint info $ScriptName $msg
    $SendNotification2 ({
        origin   = $ScriptName;
        subject  = ([$SymbolForNotification "earth"] . " Duck DNS");
        message  = $msg . "\n";
        silent   = true })
}
