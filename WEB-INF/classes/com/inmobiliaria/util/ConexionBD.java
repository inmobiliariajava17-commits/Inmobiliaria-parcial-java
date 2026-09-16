package com.inmobiliaria.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Clase centralizada para obtener conexiones JDBC a la base de datos.
 * Toda clase DAO debe usar ConexionBD.obtenerConexion() en vez de
 * escribir la cadena de conexión repetida en cada clase.
 */
public class ConexionBD {

    private static Properties propiedades;

    // Se cargan los datos de conexión UNA sola vez, al iniciar la clase.
    static {
        try {
            propiedades = new Properties();
            InputStream input = ConexionBD.class.getClassLoader()
                    .getResourceAsStream("db.properties");
            if (input == null) {
                throw new RuntimeException(
                    "No se encontró db.properties en WEB-INF/classes. " +
                    "Verifica que el archivo esté ahí.");
            }
            propiedades.load(input);
            input.close();

            // Registrar el driver de PostgreSQL
            Class.forName(propiedades.getProperty("db.driver"));

        } catch (IOException | ClassNotFoundException e) {
            throw new RuntimeException("Error cargando configuración de BD: " + e.getMessage(), e);
        }
    }

    /**
     * Devuelve una nueva conexión activa a la base de datos.
     * Quien la use es responsable de cerrarla (usar try-with-resources).
     */
    public static Connection obtenerConexion() throws SQLException {
        String host = propiedades.getProperty("db.host");
        String port = propiedades.getProperty("db.port");
        String dbName = propiedades.getProperty("db.name");
        String user = propiedades.getProperty("db.user");
        String password = propiedades.getProperty("db.password");

        String url = String.format("jdbc:postgresql://%s:%s/%s?sslmode=require",
                host, port, dbName);

        return DriverManager.getConnection(url, user, password);
    }

    /**
     * Método simple para probar la conexión desde una página de prueba.
     */
    public static boolean probarConexion() {
        try (Connection con = obtenerConexion()) {
            return con != null && !con.isClosed();
        } catch (SQLException e) {
            System.err.println("Error probando conexión: " + e.getMessage());
            return false;
        }
    }
}
