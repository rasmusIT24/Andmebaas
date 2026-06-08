# =================================================================================
# KURSUSE PROGRESSI RAPORT - AUTOMAATKONTROLLI SKRIPT KOOS SALVESTAMISEGA
# Tulemus väljastatakse konsooli selge tabelina ja salvestatakse töölauale.
# =================================================================================

# --- Kasutaja seadistused (Parandatud trükiviga: ojala.forest) ---
$OodatavServeriNimi = "AD1"
$OodatavIPMuster    = '^10\.0\.\d{1,3}\.10$' 
$OodatavDomeenMuster = "^(ojala\.forest|test\.local)$" 

# Dünaamiline domeeninime tuvastus serverist
$TegelikDomeen = (Get-WmiObject Win32_ComputerSystem).Domain
$PraeguneNimi = $env:COMPUTERNAME

# Failide salvestamise asukoht (Töölaud)
$Toolaud = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$TxtFailiTee = [System.IO.Path]::Combine($Toolaud, "Kursuse_progressi_raport.txt")
$CsvFailiTee = [System.IO.Path]::Combine($Toolaud, "Kursuse_progressi_raport.csv")

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
# RAPORTI KUVAMINE TABELINA JA VÄRVIKODEERIMINE
# ---------------------------------------------------------------------------------

# =================================================================================
# AINULT FAILIDESSE SALVESTAMISE KOODIPLOKK
# =================================================================================

# 1. Tuvastame kasutaja töölaua (Desktop) kausta asukoha
$Toolaud = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$TxtFailiTee = [System.IO.Path]::Combine($Toolaud, "Kursuse_progressi_raport.txt")
$CsvFailiTee = [System.IO.Path]::Combine($Toolaud, "Kursuse_progressi_raport.csv")

# 2. Tekstifaili (.txt) koostamine ja ilusa tabelina vormindamine
$TxtSisu = @()
$TxtSisu += "======================================================================"
$TxtSisu += "                KURSUSE PROGRESSI RAPORT: AUTOMAATAUDIT              "
$TxtSisu += "======================================================================"
$TxtSisu += "Genereeritud: $(Get-Date)"
$TxtSisu += "Server: $env:COMPUTERNAME"
$TxtSisu += ""
# Tabeli päis (veergude laiused: 25, 35, 10 sümbolit)
$TxtSisu += "{0,-25} | {1,-35} | {2,-10} | {3}" -f "Kategooria", "Kontrollitav punkt", "Staatus", "Detailid"
$TxtSisu += "-------------------------------------------------------------------------------------------------------"

# Lisame iga tulemuse rea tabelisse
foreach ($Rida in $Raport) {
    $TxtSisu += "{0,-25} | {1,-35} | {2,-10} | {3}" -f $Rida.Kategooria, $Rida.'Kontrollitav punkt', $Rida.Staatus, $Rida.Detailid
}
$TxtSisu += "======================================================================"

# Kirjutame sisu tekstifaili (UTF-8 tagab täpitähtede õige kuvamise)
$TxtSisu | Out-File -FilePath $TxtFailiTee -Encoding utf8 -Force


# 3. CSV faili (.csv) eksportimine Exceli jaoks
$Raport | Export-Csv -Path $CsvFailiTee -NoTypeInformation -Delimiter "," -Encoding utf8 -Force


# 4. Teavitus konsooli, et failid on valmis
Write-Host ""
Write-Host "Raportid edukalt töölauale salvestatud!" -ForegroundColor Cyan
Write-Host "-> Vaata faili: $TxtFailiTee" -ForegroundColor Gray
Write-Host "-> Vaata faili: $CsvFailiTee" -ForegroundColor Gray


Clear-Host
Write-Host "======================================================================" -ForegroundColor Cyan
