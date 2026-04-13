-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 13-04-2026 a las 21:31:08
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `asistencia`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_empleado_sp` (IN `c` INT, IN `n` VARCHAR(255), IN `a` VARCHAR(255), IN `f` VARCHAR(255), IN `d` INT)   BEGIN
    INSERT INTO empleados (cedula, nombre, apellido, foto, departamento_id)
    VALUES (c,n,a,f,d);

    INSERT INTO historial (accion, fecha, descripcion, cedula)
    VALUES ('Insertado por SP', NOW(), CONCAT('Nombre: ', n), c);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_marcado_transaccion` (IN `p_cedula` INT, IN `p_tipo` VARCHAR(50))   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM empleados WHERE cedula = p_cedula) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Empleado no existe';
    END IF;

    INSERT INTO marcados (cedula, tipo, fecha)
    VALUES (p_cedula, p_tipo, CURDATE());

    INSERT INTO historial (accion, fecha, descripcion, cedula)
    VALUES (
        'Transacción',
        NOW(),
        CONCAT('Marcado ', p_tipo),
        p_cedula
    );

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporte_marcados_sp` (IN `c` INT)   BEGIN
    SELECT * FROM marcados WHERE cedula = c;
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `calcular_horas` (`inicio` DATETIME, `fin` DATETIME) RETURNS INT(11) DETERMINISTIC BEGIN
    RETURN TIMESTAMPDIFF(HOUR, inicio, fin);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `validar_cedula` (`ced` INT) RETURNS VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC BEGIN
    IF ced IS NULL OR ced <= 0 THEN
        RETURN 'Cédula inválida';
    ELSE
        RETURN 'Cédula válida';
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `departamentos`
--

CREATE TABLE `departamentos` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `departamentos`
--

INSERT INTO `departamentos` (`id`, `nombre`) VALUES
(1, 'Sistemas'),
(2, 'Recursos Humanos'),
(3, 'Contabilidad');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
--

CREATE TABLE `empleados` (
  `cedula` int(11) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `apellido` varchar(255) NOT NULL,
  `foto` varchar(255) NOT NULL,
  `departamento_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `empleados`
--

INSERT INTO `empleados` (`cedula`, `nombre`, `apellido`, `foto`, `departamento_id`) VALUES
(1001, 'Luis', 'Ramirez', 'foto1.jpg', 1),
(1002, 'Ana', 'Lopez', 'foto2.jpg', 2),
(1003, 'Juana', 'Lizarraga', 'default.jpg', 3);

--
-- Disparadores `empleados`
--
DELIMITER $$
CREATE TRIGGER `tr_nuevo_empleado` AFTER INSERT ON `empleados` FOR EACH ROW BEGIN
    INSERT INTO historial (accion, fecha, descripcion, cedula)
    VALUES ('Nuevo empleado', NOW(), CONCAT('Nombre: ', NEW.nombre), NEW.cedula);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial`
--

CREATE TABLE `historial` (
  `id` int(11) NOT NULL,
  `accion` varchar(100) DEFAULT NULL,
  `fecha` datetime DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `cedula` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `historial`
--

INSERT INTO `historial` (`id`, `accion`, `fecha`, `descripcion`, `cedula`) VALUES
(1, 'Nuevo empleado', '2026-03-29 17:06:03', 'Nombre: Luis', 1001),
(2, 'Insertado por SP', '2026-03-29 17:06:03', 'Nombre: Luis', 1001),
(3, 'Nuevo empleado', '2026-03-29 17:06:03', 'Nombre: Ana', 1002),
(4, 'Insertado por SP', '2026-03-29 17:06:03', 'Nombre: Ana', 1002),
(7, 'Nuevo acceso', '2026-03-29 17:06:07', 'Cédula: 1001', 1001),
(8, 'Transacción', '2026-03-29 17:06:07', 'Marcado Entrada', 1001),
(9, 'Nuevo acceso', '2026-03-29 17:06:08', 'Cédula: 1001', 1001),
(10, 'Transacción', '2026-03-29 17:06:08', 'Marcado Salida', 1001),
(11, 'Nuevo acceso', '2026-03-29 17:06:09', 'Cédula: 1002', 1002),
(12, 'Transacción', '2026-03-29 17:06:09', 'Marcado Entrada', 1002),
(15, 'Nuevo acceso', '2026-03-29 17:07:38', 'Cédula: 1001', 1001),
(16, 'Transacción', '2026-03-29 17:07:38', 'Marcado Entrada', 1001),
(17, 'Nuevo acceso', '2026-03-29 17:07:45', 'Cédula: 1001', 1001),
(18, 'Transacción', '2026-03-29 17:07:45', 'Marcado Salida', 1001),
(19, 'Nuevo acceso', '2026-03-29 17:10:35', 'Cédula: 1001', 1001),
(20, 'Transacción', '2026-03-29 17:10:35', 'Marcado Entrada', 1001),
(21, 'Nuevo acceso', '2026-03-29 17:10:40', 'Cédula: 1001', 1001),
(22, 'Transacción', '2026-03-29 17:10:40', 'Marcado Salida', 1001),
(23, 'Nuevo acceso', '2026-03-29 17:29:18', 'Cédula: 1001', 1001),
(24, 'Transacción', '2026-03-29 17:29:18', 'Marcado Entrada', 1001),
(25, 'Nuevo acceso', '2026-03-29 19:45:37', 'Cédula: 1001', 1001),
(26, 'Transacción', '2026-03-29 19:45:37', 'Marcado Salida', 1001),
(31, 'Nuevo empleado', '2026-03-29 19:46:53', 'Nombre: Juana', 1003),
(32, 'Insertado por SP', '2026-03-29 19:46:53', 'Nombre: Juana', 1003),
(33, 'Nuevo acceso', '2026-04-10 11:39:55', 'Cédula: 1001', 1001),
(34, 'Transacción', '2026-04-10 11:39:55', 'Marcado Entrada', 1001),
(35, 'Nuevo acceso', '2026-04-10 11:40:02', 'Cédula: 1001', 1001),
(36, 'Transacción', '2026-04-10 11:40:02', 'Marcado Salida', 1001),
(37, 'Nuevo acceso', '2026-04-12 21:45:21', 'Cédula: 1001', 1001),
(38, 'Transacción', '2026-04-12 21:45:21', 'Marcado Entrada', 1001),
(39, 'Nuevo acceso', '2026-04-12 21:45:39', 'Cédula: 1002', 1002),
(40, 'Transacción', '2026-04-12 21:45:39', 'Marcado Entrada', 1002),
(41, 'Nuevo acceso', '2026-04-12 21:46:55', 'Cédula: 1002', 1002),
(42, 'Transacción', '2026-04-12 21:46:55', 'Marcado Salida', 1002);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `marcados`
--

CREATE TABLE `marcados` (
  `id` int(11) NOT NULL,
  `cedula` int(11) NOT NULL,
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `tipo` varchar(50) NOT NULL,
  `fecha` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `marcados`
--

INSERT INTO `marcados` (`id`, `cedula`, `fecha_hora`, `tipo`, `fecha`) VALUES
(1, 1001, '2026-03-30 00:06:07', 'Entrada', '2026-03-29'),
(2, 1001, '2026-03-30 00:06:08', 'Salida', '2026-03-29'),
(3, 1002, '2026-03-30 00:06:09', 'Entrada', '2026-03-29'),
(5, 1001, '2026-03-30 00:07:38', 'Entrada', '2026-03-29'),
(6, 1001, '2026-03-30 00:07:45', 'Salida', '2026-03-29'),
(7, 1001, '2026-03-30 00:10:35', 'Entrada', '2026-03-29'),
(8, 1001, '2026-03-30 00:10:40', 'Salida', '2026-03-29'),
(9, 1001, '2026-03-30 00:29:18', 'Entrada', '2026-03-29'),
(10, 1001, '2026-03-30 02:45:37', 'Salida', '2026-03-29'),
(11, 1001, '2026-04-10 18:39:55', 'Entrada', '2026-04-10'),
(12, 1001, '2026-04-10 18:40:02', 'Salida', '2026-04-10'),
(13, 1001, '2026-04-13 04:45:21', 'Entrada', '2026-04-12'),
(14, 1002, '2026-04-13 04:45:39', 'Entrada', '2026-04-12'),
(15, 1002, '2026-04-13 04:46:55', 'Salida', '2026-04-12');

--
-- Disparadores `marcados`
--
DELIMITER $$
CREATE TRIGGER `tr_registro_acceso` AFTER INSERT ON `marcados` FOR EACH ROW BEGIN
    INSERT INTO historial (accion, fecha, descripcion, cedula)
    VALUES ('Nuevo acceso', NOW(), CONCAT('Cédula: ', NEW.cedula), NEW.cedula);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id` int(11) NOT NULL,
  `nombre_usuario` varchar(255) NOT NULL,
  `clave` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id`, `nombre_usuario`, `clave`) VALUES
(1, 'admin', '8cb2237d0679ca88db6464eac60da96345513964');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `departamentos`
--
ALTER TABLE `departamentos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD PRIMARY KEY (`cedula`),
  ADD KEY `fk_empleados_departamentos` (`departamento_id`);

--
-- Indices de la tabla `historial`
--
ALTER TABLE `historial`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_historial_empleado` (`cedula`);

--
-- Indices de la tabla `marcados`
--
ALTER TABLE `marcados`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_marcados_empleados` (`cedula`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `departamentos`
--
ALTER TABLE `departamentos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `historial`
--
ALTER TABLE `historial`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT de la tabla `marcados`
--
ALTER TABLE `marcados`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD CONSTRAINT `fk_empleados_departamentos` FOREIGN KEY (`departamento_id`) REFERENCES `departamentos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `historial`
--
ALTER TABLE `historial`
  ADD CONSTRAINT `fk_historial_empleado` FOREIGN KEY (`cedula`) REFERENCES `empleados` (`cedula`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `marcados`
--
ALTER TABLE `marcados`
  ADD CONSTRAINT `fk_marcados_empleados` FOREIGN KEY (`cedula`) REFERENCES `empleados` (`cedula`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
