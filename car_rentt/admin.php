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
    <a class="navbar-brand" href="#" class="fw-bold">Autorent admin</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarSupportedContent">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <li class="nav-item">
          <a class="nav-link active" aria-current="page" href="index.php">Avaleht</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="index.php">Autod</a>
          <li class="nav-item"></li>
          <a class="nav-link" href="#">Hinnad</a>
          <a class="nav-link" href="#">Kontakt</a>
        </li>
          </ul>
        </li>
        </li>
      </ul>
      <form class="d-flex" role="search">
        <input class="form-control me-2" type="Otsi autot" placeholder="Otsi autot" aria-label="Otsi autot" name="otsi"/>
        <button class="btn btn-outline-dark" type="submit">Search</button>
        <?php
//         if (!empty($_GET['otsi'])) {
// 	//kasutaja tekst vormist
// 	$otsi = $_GET['otsi'];
// 	//päring
// 	$paring = 'SELECT * FROM cars WHERE mark LIKE "'.$otsi.'"';
//   var_dump($paring);
	
// }
        ?> 
      </form>
    </div>
  </div>
</nav>



<div class="container mt-4">
    <div class="row g-4">

<p class="fs-1">Autod</p>
<div class="d-flex align-items-center">
  <span>Halda autorendi autode nimekirja</span>
  <button class="btn btn-dark ms-auto" href="add_car.php">Lisa auto</button>
</div>

          <table class="table table-striped">
            <tr><td><p class="fw-bold">Pilt</p></td> <td><p class="fw-bold">Auto</td><td><p class="fw-bold">Mootor</td><td><p class="fw-bold">Kütus</td><td><p class="fw-bold">hind</td><td><p class="fw-bold">Kirjeldus</td><td><p class="fw-bold">Tegevused</td></tr>
          
        <?php
        $paring = 'SELECT * FROM cars ';
        if (!empty($_GET['otsi'])) {
        $otsi = $_GET['otsi'];
        $paring.='WHERE mark  LIKE "'.$otsi.'"';
        }
        $paring .='LIMIT 8';
        // var_dump($paring);
$valjund = mysqli_query($yhendus, $paring);

if ($valjund) {
    // Tulemuste läbikäimine ja kuvamine
    while ($rida = mysqli_fetch_array($valjund)) {
    // print_r($rida["model"]);
    
        // for ($i = 0; $i < 8; $i++) {
            $id = $rida["id"];
            $mark = $rida["mark"];
            $model =  $rida["model"];
            $engine =  $rida["engine"];
            $fuel =  $rida["fuel"];
            $price =  $rida["price"];
            $description = $rida["description"];
            $status = $rida["status"];
            $image =  $rida["image"];
        ?>

       <tr><td><img src="https://loremflickr.com/100/100/<?= $mark ?>" class="img-fluid h-100 w-100 object-fit-cover"?></td> <td><?php echo $model ?></td><td><?php echo $engine ?></td><td><?php echo $fuel ?></td><td><?php echo $price ?></td><td><?php echo $description ?></td><td>
  <div class="d-flex justify-content-end align-items-center gap-2">
    <a href="edit.php?id=<?php echo $id ?>" class="btn btn-outline-primary">Muuda</a>
    <a href="delete.php?id=<?php echo $id ?>" class="btn btn-outline-danger">Kustuta</a>
  </div>
</td></tr>

        <?php }} ?>
        
</table>
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