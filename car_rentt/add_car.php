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
        <button class="btn btn-outline-dark" type="submit">Logout</button>
</nav>

    </div>
  </div>
</nav>

<div class="container my-5">
  <div class="row justify-content-center">
    <div class="col-lg-6 col-md-8">
      <div class="card shadow-sm">
        <div class="card-header">
          <h5 class="mb-0">Lisa auto</h5>
        </div>
        <div class="card-body">
          <form>
            <div class="mb-3">
              <label for="mark" class="form-label">Mark</label>
              <input type="text" class="form-control" id="mark" name="mark">
            </div>

            <div class="mb-3">
              <label for="mudel" class="form-label">Mudel</label>
              <input type="text" class="form-control" id="mudel" name="mudel">
            </div>

            <div class="mb-3">
              <label for="mootor" class="form-label">Mootor</label>
              <input type="text" class="form-control" id="mootor" name="mootor">
            </div>

            <div class="mb-3">
              <label for="kütus" class="form-label">Kütus</label>
              <select class="form-select" id="kütus" name="kütus">
                <option selected disabled>Vali</option>
                <option value="bensiin">Bensiin</option>
                <option value="diisel">Diisel</option>
                <option value="hübriid">Hübriid</option>
                <option value="elekter">Elekter</option>
              </select>
            </div>

            <div class="mb-3">
              <label for="hind" class="form-label">Hind (€ / päev)</label>
              <input type="number" step="0.01" class="form-control" id="hind" name="hind">
            </div>

            <div class="mb-3">
              <label for="pilt" class="form-label">Auto pilt</label>
              <input class="form-control" type="file" id="pilt" name="pilt" accept=".jpg,.jpeg,.png,.webp">
              <div class="form-text">
                Lubatud formaadid: JPG, PNG, WEBP.
              </div>
            </div>

            <div class="d-flex justify-content-end gap-2 mt-4">
              <button type="submit" class="btn btn-dark">Salvesta</button>
              <button type="button" class="btn outline-dark">Tühista</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>


</html>
</body>