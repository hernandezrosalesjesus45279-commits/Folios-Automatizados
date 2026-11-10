-- BASE DE DATOS: Sistema de asignación automatizada de números de oficio
-- Para SQL Server. Basada en el diagrama de datos y el diagrama de clases.
-- Cómo usarla: abre este archivo en SQL Server Management Studio y presiona F5.

CREATE DATABASE bd_control_oficios;
GO
USE bd_control_oficios;
GO

-- ============================================================
-- TABLA 1: departamento  (clase Departamento)
-- ============================================================
CREATE TABLE departamento (
    id_departamento INT IDENTITY(1,1) PRIMARY KEY,   -- se llena solo: 1, 2, 3...
    nombre          VARCHAR(50) NOT NULL,
    activo          BIT NOT NULL DEFAULT 1           -- 1 = activo, 0 = ya no se usa
);
GO

-- ============================================================
-- TABLA 2: usuarios  (clase Usuario)
-- ============================================================
CREATE TABLE usuarios (
    id_usuario      INT IDENTITY(1,1) PRIMARY KEY,
    nombre_completo VARCHAR(120) NOT NULL,
    usuario         VARCHAR(50)  NOT NULL UNIQUE,    -- no puede haber dos usuarios iguales
    contrasena      VARCHAR(255) NOT NULL,           -- se guarda cifrada
    rol             VARCHAR(30)  NOT NULL
        CHECK (rol IN ('Secretaria departamental', 'Secretaria del director')),
    id_departamento INT NOT NULL
        FOREIGN KEY REFERENCES departamento (id_departamento)
);
GO

-- ============================================================
-- TABLA 3: solicitudes_oficio  (clase Solicitud_Oficio)
-- ============================================================
CREATE TABLE solicitudes_oficio (
    id_solicitud    INT IDENTITY(1,1) PRIMARY KEY,
    numero_oficio   INT NOT NULL,
    anio            INT NOT NULL,                    -- EXTRA: año del oficio (reinicio anual)
    asunto          VARCHAR(250) NOT NULL,
    fecha_solicitud DATE    NOT NULL DEFAULT GETDATE(),   -- la pone el servidor solo
    hora_solicitud  TIME(0) NOT NULL DEFAULT GETDATE(),   -- la pone el servidor solo
    estado          VARCHAR(50) NOT NULL DEFAULT 'Asignado'
        CHECK (estado IN ('Asignado', 'Validado', 'Cancelado')),   -- solo estos 3
    id_usuario      INT NOT NULL
        FOREIGN KEY REFERENCES usuarios (id_usuario),
    id_departamento INT NOT NULL
        FOREIGN KEY REFERENCES departamento (id_departamento),
    UNIQUE (anio, numero_oficio)                     -- no repite el número en el mismo año
);
GO

-- ============================================================
-- TABLA 4 (EXTRA): bitacora_cancelacion
-- Guarda quién canceló un número, cuándo y por qué.
-- Si no quieres esta tabla, bórrala junto con la línea "anio" de arriba.
-- ============================================================
CREATE TABLE bitacora_cancelacion (
    id_bitacora       INT IDENTITY(1,1) PRIMARY KEY,
    id_solicitud      INT NOT NULL
        FOREIGN KEY REFERENCES solicitudes_oficio (id_solicitud),
    id_usuario        INT NOT NULL
        FOREIGN KEY REFERENCES usuarios (id_usuario),   -- quién canceló
    fecha_cancelacion DATE    NOT NULL DEFAULT GETDATE(),
    hora_cancelacion  TIME(0) NOT NULL DEFAULT GETDATE(),
    motivo            VARCHAR(250) NULL
);
GO

-- ============================================================
-- DATOS DE EJEMPLO (solo para probar)
-- ============================================================
INSERT INTO departamento (nombre) VALUES ('Recursos Humanos'), ('Dirección');

INSERT INTO usuarios (nombre_completo, usuario, contrasena, rol, id_departamento)
VALUES ('Ana López', 'ana', '1234', 'Secretaria departamental', 1),
       ('Secretaria del director', 'direccion', '1234', 'Secretaria del director', 2);

-- La fecha y la hora no se escriben: SQL Server las pone solo
INSERT INTO solicitudes_oficio (numero_oficio, anio, asunto, id_usuario, id_departamento)
VALUES (1, 2026, 'Solicitud de constancias laborales', 1, 1);

SELECT * FROM solicitudes_oficio;
GO
