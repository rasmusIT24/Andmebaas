
<?php
// *** Protseduurili *** //
// Sinu andmed
$db_server = 'localhost';
$db_andmebaas = 'ojalacar_rent';
$db_kasutaja = 'root';
$db_salasona = '';


// Ühendus andmebaasiga
$yhendus = mysqli_connect($db_server, $db_kasutaja, $db_salasona, $db_andmebaas);


// Ühenduse kontroll
if (!$yhendus) {
    die('Ei saa ühendust andmebaasiga');
}
?>