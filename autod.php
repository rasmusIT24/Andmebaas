<?php
$conn = new mysqli("localhost", "root", "", "andmebaas");

$q = isset($_GET['q']) ? $_GET['q'] : '';

if ($q == '') {
    $sql = "SELECT * FROM autod";
} else {
    $sql = "SELECT * FROM autod 
            WHERE mark LIKE '%$q%' 
            OR mudel LIKE '%$q%'";
}

$result = $conn->query($sql);

while($row = $result->fetch_assoc()) {
    echo $row['mark'] . " " . $row['mudel'] . "<br>";
}
?>