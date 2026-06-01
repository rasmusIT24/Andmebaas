<?php include('config.php'); ?>
<?php
session_start();
if ($_GET) {
    $test='$2a$10$U0X2SZ8R7hBxQllYP8RgUOuNyL3oubnJyg0oCHR.pJmPIwV2NB0ra';
     $login = $_GET['login'];
    $paring = "SELECT * FROM `users` WHERE username ='".$login."'";
    $valjund = mysqli_query($yhendus, $paring);
    $rida = mysqli_fetch_assoc($valjund);
    // var_dump($rida["password"]);

    $pw = $_GET['pw'];
        if ($login == 'admin' && password_verify($pw, $test)) {
            $_SESSION['tuvastamine'] = 'misiganes';
            header('Location: admin.php');
        } else {
            echo 'ei tööta';
        }
}
   
?>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>KuradiAutod.ee</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</head>


<body>
    <div class="container">
        <nav class="navbar navbar-expand-lg bg-body-tertiary">
  <div class="container-fluid">
    <a class="navbar-brand" href="#" class="fw-bold">Autorent admin</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarSupportedContent">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        </li>
          </ul>
        </li>
        </li>
      </ul>
      <form class="d-flex" role="search">
</nav>
<form action="login.php" method="get">
    login <input type="text" name="login"><br>
    salasõna <input type="password" name="pw"><br>
    <input type="submit" value="login">
</form>
    </div>
  </div>
</nav>
</body>