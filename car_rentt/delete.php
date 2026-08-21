<?php
// session_start();
// if (!isset($_SESSION['tuvastamine'])) {
//   header('Location: login.php');
//   exit();
//   }
include("config.php");


$id = $_GET['id'];

  $stmt = $yhendus->prepare("DELETE FROM cars WHERE id = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();

       if ($stmt->affected_rows > 0) {
        header('Location: admin.php?deleted=1');
    } else {
        header('Location: admin.php?error=1');
    }