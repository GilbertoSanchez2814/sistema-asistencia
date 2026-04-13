<?php
session_start();
if (!isset($_SESSION['admin'])) {
    header("Location: ../index.php");
}

require("../config/conexion.php");

$historial = $conexion->query("
SELECT h.*, e.nombre, e.apellido 
FROM historial h
LEFT JOIN empleados e ON h.cedula = e.cedula
ORDER BY h.fecha DESC
");
?>

<!DOCTYPE html>
<html>
<head>
<title>Historial</title>
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
<h1>Historial</h1>

<table border="1" width="100%">
<tr>
    <th>Fecha</th>
    <th>Acción</th>
    <th>Empleado</th>
    <th>Descripción</th>
</tr>

<?php while($h = $historial->fetch_assoc()): ?>
<tr>
    <td><?= $h['fecha'] ?></td>
    <td><?= $h['accion'] ?></td>
    <td><?= $h['nombre'] ?> <?= $h['apellido'] ?></td>
    <td><?= $h['descripcion'] ?></td>
</tr>
<?php endwhile; ?>

</table>

</div>

</body>
</html>