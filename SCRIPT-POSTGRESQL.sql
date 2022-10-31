--ORDEN DE INSTALACIÓN:
-- DROP TABLE ctl_puestos;
CREATE TABLE ctl_puestos(   
   num_puesto INTEGER DEFAULT 0 NOT NULL,
   des_puesto VARCHAR(50) DEFAULT 'POR DEFINIR' NOT NULL,
   fec_registro  timestamp DEFAULT TIMENOW(),
   PRIMARY KEY(num_puesto)
);
CREATE INDEX idx_puestos ON ctl_puestos (num_puesto);
INSERT INTO ctl_puestos (num_puesto,des_puesto) VALUES (1,'PRUEBA');
INSERT INTO ctl_puestos (num_puesto,des_puesto) VALUES (2,'SOBRE-PRUEBA');
SELECT * FROM ctl_puestos; --WHERE num_puesto = 2;

-- DROP TABLE ctl_empleados;a
CREATE TABLE ctl_empleados(
   idu_empleado SERIAL,
   num_puesto INTEGER DEFAULT 0 NOT NULL,
   des_nombre VARCHAR(25) DEFAULT '' NOT NULL,
   des_apellido VARCHAR(25) DEFAULT '' NOT NULL,
   des_correo VARCHAR(100) DEFAULT '' NOT NULL,
   fec_registro  timestamp DEFAULT TIMENOW(),
   PRIMARY KEY(idu_empleado),
   CONSTRAINT fk_ctl_puestos
      FOREIGN KEY(num_puesto) 
	  REFERENCES ctl_puestos(num_puesto)
);
CREATE INDEX idx_empleados ON ctl_empleados (idu_empleado,num_puesto);
INSERT INTO ctl_empleados (num_puesto,des_nombre,des_apellido,des_correo) VALUES (2,'FREDY','BOJORQUEZ','fredy@bojorquez.com');
INSERT INTO ctl_empleados (num_puesto,des_nombre,des_apellido,des_correo) VALUES (1,'ALONSO','DIAZ','alonso@bojorquez.com');
INSERT INTO ctl_empleados (num_puesto,des_nombre,des_apellido,des_correo) VALUES (1,'PRUEBA','TAMBIEN','prueba@bojorquez.com');
SELECT * FROM ctl_empleados;

-- DROP TABLE ctl_inventario;
CREATE TABLE ctl_inventario(
   idu_codigo INTEGER DEFAULT 0 NOT NULL,
   des_codigo VARCHAR(50) DEFAULT '' NOT NULL,
   imp_precio FLOAT DEFAULT 0.00 NOT NULL,
   num_existencia INTEGER DEFAULT 0 NOT NULL,
   imp_totalinventario FLOAT DEFAULT 0.00 NOT NULL,
   fec_registro  TIMESTAMP DEFAULT TIMENOW(),
   PRIMARY KEY(idu_codigo)   
);
CREATE INDEX idx_inventario ON ctl_inventario (idu_codigo,des_codigo);
INSERT INTO ctl_inventario (idu_codigo,des_codigo,imp_precio) VALUES (111111,'TELEVISION 55',10499.99);
INSERT INTO ctl_inventario (idu_codigo,des_codigo,imp_precio) VALUES (222222,'LAVADORA LG 19 TONELADAS',8999.99);
INSERT INTO ctl_inventario (idu_codigo,des_codigo,imp_precio) VALUES (333333,'COMEDOR CEDRO 8 SILLAS',18999.99);
SELECT * FROM ctl_inventario;

-- DROP TABLE mov_polizas;
CREATE TABLE mov_polizas(
   idu_poliza SERIAL,
   idu_codigo INTEGER DEFAULT 0 NOT NULL,
   imp_cargo FLOAT DEFAULT 0.00 NOT NULL,
   idu_empleado INTEGER DEFAULT 0 NOT NULL,
   num_cantidad INTEGER DEFAULT 0 NOT NULL,
   idu_cancelada BOOLEAN DEFAULT FALSE,
   num_empleadocancelo INTEGER DEFAULT 0 NOT NULL,
   fec_registro  TIMESTAMP DEFAULT TIMENOW(),
   PRIMARY KEY(idu_poliza),
      CONSTRAINT fk_ctl_inventario
      FOREIGN KEY(idu_codigo) 
	  REFERENCES ctl_inventario(idu_codigo),
      CONSTRAINT fk_ctl_empleados
      FOREIGN KEY(idu_empleado) 
	   REFERENCES ctl_empleados(idu_empleado)
);
CREATE INDEX idx_polizas ON mov_polizas (idu_poliza,idu_empleado,idu_codigo);
INSERT INTO mov_polizas (idu_codigo,idu_empleado,num_cantidad,imp_cargo) VALUES (111111,3,1,10499.99);
INSERT INTO mov_polizas (idu_codigo,idu_empleado,num_cantidad,imp_cargo) VALUES (222222,3,1,8999.99);
INSERT INTO mov_polizas (idu_codigo,idu_empleado,num_cantidad,imp_cargo) VALUES (333333,4,1,18999.99);
SELECT * FROM mov_polizas;

-------------------------------
--ORDEN DE ELIMINACIÓN---------
-------------------------------
DROP TABLE mov_polizas;		---
DROP TABLE ctl_inventario;	---
DROP TABLE ctl_empleados;	---
DROP TABLE ctl_puestos;		---
-------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--select * from mov_polizas  
--drop  FUNCTION fun_guardapoliza(INTEGER,DOUBLE PRECISION,INTEGER)
--select * from fun_guardapoliza(222222,1542,2,9)
CREATE OR REPLACE FUNCTION fun_guardapoliza(INTEGER,DOUBLE PRECISION,INTEGER,INTEGER)
 RETURNS INTEGER AS
 $BODY$
 DECLARE
	codigo	 	ALIAS FOR $1;
	importe		ALIAS FOR $2;
	cantidad	ALIAS FOR $3;
	empleado        ALIAS FOR $4;
 BEGIN	
	INSERT INTO mov_polizas 
	(idu_codigo,imp_cargo,num_cantidad,idu_empleado)
	VALUES
	(codigo,importe,cantidad,empleado);
	RETURN 1;
 END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

--SELECT * FROM fun_eliminapuesto(1)
CREATE OR REPLACE FUNCTION fun_eliminapoliza(INTEGER)
 RETURNS INTEGER AS
 $BODY$
 DECLARE
	poliza	 	ALIAS FOR $1;
	empleado	ALIAS FOR $2;
 BEGIN	
	UPDATE mov_polizas 
	SET idu_cancelada = true, num_empleadocancelo = empleado
	WHERE idu_poliza = poliza;
	RETURN 1;
 END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;


--drop function fun_consultaempleado(INTEGER)
SELECT piliza,codigo,cargo,empleado,cantidad FROM fun_consultapoliza(1)
CREATE OR REPLACE FUNCTION fun_consultapoliza(INTEGER)
	RETURNS TABLE(poliza INTEGER, codigo INTEGER, cargo DOUBLE PRECISION, empleado INTEGER, cantidad INTEGER) AS
$BODY$
DECLARE
	idpoliza	ALIAS FOR $1;
	BEGIN
		RETURN QUERY 
			SELECT 
			   idu_poliza,idu_codigo,imp_cargo,idu_empleado,num_cantidad FROM mov_polizas WHERE idu_poliza = idpoliza AND idu_cancelada = FALSE;
	END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;


--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

SELECT * FROM fun_actualizapuesto(1,'CAMBIO')
CREATE OR REPLACE FUNCTION fun_actualizapuesto(INTEGER,VARCHAR(50))
 RETURNS INTEGER AS
 $BODY$
 DECLARE
	puesto	 		ALIAS FOR $1;
	descripcion		ALIAS FOR $2;	
 BEGIN	
	UPDATE ctl_puestos 
	SET des_puesto = descripcion
	WHERE num_puesto = puesto;
	RETURN 1;
 END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

SELECT * FROM fun_eliminapuesto(1)
CREATE OR REPLACE FUNCTION fun_eliminapuesto(INTEGER)
 RETURNS INTEGER AS
 $BODY$
 DECLARE
	puesto	 	ALIAS FOR $1;
	countID INTEGER DEFAULT 0;
 BEGIN	
	IF NOT EXISTS (SELECT num_puesto FROM ctl_empleados WHERE num_puesto = puesto LIMIT 1) THEN
		DELETE FROM ctl_puestos WHERE num_puesto = puesto;	
		RETURN 1;
	ELSE		
		RETURN 0;
	END IF;
 END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION fun_guardaempleado(INTEGER,VARCHAR(50))
 RETURNS TABLE(idEmp INTEGER) AS
 $BODY$
 DECLARE
	puesto	 	ALIAS FOR $1;
	descripcion	ALIAS FOR $2;
 BEGIN	
	IF NOT EXISTS (SELECT num_puesto FROM ctl_puestos WHERE num_puesto = puesto LIMIT 1)THEN
		INSERT INTO ctl_puestos 
		(num_puesto,des_apellido)
		VALUES
		(puesto,descripcion);
		RETURN 1
	ELSE
		RETURN 0;
	END IF;
	
	
 END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;



--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--drop function fun_consultaempleado(INTEGER)
SELECT * FROM fun_consultaempleado(1)
CREATE OR REPLACE FUNCTION fun_consultaempleado(INTEGER)
	RETURNS TABLE(idEmpl INTEGER, iPuesto integer, dNombre VARCHAR(25),dApellido VARCHAR(25),dCorreo VARCHAR(100), fRegistro TIMESTAMP) AS
$BODY$
DECLARE
	idEmpleado	 		ALIAS FOR $1;
	BEGIN
		RETURN QUERY 
			SELECT 
			   idu_empleado,num_puesto,des_nombre,des_apellido,des_correo,fec_registro FROM ctl_empleados WHERE idu_empleado =idEmpleado;			
	END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

SELECT * FROM fun_actualizaempleado(1)
CREATE OR REPLACE FUNCTION fun_actualizaempleado(INTEGER,INTEGER,VARCHAR(25),VARCHAR(25),VARCHAR(100))
 RETURNS INTEGER AS
 $BODY$
 DECLARE
	idEmpleado	 	ALIAS FOR $1;
	iPuesto	 		ALIAS FOR $2;
	dNombre	 		ALIAS FOR $3;
	dApellido	 	ALIAS FOR $4;
	dCorreo	 		ALIAS FOR $5;
 BEGIN	
	IF ((iPuesto != 0 OR iPuesto != NULL) THEN
		UPDATE ctl_empleados SET num_puesto = iPuesto WHERE idu_empleado =idEmpleado;
	END IF;	
	IF ((dNombre != '' OR dNombre != NULL)) THEN
		UPDATE ctl_empleados SET des_nombre = dNombre WHERE idu_empleado =idEmpleado;
	END IF;	
	IF ((dApellido != '' OR dApellido != NULL)) THEN
		UPDATE ctl_empleados SET des_apellido = dApellido WHERE idu_empleado =idEmpleado;
	END IF;	
	IF (dCorreo = '' OR dCorreo = NULL)) THEN
		UPDATE ctl_empleados SET des_correo = dCorreo WHERE idu_empleado =idEmpleado;
	END IF;	
	RETURN 1;
 END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

SELECT * FROM fun_eliminaempleado(1)
CREATE OR REPLACE FUNCTION fun_eliminaempleado(INTEGER)
 RETURNS INTEGER AS
 $BODY$
 DECLARE
	idEmpleado	 	ALIAS FOR $1;
	countID INTEGER DEFAULT 0;
 BEGIN	
	SELECT COUNT(*) INTO countID FROM mov_polizas WHERE idu_empleado = idEmpleado;
	IF countID > 0 THEN                 
		RETURN 0;
	ELSE
		DELETE FROM ctl_empleados WHERE idu_empleado =idEmpleado;
		RETURN 1;
	END IF;
 END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

--select fun_guardaempleado('PRUEBA DE INSERT','CON APELLIDO',1,'correo_test@test')
 --drop FUNCTION fun_guardaempleado(VARCHAR(25),VARCHAR(25),INTEGER, VARCHAR(100))
CREATE OR REPLACE FUNCTION fun_guardaempleado(VARCHAR(25),VARCHAR(25),INTEGER, VARCHAR(100))
 RETURNS TABLE(idEmp INTEGER) AS
 $BODY$
 DECLARE
	dNombre	 	ALIAS FOR $1;
	dApellido	ALIAS FOR $2;
	numPuesto	ALIAS FOR $3;
	dCorreo	 	ALIAS FOR $4;
	idEmpleado 	INTEGER DEFAULT 0;

 BEGIN	
	INSERT INTO ctl_empleados 
	(des_nombre,des_apellido,num_puesto,des_correo) 
	VALUES
	(dNombre,dApellido,numPuesto,dCorreo);
	RETURN QUERY 
	SELECT MAX(idu_empleado) FROM ctl_empleados LIMIT 1;	
	
 END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;


--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--drop FUNCTION fun_consultainventario(INTEGER)
CREATE OR REPLACE FUNCTION fun_consultainventario(INTEGER)
	RETURNS TABLE(codigo INTEGER, nombre VARCHAR(50), precio float, existencia INTEGER, imptotal float, fRegistro TIMESTAMP) AS
$BODY$
DECLARE
	idCodigo	ALIAS FOR $1;
	BEGIN
		RETURN QUERY 
			SELECT 
			   idu_codigo,des_codigo,imp_precio,num_existencia,imp_totalinventario,fec_registro FROM ctl_inventario WHERE idu_codigo = idCodigo;		
	END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
--SELECT * FROM fun_consultainventario(11111)

SELECT * FROM fun_actualizaempleado(1)
CREATE OR REPLACE FUNCTION fun_actualizainventario(INTEGER,VARCHAR(50),FLOAT,INTEGER)
 RETURNS INTEGER AS
 $BODY$
 DECLARE
	idCodigo	 	ALIAS FOR $1;
	descripcion		ALIAS FOR $2;
	precio	 		ALIAS FOR $3;
	existencia	 	ALIAS FOR $4;
	total 	INTEGER DEFAULT 0;
 BEGIN	
	UPDATE ctl_inventario 
	SET des_codigo = descripcion, imp_precio = precio, num_existencia = existencia 
	WHERE idu_codigo = idCodigo;
	SELECT (num_existencia * imp_precio) INTO total 
	FROM ctl_inventario 
	WHERE idu_codigo = idCodigo
	GROUP BY num_existencia, imp_precio;
	UPDATE ctl_inventario SET imp_totalinventario = total 
	WHERE idu_codigo = idCodigo;
	RETURN 1;
 END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

SELECT * FROM fun_eliminainventario(1)
CREATE OR REPLACE FUNCTION fun_eliminainventario(INTEGER)
 RETURNS INTEGER AS
 $BODY$
 DECLARE
	idCodigo	 ALIAS FOR $1;
	countID INTEGER DEFAULT 0;
 BEGIN	
	SELECT COUNT(*) INTO countID FROM ctl_inventario WHERE idu_codigo = idCodigo;
	IF countID > 0 THEN                 
		DELETE FROM ctl_inventario WHERE idu_codigo = idCodigo;
		RETURN 1;
	ELSE
		RETURN 0;
	END IF;
 END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

--select fun_guardaempleado('PRUEBA DE INSERT','CON APELLIDO',1,'correo_test@test')
 --drop FUNCTION fun_guardaempleado(VARCHAR(25),VARCHAR(25),INTEGER, VARCHAR(100))
CREATE OR REPLACE FUNCTION fun_guardainventario(INTEGER,VARCHAR(50),FLOAT,INTEGER)
 RETURNS INTEGER AS
 $BODY$
 DECLARE
	idCodigo	 	ALIAS FOR $1;
	descripcion		ALIAS FOR $2;
	precio	 		ALIAS FOR $3;
	existencia	 	ALIAS FOR $4;
	total 	INTEGER DEFAULT 0;
 BEGIN	
	IF NOT EXISTS (SELECT idu_codigo FROM ctl_inventario WHERE idu_codigo = idCodigo) THEN
		INSERT INTO ctl_inventario 
		(idu_codigo, des_codigo, imp_precio, num_existencia) 
		VALUES
		(idCodigo, descripcion, precio, existencia);
		UPDATE ctl_inventario 
		SET imp_totalinventario = (existencia * precio) 
		WHERE idu_codigo = idCodigo;
		
	END IF;
	RETURN 1;	
 END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;