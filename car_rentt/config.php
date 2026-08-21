<?php
$db_server = 'localhost';
$db_andmebaas = 'car_rent';
$db_kasutaja = 'rojala';
$db_salasona = 'Passw0rd';


$yhendus = mysqli_connect($db_server, $db_kasutaja, $db_salasona, $db_andmebaas);


if (!$yhendus) {
    die('Ei saa ühendust andmebaasiga');
}
?>