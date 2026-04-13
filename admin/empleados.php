<?php
session_start();
if (!isset($_SESSION['admin'])) {
    header("Location: ../index.php");
}

require("../config/conexion.php");

$mensaje = "";

// INSERTAR (usando SP)
if (isset($_POST['agregar'])) {

    $cedula = $_POST['cedula'];
    $nombre = $_POST['nombre'];
    $apellido = $_POST['apellido'];
    $dep = $_POST['departamento'];

    if ($cedula <= 0) {
        $mensaje = "❌ Cédula inválida";
    } else {

        if ($conexion->query("CALL insertar_empleado_sp($cedula,'$nombre','$apellido','default.jpg',$dep)")) {
            $mensaje = "✅ Empleado agregado correctamente";
        } else {
            $mensaje = "❌ Error al agregar";
        }

        // limpiar resultados del SP
        while ($conexion->more_results() && $conexion->next_result()) {}
    }
}

// 🔥 ELIMINAR (ARREGLADO)
if (isset($_GET['eliminar'])) {
    $cedula = $_GET['eliminar'];

    // limpiar por si hay resultados pendientes
    while ($conexion->more_results() && $conexion->next_result()) {}

    // borrar dependencias primero
    $conexion->query("DELETE FROM historial WHERE cedula=$cedula");
    $conexion->query("DELETE FROM marcados WHERE cedula=$cedula");

    // ahora sí borrar empleado
    if ($conexion->query("DELETE FROM empleados WHERE cedula=$cedula")) {
        $mensaje = "🗑️ Empleado eliminado correctamente";
    } else {
        $mensaje = "❌ Error al eliminar";
    }
}

// LISTAR
$empleados = $conexion->query("
SELECT e.*, d.nombre as departamento 
FROM empleados e 
LEFT JOIN departamentos d ON e.departamento_id = d.id
");
?>

<!DOCTYPE html>
<html>
<head>
<title>Empleados</title>
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
<h1>Empleados</h1>

<h3 style="color:green;"><?= $mensaje ?></h3>

<h3>Agregar empleado</h3>
<form method="POST">
    <input type="number" name="cedula" placeholder="Cédula" required>
    <input type="text" name="nombre" placeholder="Nombre" required>
    <input type="text" name="apellido" placeholder="Apellido" required>

    <select name="departamento">
        <?php
        $deps = $conexion->query("SELECT * FROM departamentos");
        while($d = $deps->fetch_assoc()){
            echo "<option value='{$d['id']}'>{$d['nombre']}</option>";
        }
        ?>
    </select>

    <button name="agregar">Agregar</button>
</form>

<h3>Lista de empleados</h3>

<table>
<tr>
    <th>Cédula</th>
    <th>Nombre</th>
    <th>Apellido</th>
    <th>Departamento</th>
    <th>Acciones</th>
</tr>

<?php while($e = $empleados->fetch_assoc()): ?>
<tr>
    <td><?= $e['cedula'] ?></td>
    <td><?= $e['nombre'] ?></td>
    <td><?= $e['apellido'] ?></td>
    <td><?= $e['departamento'] ?></td>
    <td>
        <a href="?eliminar=<?= $e['cedula'] ?>" 
           onclick="return confirm('¿Eliminar empleado?')">
           Eliminar
        </a>
    </td>
</tr>
<?php endwhile; ?>

</table>

</div>

</body>
</html>