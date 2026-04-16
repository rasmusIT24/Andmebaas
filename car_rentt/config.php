<?php
$db_server = 'localhost';
$db_andmebaas = 'ojalacar_rent';
$db_kasutaja = 'root';
$db_salasona = '';


$yhendus = mysqli_connect($db_server, $db_kasutaja, $db_salasona, $db_andmebaas);


if (!$yhendus) {
    die('Ei saa ühendust andmebaasiga');
}
?>