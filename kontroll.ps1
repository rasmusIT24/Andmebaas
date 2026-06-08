# =================================================================================
# KURSUSE PROGRESSI RAPORT - AUTOMAATKONTROLLI SKRIPT KOOS HTML SALVESTAMISEGA
# Tulemus kuvatakse konsoolis ja salvestatakse visuaalse HTML-failina töölauale.
# =================================================================================

# --- Kasutaja seadistused ---
$OodatavServeriNimi = "AD1"
$OodatavIPMuster    = '^10\.0\.\d{1,3}\.10$' 
$OodatavDomeenMuster = "^(ojala\.forest|test\.local)$" 

# Dünaamiline domeeninime tuvastus serverist
$TegelikDomeen = (Get-WmiObject Win32_ComputerSystem).Domain
$PraeguneNimi = $env:COMPUTERNAME

# Faili salvestamise asukoht (Töölaud)
$Toolaud = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$HtmlFailiTee = [System.IO.Path]::Combine($Toolaud, "Kursuse_progressi_raport.html")

# Raporti massiiv tulemuste kogumiseks
$Raport = @()

# Abifunktsioon tulemuste lisamiseks
function Lisa-Tulemus ($Kategooria, $Kontroll, $Staatus, $Detailid) {
    $Objekt = [PSCustomObject]@{
        'Kategooria'         = $Kategooria
        'Kontrollitav punkt' = $Kontroll
        'Staatus'            = $Staatus
        'Detailid'           = $Detailid
    }
    $script:Raport += $Objekt
}

# ---------------------------------------------------------------------------------
# 1. BAASVÕRK JA DOMEEN
# ---------------------------------------------------------------------------------
$Kat = "Baasvõrk ja domeen"

if ($PraeguneNimi -ieq $OodatavServeriNimi) {
    Lisa-Tulemus $Kat "Serveri nimi on AD1" "TEHTUD" "Nimi on korras ($PraeguneNimi)"
} else {
    Lisa-Tulemus $Kat "Serveri nimi on AD1" "TEGEMATA" "Praegune nimi: $PraeguneNimi"
}

$IPAadressid = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceComponentType Hardware).IPAddress
$IPSobib = $false
$LeitudIP = ""
foreach ($IP in $IPAadressid) {
    if ($IP -match $OodatavIPMuster) { $IPSobib = $true; $LeitudIP = $IP; break }
}
if ($IPSobib) {
    Lisa-Tulemus $Kat "IP-aadress on 10.0.XXX.10" "TEHTUD" "Leitud IP: $LeitudIP"
} else {
    Lisa-Tulemus $Kat "IP-aadress on 10.0.XXX.10" "TEGEMATA" "Leitud IP-d: ($($IPAadressid -join ', '))"
}

if ($TegelikDomeen -match $OodatavDomeenMuster) {
    Lisa-Tulemus $Kat "Domeen on kättesaadav" "TEHTUD" "Domeen: $TegelikDomeen"
} else {
    Lisa-Tulemus $Kat "Domeen on kättesaadav" "TEGEMATA" "Tuvastatud domeen: $TegelikDomeen (ootasime ojala.forest või test.local)"
}

# ---------------------------------------------------------------------------------
# 2. ACTIVE DIRECTORY STRUKTUUR (OU-d ja Grupid)
# ---------------------------------------------------------------------------------
$Kat = "AD Struktuur"
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

if (Get-Module ActiveDirectory) {
    $Oud = @("KASUTAJAD", "LEKTORID", "TUDENGID", "ARVUTID")
    foreach ($OU in $Oud) {
        $LeitudOU = Get-ADOrganizationalUnit -Filter "Name -eq '$OU'" -ErrorAction SilentlyContinue
        if ($LeitudOU) { Lisa-Tulemus $Kat "OU $OU olemasolu" "TEHTUD" "Leitud" }
        else { Lisa-Tulemus $Kat "OU $OU olemasolu" "TEGEMATA" "Puudub" }
    }

    $Grupid = @("Lektorid", "Tudengid", "RedirectedDirectories")
    foreach ($Grupp in $Grupid) {
        $LeitudGrupp = Get-ADGroup -Filter "Name -eq '$Grupp'" -ErrorAction SilentlyContinue
        if ($LeitudGrupp) { Lisa-Tulemus $Kat "Grupp $Grupp loodud" "TEHTUD" "Leitud" }
        else { Lisa-Tulemus $Kat "Grupp $Grupp loodud" "TEGEMATA" "Puudub" }
    }
} else {
    Lisa-Tulemus $Kat "AD kontroll" "TEGEMATA" "ActiveDirectory moodul pole saadaval"
}

# ---------------------------------------------------------------------------------
# 3. KASUTAJAD JA KUULUVUS
# ---------------------------------------------------------------------------------
$Kat = "Kasutajad"
if (Get-Module ActiveDirectory) {
    $Kasutajakontrollid = @(
        @{Nimi="oppejoud1"; Grupp="Lektorid"},
        @{Nimi="oppejoud2"; Grupp="Lektorid"},
        @{Nimi="tudeng1"; Grupp="Tudengid"},
        @{Nimi="tudeng2"; Grupp="Tudengid"}
    )

    foreach ($K in $Kasutajakontrollid) {
        $U = Get-ADUser -Filter "SamAccountName -eq '$($K.Nimi)'" -ErrorAction SilentlyContinue
        if ($U) {
            $Grupid = Get-ADPrincipalGroupMembership $U | Select-Object -ExpandProperty Name
            if ($Grupid -contains $K.Grupp) {
                Lisa-Tulemus $Kat "Kasutaja $($K.Nimi)" "TEHTUD" "Olemas ja grupis $($K.Grupp)"
            } else {
                Lisa-Tulemus $Kat "Kasutaja $($K.Nimi)" "TEGEMATA" "Puudub grupist $($K.Grupp)"
            }
        } else {
            Lisa-Tulemus $Kat "Kasutaja $($K.Nimi)" "TEGEMATA" "Kasutajat ei eksisteeri"
        }
    }
}

# ---------------------------------------------------------------------------------
# 4. SERVERI ROLLID JA TEENUSED
# ---------------------------------------------------------------------------------
$Kat = "Serveri rollid"
$Rollid = @(
    @{Nimi="AD-Domain-Services"; Kuva="Active Directory"},
    @{Nimi="DHCP"; Kuva="DHCP Server"},
    @{Nimi="DNS"; Kuva="DNS Server"},
    @{Nimi="WDS"; Kuva="Windows Deployment Services"},
    @{Nimi="Web-Server"; Kuva="IIS Web Server"}
)

foreach ($R in $Rollid) {
    $Feature = Get-WindowsFeature -Name $R.Nimi -ErrorAction SilentlyContinue
    if ($Feature -and $Feature.Installed) {
        Lisa-Tulemus $Kat "Roll $($R.Kuva) paigaldatud" "TEHTUD" "Paigaldatud"
    } else {
        Lisa-Tulemus $Kat "Roll $($R.Kuva) paigaldatud" "TEGEMATA" "Puudu"
    }
}

if (Get-Command Get-DhcpServerv4Scope -ErrorAction SilentlyContinue) {
    $Skoop = Get-DhcpServerv4Scope | Where-Object {$_.Name -eq "HKHK"} -ErrorAction SilentlyContinue
    if ($Skoop) {
        Lisa-Tulemus $Kat "DHCP skoop 'HKHK'" "TEHTUD" "Skoop leitud (Võrk: $($Skoop.ScopeId))"
    } else {
        Lisa-Tulemus $Kat "DHCP skoop 'HKHK'" "TEGEMATA" "Skoopi nimega 'HKHK' ei leitud"
    }
} else {
    Lisa-Tulemus $Kat "DHCP skoop 'HKHK'" "TEGEMATA" "DHCP käsud pole kättesaadavad"
}

# ---------------------------------------------------------------------------------
# 5. FAILITEENUSED JA DFS
# ---------------------------------------------------------------------------------
$Kat = "Failiteenused ja DFS"

$Kaustad = @("F:\DFS_Lektoritele", "F:\DFS_Tudengitele")
foreach ($Kaust in $Kaustad) {
    if (Test-Path -Path $Kaust) {
        Lisa-Tulemus $Kat "Kaust $Kaust eksisteerib" "TEHTUD" "Leitud kettalt"
    } else {
        Lisa-Tulemus $Kat "Kaust $Kaust eksisteerib" "TEGEMATA" "Ei leitud või F: puudub"
    }
}

if (Get-Command Get-DfsnRoot -ErrorAction SilentlyContinue) {
    $DfsJuured = Get-DfsnRoot -Path "\\*\*" -ErrorAction SilentlyContinue
    $DfsLeitud = $false
    foreach ($Root in $DfsJuured) {
        if ($Root.Path -match '\\Tudengid$') {
            Lisa-Tulemus $Kat "DFS nimeruum \Tudengid" "TEHTUD" "Leitud: $($Root.Path)"
            $DfsLeitud = $true
            break
        }
    }
    if (-not $DfsLeitud) {
        Lisa-Tulemus $Kat "DFS nimeruum \Tudengid" "TEGEMATA" "Nimeruumi '\Tudengid' ei tuvastatud"
    }
} else {
    Lisa-Tulemus $Kat "DFS nimeruum \Tudengid" "TEGEMATA" "DFS moodul pole paigaldatud"
}

# ---------------------------------------------------------------------------------
# 6. GROUP POLICY (GPO)
# ---------------------------------------------------------------------------------
$Kat = "GPO seadistused"
if (Get-Command Get-GPO -ErrorAction SilentlyContinue) {
    $OodatavadGpod = @("7zip", "Chrome", "Wallpaper")
    $SysteemiGpod = Get-GPO -All -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DisplayName
    
    foreach ($Gpo in $OodatavadGpod) {
        if ($SysteemiGpod -contains $Gpo) {
            Lisa-Tulemus $Kat "GPO '$Gpo' olemasolu" "TEHTUD" "Leitud"
        } else {
            Lisa-Tulemus $Kat "GPO '$Gpo' olemasolu" "TEGEMATA" "Poliitikat ei leitud"
        }
    }
} else {
    Lisa-Tulemus $Kat "GPO seadistused" "TEGEMATA" "GroupPolicy moodul pole saadaval"
}

# ---------------------------------------------------------------------------------
# 7. TURVALISUS (LAPS)
# ---------------------------------------------------------------------------------
$Kat = "Turvalisus (LAPS)"
$LapsCmd = Get-Command -Module Microsoft.Windows.LAPS -ErrorAction SilentlyContinue
if ($LapsCmd) {
    Lisa-Tulemus $Kat "LAPS-i laiendus paigaldatud" "TEHTUD" "Moodul Microsoft.Windows.LAPS on olemas"
} else {
    Lisa-Tulemus $Kat "LAPS-i laiendus paigaldatud" "TEGEMATA" "Moodulit ei tuvastatud"
}

# ---------------------------------------------------------------------------------
# BOONUS: LITSENTSI STAATUS JA REARM
# ---------------------------------------------------------------------------------
$Kat = "Boonus (Litsents)"
try {
    $Lic = Get-WmiObject SoftwareLicensingProduct -Filter "Name like '%Windows%'" | 
           Where-Object { $_.PartialProductKey } | Select-Object -First 1

    if ($Lic) {
        $PaeviJaanud = [Math]::Round($Lic.LicenseStatusReason / 1440, 1)
        $Service = Get-WmiObject SoftwareLicensingService
        $RearmiksJaanud = $Service.RemainingWindowsRearmCount

        $Info = "Päevi jäänud: $PaeviJaanud | Rearm loendur alles: $RearmiksJaanud"
        Lisa-Tulemus $Kat "Litsentsi aegumine & Rearm" "INFO" $Info
    } else {
        Lisa-Tulemus $Kat "Litsentsi aegumine & Rearm" "TEGEMATA" "Andmeid ei saanud lugeda"
    }
} catch {
    Lisa-Tulemus $Kat "Litsentsi aegumine & Rearm" "TEGEMATA" "Viga päringu tegemisel"
}

# ---------------------------------------------------------------------------------
# RAPORTI KUVAMINE KONSOOLIS (VÄRVIKODEERITUD)
# ---------------------------------------------------------------------------------
Clear-Host
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                KURSUSE PROGRESSI RAPORT: AUTOMAATAUDIT              " -ForegroundColor Cyan

# =================================================================================
# AINULT HTML FAILINA GENEREERIMISE JA SALVESTAMISE KOODIPLOKK
# =================================================================================

# 1. Tuvastame kasutaja töölaua (Desktop) kausta ja määrame faili asukoha
$Toolaud = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$HtmlFailiTee = [System.IO.Path]::Combine($Toolaud, "Kursuse_progressi_raport.html")

# 2. Defineerime HTML-i stiilid (CSS) tabeli ilusa välimuse jaoks
$HtmlStiil = @"
<style>
    body { font-family: Arial, sans-serif; background-color: #f4f6f9; color: #333; margin: 20px; }
    h1 { color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 10px; font-size: 24px; }
    .meta-info { font-style: italic; color: #666; margin-bottom: 20px; line-height: 1.6; }
    table { border-collapse: collapse; width: 100%; box-shadow: 0 2px 5px rgba(0,0,0,0.1); background-color: #fff; }
    th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #ddd; }
    th { background-color: #0056b3; color: white; text-transform: uppercase; font-size: 14px; }
    tr:hover { background-color: #f1f1f1; }
    .status-tehtud { background-color: #d4edda; color: #155724; font-weight: bold; text-align: center; border-radius: 4px; padding: 5px; }
    .status-tegemata { background-color: #f8d7da; color: #721c24; font-weight: bold; text-align: center; border-radius: 4px; padding: 5px; }
    .status-info { background-color: #fff3cd; color: #856404; font-weight: bold; text-align: center; border-radius: 4px; padding: 5px; }
</style>
"@

# 3. HTML-i päise ja serveri info kokkupanek
$HtmlSisu = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Kursuse progressi raport</title>
    $HtmlStiil
</head>
<body>
    <h1>Kursuse progressi raport: Automaataudit</h1>
    <div class="meta-info">
        <strong>Genereeritud:</strong> $(Get-Date)<br>
        <strong>Server (Hostname):</strong> $env:COMPUTERNAME<br>
        <strong>Domeen (Domain):</strong> $((Get-WmiObject Win32_ComputerSystem).Domain)
    </div>
    <table>
        <thead>
            <tr>
                <th>Kategooria</th>
                <th>Kontrollitav punkt</th>
                <th style="width: 120px; text-align: center;">Status</th>
                <th>Detailid</th>
            </tr>
        </thead>
        <tbody>
"@

# 4. Lisame ridade kaupa andmed ja määrame staatuse järgi värvuse
foreach ($Rida in $Raport) {
    $Klass = ""
    if ($Rida.Staatus -eq "TEHTUD") { $Klass = "status-tehtud" }
    elseif ($Rida.Staatus -eq "TEGEMATA") { $Klass = "status-tegemata" }
    else { $Klass = "status-info" }

    $HtmlSisu += "<tr>"
    $HtmlSisu += "<td>$($Rida.Kategooria)</td>"
    $HtmlSisu += "<td>$($Rida.'Kontrollitav punkt')</td>"
    $HtmlSisu += "<td><div class='$Klass'>$($Rida.Staatus)</div></td>"
    $HtmlSisu += "<td>$($Rida.Detailid)</td>"
    $HtmlSisu += "</tr>"
}

# 5. HTML struktuuri lõpetamine
$HtmlSisu += @"
        </tbody>
    </table>
</body>
</html>
"@

# 6. Salvestame kogu sisu failina (UTF-8 tagab täpitähtede korrektse kuvamise)
$HtmlSisu | Out-File -FilePath $HtmlFailiTee -Encoding utf8 -Force

# 7. Kinnitus konsooli
Write-Host ""
Write-Host "HTML-raport edukalt töölauale genereeritud!" -ForegroundColor Cyan
Write-Host "-> Faili tee: $HtmlFailiTee" -ForegroundColor Gray
