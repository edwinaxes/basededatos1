-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 23-05-2024 a las 14:28:09
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
-- Base de datos: `alquilarcanchas`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_cliente` (IN `p_id` INT, IN `p_nombre` VARCHAR(100), IN `p_identificacion` VARCHAR(20), IN `p_direccion` VARCHAR(255), IN `p_correo_electronico` VARCHAR(100), IN `p_numero_telefono` VARCHAR(15), IN `p_contrasena` VARCHAR(255))   BEGIN
    UPDATE clientes
    SET nombre = p_nombre, identificacion = p_identificacion, direccion = p_direccion, correo_electronico = p_correo_electronico, numero_telefono = p_numero_telefono, contrasena = p_contrasena
    WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cancelar_reserva` (IN `p_reserva_id` INT)   BEGIN
    UPDATE reservas
    SET estado = 'cancelado'
    WHERE id = p_reserva_id AND estado = 'reservado' AND fecha >= CURDATE() + INTERVAL 1 DAY;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarCanchasDisponibles` ()   BEGIN
    SELECT * FROM canchas WHERE disponibilidad = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarHistorialReservasPorCliente` (IN `p_cliente_id` INT)   BEGIN
    SELECT 
        r.id AS reserva_id,
        c.nombre AS cliente_nombre,
        can.ubicacion AS cancha_ubicacion,
        r.fecha,
        r.hora_inicio,
        r.duracion,
        r.alquila_indumentaria,
        r.servicio_arbitraje,
        r.estado,
        p.metodo_pago,
        p.fecha_pago,
        p.monto
    FROM 
        reservas r
        INNER JOIN clientes c ON r.cliente_id = c.id
        INNER JOIN canchas can ON r.cancha_id = can.id
        LEFT JOIN pagos p ON r.id = p.reserva_id
    WHERE 
        r.cliente_id = p_cliente_id
    ORDER BY 
        r.fecha DESC, r.hora_inicio DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `crear_cliente` (IN `p_nombre` VARCHAR(100), IN `p_identificacion` VARCHAR(20), IN `p_direccion` VARCHAR(255), IN `p_correo_electronico` VARCHAR(100), IN `p_numero_telefono` VARCHAR(15), IN `p_contrasena` VARCHAR(255))   BEGIN
    INSERT INTO clientes (nombre, identificacion, direccion, correo_electronico, numero_telefono, contrasena)
    VALUES (p_nombre, p_identificacion, p_direccion, p_correo_electronico, p_numero_telefono, p_contrasena);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_cliente` (IN `p_id` INT)   BEGIN
    DELETE FROM clientes WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `leer_cliente` (IN `p_id` INT)   BEGIN
    SELECT * FROM clientes WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pagar_reserva` (IN `p_reserva_id` INT, IN `p_metodo_pago` VARCHAR(50), IN `p_fecha_pago` DATE, IN `p_monto` DECIMAL(10,2))   BEGIN
    INSERT INTO pagos (reserva_id, metodo_pago, fecha_pago, monto)
    VALUES (p_reserva_id, p_metodo_pago, p_fecha_pago, p_monto);
    
    UPDATE reservas
    SET estado = 'pagado'
    WHERE id = p_reserva_id;
    
    -- Aquí puedes agregar lógica para enviar una confirmación al usuario
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_cancha` (IN `p_ubicacion` VARCHAR(255), IN `p_tamano` VARCHAR(50), IN `p_tipo_superficie` VARCHAR(50), IN `p_precio_por_hora` DECIMAL(10,2))   BEGIN
    INSERT INTO canchas (ubicacion, tamano, tipo_superficie, precio_por_hora)
    VALUES (p_ubicacion, p_tamano, p_tipo_superficie, p_precio_por_hora);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_cliente` (IN `p_nombre` VARCHAR(100), IN `p_identificacion` VARCHAR(20), IN `p_direccion` VARCHAR(255), IN `p_correo_electronico` VARCHAR(100), IN `p_numero_telefono` VARCHAR(15), IN `p_contrasena` VARCHAR(255))   BEGIN
    INSERT INTO clientes (nombre, identificacion, direccion, correo_electronico, numero_telefono, contrasena)
    VALUES (p_nombre, p_identificacion, p_direccion, p_correo_electronico, p_numero_telefono, p_contrasena);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reservar_cancha` (IN `p_cliente_id` INT, IN `p_cancha_id` INT, IN `p_fecha` DATE, IN `p_hora_inicio` TIME, IN `p_duracion` INT, IN `p_alquila_indumentaria` BOOLEAN, IN `p_servicio_arbitraje` BOOLEAN)   BEGIN
    INSERT INTO reservas (cliente_id, cancha_id, fecha, hora_inicio, duracion, alquila_indumentaria, servicio_arbitraje)
    VALUES (p_cliente_id, p_cancha_id, p_fecha, p_hora_inicio, p_duracion, p_alquila_indumentaria, p_servicio_arbitraje);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `canchas`
--

CREATE TABLE `canchas` (
  `id` int(11) NOT NULL,
  `ubicacion` varchar(255) NOT NULL,
  `tamano` varchar(50) NOT NULL,
  `tipo_superficie` varchar(50) NOT NULL,
  `disponibilidad` tinyint(1) DEFAULT 1,
  `precio_por_hora` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `canchas`
--

INSERT INTO `canchas` (`id`, `ubicacion`, `tamano`, `tipo_superficie`, `disponibilidad`, `precio_por_hora`) VALUES
(1, 'Centro Deportivo A', '20x40', 'Césped', 1, 50.00),
(2, 'Centro Deportivo B', '30x50', 'Sintético', 0, 60.00),
(3, 'Centro Deportivo C', '25x45', 'Césped', 0, 55.00),
(4, 'Centro Deportivo D', '35x55', 'Hormigón', 0, 70.00),
(5, 'Centro Deportivo E', '40x60', 'Sintético', 0, 80.00),
(6, 'san juan', 'futbol11', 'pasto', 1, 350.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `identificacion` varchar(20) NOT NULL,
  `direccion` varchar(255) NOT NULL,
  `correo_electronico` varchar(100) NOT NULL,
  `numero_telefono` varchar(15) NOT NULL,
  `contrasena` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`id`, `nombre`, `identificacion`, `direccion`, `correo_electronico`, `numero_telefono`, `contrasena`) VALUES
(1, 'Juan Pérez', 'ID001', 'Calle Falsa 123', 'juan.perez@example.com', '555-1234', 'contrasena1'),
(2, 'María Gómez', 'ID002', 'Avenida Siempre Viva 456', 'maria.gomez@example.com', '555-5678', 'contrasena2'),
(3, 'Carlos Ramírez', 'ID003', 'Boulevard de los Sueños 789', 'carlos.ramirez@example.com', '555-9101', 'contrasena3'),
(4, 'Ana Fernández', 'ID004', 'Pasaje de las Flores 321', 'ana.fernandez@example.com', '555-1122', 'contrasena4'),
(5, '6565', '656', '6565', '565', '6565', '6565'),
(8, 'andres', '10215', 'cr3', 'andres@example', '322541', '54321'),
(9, '4', '1', '4', '7', '7', '4'),
(11, 'oscar', '45879541254', 'cre3', 'oscar@example', '547154', '4587'),
(12, '*', '1254', 'ree', 'ssf@dssd', '4587', '4521');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `equipos_alquiler`
--

CREATE TABLE `equipos_alquiler` (
  `id` int(11) NOT NULL,
  `tipo` varchar(255) DEFAULT NULL,
  `precio` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `equipos_alquiler`
--

INSERT INTO `equipos_alquiler` (`id`, `tipo`, `precio`) VALUES
(1, 'Balón', 10.00),
(2, 'Guantes', 15.00),
(3, 'Canilleras', 20.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos`
--

CREATE TABLE `pagos` (
  `id` int(11) NOT NULL,
  `reserva_id` int(11) NOT NULL,
  `metodo_pago` varchar(50) NOT NULL,
  `fecha_pago` date NOT NULL,
  `monto` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pagos`
--

INSERT INTO `pagos` (`id`, `reserva_id`, `metodo_pago`, `fecha_pago`, `monto`) VALUES
(1, 1, 'Tarjeta de Crédito', '2024-05-19', 100.00),
(2, 2, 'PayPal', '2024-05-20', 60.00),
(3, 3, 'Transferencia Bancaria', '2024-05-21', 165.00),
(4, 4, 'Efectivo', '2024-05-22', 140.00),
(5, 5, 'Tarjeta de Débito', '2024-05-23', 80.00),
(6, 2, 'efectivo', '0000-00-00', 200000.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reservas`
--

CREATE TABLE `reservas` (
  `id` int(11) NOT NULL,
  `cliente_id` int(11) NOT NULL,
  `cancha_id` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `hora_inicio` time NOT NULL,
  `duracion` int(11) NOT NULL,
  `alquila_indumentaria` tinyint(1) DEFAULT 0,
  `servicio_arbitraje` tinyint(1) DEFAULT 0,
  `estado` enum('reservado','cancelado','pagado') DEFAULT 'reservado',
  `equipo_alquiler_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `reservas`
--

INSERT INTO `reservas` (`id`, `cliente_id`, `cancha_id`, `fecha`, `hora_inicio`, `duracion`, `alquila_indumentaria`, `servicio_arbitraje`, `estado`, `equipo_alquiler_id`) VALUES
(1, 1, 1, '2024-05-20', '10:00:00', 2, 0, 0, 'cancelado', NULL),
(2, 2, 2, '2024-05-21', '11:00:00', 1, 1, 0, 'pagado', NULL),
(3, 3, 3, '2024-05-22', '12:00:00', 3, 0, 1, 'reservado', NULL),
(4, 4, 4, '2024-05-23', '13:00:00', 2, 1, 1, 'reservado', NULL),
(5, 5, 5, '2024-05-24', '14:00:00', 1, 0, 0, 'reservado', NULL),
(6, 1, 4, '2024-05-30', '20:40:24', 1, 0, 0, 'reservado', NULL);

--
-- Disparadores `reservas`
--
DELIMITER $$
CREATE TRIGGER `actualizar_disponibilidad_cancha_cancelacion` AFTER UPDATE ON `reservas` FOR EACH ROW BEGIN
    IF NEW.estado = 'cancelado' AND OLD.estado != 'cancelado' THEN
        UPDATE canchas SET disponibilidad = TRUE WHERE id = NEW.cancha_id;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `actualizar_disponibilidad_cancha_reserva` AFTER INSERT ON `reservas` FOR EACH ROW BEGIN
    IF NEW.estado = 'reservado' THEN
        UPDATE canchas SET disponibilidad = FALSE WHERE id = NEW.cancha_id;
    END IF;
END
$$
DELIMITER ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `canchas`
--
ALTER TABLE `canchas`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `correo_electronico` (`correo_electronico`);

--
-- Indices de la tabla `equipos_alquiler`
--
ALTER TABLE `equipos_alquiler`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reserva_id` (`reserva_id`);

--
-- Indices de la tabla `reservas`
--
ALTER TABLE `reservas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cliente_id` (`cliente_id`),
  ADD KEY `cancha_id` (`cancha_id`),
  ADD KEY `reservas_ibfk_4` (`equipo_alquiler_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `canchas`
--
ALTER TABLE `canchas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `equipos_alquiler`
--
ALTER TABLE `equipos_alquiler`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `pagos`
--
ALTER TABLE `pagos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `reservas`
--
ALTER TABLE `reservas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD CONSTRAINT `pagos_ibfk_1` FOREIGN KEY (`reserva_id`) REFERENCES `reservas` (`id`);

--
-- Filtros para la tabla `reservas`
--
ALTER TABLE `reservas`
  ADD CONSTRAINT `reservas_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`),
  ADD CONSTRAINT `reservas_ibfk_2` FOREIGN KEY (`cancha_id`) REFERENCES `canchas` (`id`),
  ADD CONSTRAINT `reservas_ibfk_4` FOREIGN KEY (`equipo_alquiler_id`) REFERENCES `equipos_alquiler` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
