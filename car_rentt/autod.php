<?php
include("config.php");
if (isset($_GET['id'])) {

    $id = intval($_GET['id']);
    $paring = "SELECT * FROM cars WHERE id = $id";
    $valjund = mysqli_query($yhendus, $paring);
    $rida = mysqli_fetch_assoc($valjund);

} else {

    $q = $_GET['q'] ?? '';
    $q = mysqli_real_escape_string($yhendus, $q);

    if ($q === '') {
        $paring = "SELECT * FROM cars";
    } else {
        $paring = "
            SELECT * FROM cars
            WHERE mark LIKE '%$q%'
               OR model LIKE '%$q%'
        ";
    }

    $valjund = mysqli_query($yhendus, $paring);
}
?>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>KuradiAutod.ee</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous">

</head>
<body>
        <nav class="navbar navbar-expand-lg bg-body-tertiary">
  <div class="container-fluid">
    <a class="navbar-brand" href="#" class="fw-bold">Autorent</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarSupportedContent">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <li class="nav-item">
          <a class="nav-link active" aria-current="page" href="etapp1.html">Avaleht</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="#">Autod</a>
          <li class="nav-item"></li>
          <a class="nav-link" href="#">Hinnad</a>
          <a class="nav-link" href="#">Kontakt</a>
        </li>
          </ul>
        </li>
        </li>
      </ul>
<form class="d-flex" role="search" method="GET" action="autod.php">
    <input class="form-control me-2" type="text" name="q" placeholder="Otsi autot">
    <button class="btn btn-outline-dark" type="submit">Otsi</button>
</form>
<?php
$paring = "SELECT * FROM cars WHERE id =".$_GET['id']."";
?>

      </form>
    </div>
  </div>
</nav>
<div class="container py-5">
  <div class="card shadow-sm border-0">
    <?php
    $paring = "SELECT * FROM cars WHERE id =".$_GET['id']."";
    // var_dump($paring);
$valjund = mysqli_query($yhendus, $paring);
$rida = mysqli_fetch_array($valjund);
          $id = $rida["id"];
            $mark = $rida["mark"];
            $model =  $rida["model"];
            $engine =  $rida["engine"];
            $fuel =  $rida["fuel"];
            $price =  $rida["price"];
            $image =  $rida["image"];





    ?>
    <div class="row g-0">
      <div class="col-md-6">
        <img src="https://loremflickr.com/400/250/<?= $mark ?>" class="img-fluid h-100 w-100 object-fit-cover" alt="Car Image">
</div>
      <div class="col-md-6 p-4 d-flex flex-column justify-content-between">
        <div>
          <h2 class="fw-bold"> <?= $mark ?> </h2>
          <p class="text-muted mb-4"><?= $model ?></p>
          <ul class="list-unstyled">
            <li><strong>Mootor:</strong> <?= $engine ?> </li>
            <li><strong>Kütus:</strong> <?= $fuel ?> </li>
            <li><strong>Käigukast:</strong> Automaat</li>
            <li><strong>Kohad:</strong> 2</li>
          </ul>
        </div>
        <div class="mt-4">
          <h3 class="fw-bold mb-3"><?= $price ?>€ / päev</h3>
          <button class="btn btn-dark btn-lg w-100">Rendi</button>
        </div>
      </div>
    </div>
  </div>
</div>


</body>