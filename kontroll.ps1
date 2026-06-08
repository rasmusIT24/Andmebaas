# =================================================================================
# KURSUSE PROGRESSI RAPORT - AUTOMAATKONTROLLI SKRIPT
# Tulemus väljastatakse konsooli selge tabelina: TEHTUD / TEGEMATA
# =================================================================================

# --- Kasutaja seadistused (muuda vastavalt vajadusele) ---
$OodatavServeriNimi = "AD1"
$OodatavIPMuster    = '^10\.0\.\d{1,3}\.10$' # Sobib 10.0.XXX.10 kujuga

# Dünaamiline domeeninime tuvastus (ühildub nii perenimi.local kui TEST.LOCAL-iga)
$TegelikDomeen = (Get-WmiObject Win32_ComputerSystem).Domain

# Raporti massiiv tulemuste kogumiseks
$Raport = @()

# Abifunktsioon tulemuste lisamiseks
function Lisa-Tulemus ($Kategooria, $Kontroll, $Staatus, $Detailid) {
    $Objekt = [PSCustomObject]@{
        'Kategooria' = $Kategooria
        'Kontrollitav punkt' = $Kontroll
        'Staatus'    = $Staatus
        'Detailid'   = $Detailid
    }
    $script:Raport += $Objekt
}

# ---------------------------------------------------------------------------------
# 1. BAASVÕRK JA DOMEEN
# ---------------------------------------------------------------------------------
$Kat = "Baasvõrk ja domeen"

# Serveri nimi
$PraeguneNimi = $env:COMPUTERNAME
if ($PraeguneNimi -eq $OodatavServeriNimi) {
    Lisa-Tulemus $Kat "Serveri nimi on $OodatavServeriNimi" "TEHTUD" "Nimi on korras"
} else {
    Lisa-Tulemus $Kat "Serveri nimi on $OodatavServeriNimi" "TEGEMATA" "Praegune nimi: $PraeguneNimi"
}

# IP-aadress
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

# Domeeni kättesaadavus
if ($TegelikDomeen -and $TegelikDomeen -ne "WORKGROUP") {
    Lisa-Tulemus $Kat "Domeen on kättesaadav" "TEHTUD" "Domeen: $TegelikDomeen"
} else {
    Lisa-Tulemus $Kat "Domeen on kättesaadav" "TEGEMATA" "Arvuti ei kuulu domeeni"
}

# ---------------------------------------------------------------------------------
# 2. ACTIVE DIRECTORY STRUKTUUR (OU-d ja Grupid)
# ---------------------------------------------------------------------------------
$Kat = "AD Struktuur"
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

if (Get-Module ActiveDirectory) {
    # OU kontroll
    $Oud = @("KASUTAJAD", "LEKTORID", "TUDENGID", "ARVUTID")
    foreach ($OU in $Oud) {
        $LeitudOU = Get-ADOrganizationalUnit -Filter "Name -eq '$OU'" -ErrorAction SilentlyContinue
        if ($LeitudOU) {
            Lisa-Tulemus $Kat "OU $OU olemasolu" "TEHTUD" "Leitud"
        } else {
            Lisa-Tulemus $Kat "OU $OU olemasolu" "TEGEMATA" "Puudub"
        }
    }

    # Gruppide kontroll
    $Grupid = @("Lektorid", "Tudengid", "RedirectedDirectories")
    foreach ($Grupp in $Grupid) {
        $LeitudGrupp = Get-ADGroup -Filter "Name -eq '$Grupp'" -ErrorAction SilentlyContinue
        if ($LeitudGrupp) {
            Lisa-Tulemus $Kat "Grupp $Grupp loodud" "TEHTUD" "Leitud"
        } else {
            Lisa-Tulemus $Kat "Grupp $Grupp loodud" "TEGEMATA" "Puudub"
        }
    }
} else {
    Lisa-Tulemus $Kat "AD kontroll" "TEGEMATA" "ActiveDirectory moodul pole saadaval"
}

# ---------------------------------------------------------------------------------
# 3. KASUTAJAD JA KUULUVUS
# ---------------------------------------------------------------------------------
$Kat = "Kasutajad"
if (Get-Module ActiveDirectory) {
    # Kasutajad ja nende oodatavad grupid
    $Kasutajakontrollid = @(
        @{Nimi="oppejoud1"; Grupp="Lektorid"},
        @{Nimi="oppejoud2"; Grupp="Lektorid"},
        @{Nimi="tudeng1"; Grupp="Tudengid"},
        @{Nimi="tudeng2"; Grupp="Tudengid"}
    )

    foreach ($K in $Kasutajakontrollid) {
        $U = Get-ADUser -Filter "SamAccountName -eq '$($K.Nimi)'" -ErrorAction SilentlyContinue
        if ($U) {
            # Kontrolli grupi kuuluvust
            $Grupid = Get-ADPrincipalGroupMembership $U | Select-Object -ExpandProperty Name
            if ($Grupid -contains $K.Grupp) {
                Lisa-Tulemus $Kat "Kasutaja $($K.Nimi)" "TEHTUD" "Olemas ja grupis $($K.Grupp)"
            } else {
                Lisa-Tulemus $Kat "Kasutaja $($K.Nimi)" "TEGEMATA" "Kasutaja olemas, kuid puudub grupist $($K.Grupp)"
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

# DHCP Skoop "HKHK"
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

# Kaustade kontroll
$Kaustad = @("F:\DFS_Lektoritele", "F:\DFS_Tudengitele")
foreach ($Kaust in $Kaustad) {
    if (Test-Path -Path $Kaust) {
        Lisa-Tulemus $Kat "Kaust $Kaust eksisteerib" "TEHTUD" "Leitud kettalt"
    } else {
        Lisa-Tulemus $Kat "Kaust $Kaust eksisteerib" "TEGEMATA" "Ei leitud või F: ketas puudub"
    }
}

# DFS Nimeruum
if (Get-Command Get-DfsnRoot -ErrorAction SilentlyContinue) {
    # Otsib nimeruumi, mis lõppeb nimega "Tudengid" (hõlmab nii TEST.LOCAL kui muud)
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
            Lisa-Tulemus $Kat "GPO '$Gpo' olemasolu" "TEHTUD" "Leitud poliitika"
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
    # Päring litsentsiinfo saamiseks WMI-st
    $Lic = Get-WmiObject SoftwareLicensingProduct -Filter "Name like '%Windows%'" | 
           Where-Object { $_.PartialProductKey } | Select-Object -First 1

    if ($Lic) {
        $PaeviJaanud = [Math]::Round($Lic.LicenseStatusReason / 1440, 1) # Minutid päevadeks
        $RearmCount = $Lic.RemainingGracePeriod # Rearm loendur mõnes versioonis
        
        # Teise meetodi proovimine järelejäänud rearmide jaoks
        $Service = Get-WmiObject SoftwareLicensingService
        $RearmiksJaanud = $Service.RemainingWindowsRearmCount

        $Info = "Päevi jäänud: $PaeviJaanud | Lubatud tagasivõtte (Rearm) alles: $RearmiksJaanud"
        Lisa-Tulemus $Kat "Litsentsi aegumine & Rearm" "INFO" $Info
    } else {
        Lisa-Tulemus $Kat "Litsentsi aegumine & Rearm" "TEGEMATA" "Andmeid ei õnnestunud lugeda"
    }
} catch {
    Lisa-Tulemus $Kat "Litsentsi aegumine & Rearm" "TEGEMATA" "Viga päringu tegemisel"
}

# ---------------------------------------------------------------------------------
