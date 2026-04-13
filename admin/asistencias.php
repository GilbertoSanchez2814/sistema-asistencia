<?php
session_start();
if (!isset($_SESSION['admin'])) {
    header("Location: ../index.php");
}

require("../config/conexion.php");

$res = $conexion->query("
SELECT m.*, e.nombre, e.apellido 
FROM marcados m
JOIN empleados e ON m.cedula = e.cedula
ORDER BY m.fecha_hora DESC
");
?>

<!DOCTYPE html>
<html>
<head>
<title>Asistencias</title>
<link rel="stylesheet" href="../assets/css/style.css">
</head>
<body>

<div class="sidebar">
    <h2>Admin</h2>
    <a href="dashboard.php">Dashboard</a>
    <a href="empleados.php">Empleados</a>
    <a href="asistencias.php">Asistencias</a>
    <a href="historial.php">Historial</a>
    <a href="../logout.php">Cerrar sesión</a>
</div>

<div class="content">
<h1>Asistencias</h1>

<table border="1" width="100%">
<tr>
    <th>Cédula</th>
    <th>Nombre</th>
    <th>Fecha</th>
    <th>Hora</th>
    <th>Tipo</th>
</tr>

<?php while($r = $res->fetch_assoc()): ?>
<tr>
    <td><?= $r['cedula'] ?></td>
    <td><?= $r['nombre'] ?> <?= $r['apellido'] ?></td>
    <td><?= $r['fecha'] ?></td>
    <td><?= $r['fecha_hora'] ?></td>
    <td><?= $r['tipo'] ?></td>
</tr>
<?php endwhile; ?>

</table>

</div>

</body>
</html>