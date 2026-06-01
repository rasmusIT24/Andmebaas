<?php include('config.php'); ?>
<?php
if ($_GET) {
     $login = $_GET['login'];
    $paring = "SELECT * FROM `users` WHERE username ='".$login."'";
    $valjund = mysqli_query($yhendus, $paring);
    $rida = mysqli_fetch_assoc($valjund);
    // var_dump($rida["password"]);

    $pw = $_GET['pw'];
        if ($login == 'user' && password_verify($pw)) {
            $_SESSION['tuvastamine'] = 'misiganes';
            header('Location: autod.php');
        } else {
            echo 'ei tööta';
        }
}
   
?>
<body>
<form method="POST">
    Nimi: <input type="text" name="name" required><br>
    Parool: <input type="password" name="password" required><br>
    <button type="submit">Registreeru</button>
</form>
</body>