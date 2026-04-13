<?php
require("../config/conexion.php");

$mensaje = "";

// REGISTRAR ENTRADA / SALIDA
if (isset($_POST['entrada']) || isset($_POST['salida'])) {

    $cedula = $_POST['cedula'];
    $departamento = $_POST['departamento'];

    // VALIDAR CÉDULA (FUNCIÓN)
    $val = $conexion->query("SELECT validar_cedula($cedula) as estado");
    $resVal = $val->fetch_assoc();

    if ($resVal['estado'] != 'Cédula válida') {
        $mensaje = $resVal['estado'];
    } else {

        // VALIDAR EMPLEADO + DEPARTAMENTO
        $validar = $conexion->query("
            SELECT * FROM empleados 
            WHERE cedula = $cedula 
            AND departamento_id = $departamento
        ");

        if ($validar->num_rows > 0) {

            if (isset($_POST['entrada'])) {
                $conexion->query("CALL registrar_marcado_transaccion($cedula,'Entrada')");
                // limpiar resultados del SP antes de cualquier otra query
                while ($conexion->more_results() && $conexion->next_result()) {}
                $mensaje = "Entrada registrada";
            }

            if (isset($_POST['salida'])) {
                $conexion->query("CALL registrar_marcado_transaccion($cedula,'Salida')");
                while ($conexion->more_results() && $conexion->next_result()) {}
                $mensaje = "Salida registrada";
            }

        } else {
            $mensaje = "Usuario no encontrado o no pertenece a esa área";
        }
    }
}
?>

<!DOCTYPE html>
<html>
<head>
<title>Marcar Asistencia</title>
<link rel="stylesheet" href="../assets/css/style.css">
</head>
<body>

<div class="content">
<h1>Registro de Asistencia</h1>

<form method="POST">
    <input type="number" name="cedula" placeholder="Ingrese su cédula" required>
    <br><br>

    <!-- SELECT DE DEPARTAMENTO -->
    <select name="departamento" required>
        <option value="">Selecciona tu área</option>
        <?php
        $deps = $conexion->query("SELECT * FROM departamentos");
        while($d = $deps->fetch_assoc()){
            echo "<option value='{$d['id']}'>{$d['nombre']}</option>";
        }
        ?>
    </select>

    <br><br>

    <button name="entrada" style="background:green;">Entrada</button>
    <button name="salida" style="background:red;">Salida</button>
</form>

<h3 style="color:green;"><?= $mensaje ?></h3>

<hr>

<h3>Consultar registros</h3>

<form method="POST">
    <input type="number" name="buscar" placeholder="Cédula" required>
    <button name="ver">Ver</button>
</form>

<?php
if (isset($_POST['ver'])) {

    $c = $_POST['buscar'];

    // LLAMAR AL SP para obtener registros
    $res = $conexion->query("CALL reporte_marcados_sp($c)");

    echo "<table border='1'>
    <tr><th>Fecha</th><th>Entrada</th><th>Salida</th><th>Horas</th></tr>";

    $entradas = [];
    $salidas = [];

    while ($r = $res->fetch_assoc()) {
        if ($r['tipo'] == 'Entrada') {
            $entradas[] = $r;
        } else {
            $salidas[] = $r;
        }
    }

    // limpiar resultados pendientes del SP antes de calcular horas
    while ($conexion->more_results() && $conexion->next_result()) {}

    // CALCULAR HORAS
    for ($i = 0; $i < count($entradas); $i++) {

        $entrada = $entradas[$i]['fecha_hora'] ?? null;
        $salida = $salidas[$i]['fecha_hora'] ?? null;
        $horas = "";

        if ($entrada && $salida) {
            $h = $conexion->query("SELECT calcular_horas('$entrada','$salida') as total");
            $resH = $h->fetch_assoc();
            $horas = $resH['total'] . " hrs";
            // limpiar resultados después de llamar la función
            while ($conexion->more_results() && $conexion->next_result()) {}
        }

        echo "<tr>
            <td>{$entradas[$i]['fecha']}</td>
            <td>$entrada</td>
            <td>$salida</td>
            <td>$horas</td>
        </tr>";
    }

    echo "</table>";
}
?>

</div>

</body>
</html>