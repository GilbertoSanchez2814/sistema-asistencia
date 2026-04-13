<?php
session_start();
require("config/conexion.php");

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $user = $_POST['usuario'];
    $pass = $_POST['clave'];

    $sql = "SELECT * FROM usuario WHERE nombre_usuario=? AND clave=SHA1(?)";
    $stmt = $conexion->prepare($sql);
    $stmt->bind_param("ss", $user, $pass);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $_SESSION['admin'] = $user;
        header("Location: admin/dashboard.php");
    } else {
        $error = "Datos incorrectos";
    }
}
?>

<!DOCTYPE html>
<html>
<head>
<title>Login</title>
<link rel="stylesheet" href="assets/css/style.css">
</head>
<body>

<div class="login-box">
    <h2>Login</h2>
    <form method="POST">
        <input type="text" name="usuario" placeholder="Usuario" required>
        <input type="password" name="clave" placeholder="Contraseña" required>
        <button type="submit">Entrar</button>
    </form>

    <?php if(isset($error)) echo "<p>$error</p>"; ?>
</div>

</body>
</html>