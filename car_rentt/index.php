<?php
include("config.php");
?>
<!DOCTYPE html>
<html lang="et">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KuradiAutod.ee</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

</head>
<style>
  .btn-long-black {
    display: inline-block;
    background-color: #000;
    color: #fff;
    padding: 12px 28px;
    border-radius: 6px;
    text-decoration: none;
    font-weight: 600;
    font-size: 16px;
    width: 100%;
    text-align: center;
    transition: 0.2s ease;
}

.btn-long-black:hover {
    background-color: #222;
}

</style>

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
          <a class="nav-link active" aria-current="page" href="#">Avaleht</a>
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
      <form class="d-flex" role="search">
        <input class="form-control me-2" type="Otsi autot" placeholder="Otsi autot" aria-label="Otsi autot"/>
        <button class="btn btn-outline-dark" type="submit">Search</button>
      </form>
    </div>
  </div>
</nav>
<section class="bg-light py-5">
  <div class="container">
    <div class="bg-secondary-subtle p-5 rounded-4">
      <div class="row align-items-center">
        <div class="col-md-6">
          <h2 class="fw-bold mb-3">Rendi auto<br>soodsalt</h2>
          <p class="text-muted mb-4">
            Lai valik usaldusväärseid autosid igaks olukorraks.
          </p>
          <a href="#" class="btn btn-dark px-4">Vaata autosid</a>
        </div>
        <div class="col-md-6 text-center">
          <img src="https://picsum.photos/700/400" class="img-fluid rounded-3" alt="Car">
        </div>
      </div>
    </div>
  </div>
</section>

<?php
$paring = 'SELECT * FROM cars';
$valjund = mysqli_query($yhendus, $paring);

if ($valjund) {
    // Tulemuste läbikäimine ja kuvamine
    while ($rida = mysqli_fetch_array($valjund)) {
    print_r($rida["models"]);
    }}

// $models = [
//     ["name" => "Audi Q8", "type" => "Crossover"],
//     ["name" => "Mercedes A-Class", "type" => "Hatchback"],
//     ["name" => "Mercedes C AMG", "type" => "Coupe"],
//     ["name" => "Audi R8 Spyder", "type" => "Cabrio"]
// ];

// $engines = ["V4", "V6", "V8", "V10"];
// $fuels = ["Bensiin", "Diisel", "Hübrid"];
// $power = [50, 80, 100, 120, 150, 200, 250];
// $years = range(2015, 2024);
?>

<div class="container mt-4">
    <div class="row g-4">

        <?php
        for ($i = 0; $i < 8; $i++) {

            $car = $models[array_rand($model)];
            $engine = $engines[array_rand($engines)];
            $fuel = $fuels[array_rand($fuels)];
            $hp = $power[array_rand($power)];
            $year = $years[array_rand($years)];
        ?>

        <div class="col-md-3">
            <div class="card h-100 shadow-sm">
                <img src="https://picsum.photos/200/200" class="card-img-top" alt="<?= $car['name'] ?>">

                <div class="card-body">
                    <h5 class="card-title"><?= $car['name'] ?></h5>
                    <p class="card-text">
                        <?= $car['type'] ?> - <?= $year ?><br>
                        <strong>Mootor:</strong> <?= $engine ?><br>
                        <strong>Kütus:</strong> <?= $fuel ?><br>
                        <strong>Hind:</strong> <?= $hp ?> €/päev
                    </p>
                </div>

                <div class="card-footer text-center">
                    <a href="#" class="btn btn-dark w-100">Rendi</a>
                </div>
            </div>
        </div>

        <?php } ?>

    </div>
</div>


</div>
<nav class="d-flex justify-content-center my-5">
  <ul class="pagination">

    <li class="page-item disabled">
      <a class="page-link">Eelmine</a>
    </li>

    <li class="page-item active">
      <a class="page-link">1</a>
    </li>

    <li class="page-item">
      <a class="page-link">2</a>
    </li>

    <li class="page-item">
      <a class="page-link">3</a>
    </li>

    <li class="page-item">
      <a class="page-link">Järgmine</a>
    </li>

  </ul>
</nav>
</body>