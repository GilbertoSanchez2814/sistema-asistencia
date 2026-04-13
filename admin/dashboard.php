<?php
session_start();
if (!isset($_SESSION['admin'])) {
    header("Location: ../index.php");
}
?>

<!DOCTYPE html>
<html>
<head>
<title>Dashboard</title>
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
    <h1>Bienvenido Admin</h1>

    <div class="card">👤 Empleados</div>
    <div class="card">⏱️ Asistencias</div>
    <div class="card">🧾 Historial</div>
</div>

</body>
</html>