<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.inmobiliaria.util.ConexionBD" %>
<%@ page import="com.inmobiliaria.util.PasswordUtil" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Prueba de conexión - Inmobiliaria</title>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <h1>Página de prueba</h1>

    <h2>1. Prueba de conexión JDBC</h2>
    <%
        boolean conexionOk = ConexionBD.probarConexion();
    %>
    <% if (conexionOk) { %>
        <p style="color: green;"><strong>✔ Conexión exitosa a la base de datos Supabase.</strong></p>
    <% } else { %>
        <p style="color: red;"><strong>✘ No se pudo conectar. Revisa WEB-INF/classes/db.properties</strong></p>
    <% } %>

    <h2>2. Prueba de consulta (listar propiedades)</h2>
    <%
        if (conexionOk) {
            try (Connection con = ConexionBD.obtenerConexion();
                 PreparedStatement ps = con.prepareStatement(
                     "SELECT titulo, precio, estado FROM propiedad ORDER BY id_propiedad");
                 ResultSet rs = ps.executeQuery()) {
    %>
                <table border="1" cellpadding="6">
                    <tr><th>Título</th><th>Precio</th><th>Estado</th></tr>
                    <%
                        while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getString("titulo") %></td>
                        <td><%= rs.getBigDecimal("precio") %></td>
                        <td><%= rs.getString("estado") %></td>
                    </tr>
                    <%
                        }
                    %>
                </table>
    <%
            } catch (Exception e) {
    %>
                <p style="color: red;">Error en la consulta: <%= e.getMessage() %></p>
    <%
            }
        }
    %>

    <h2>3. Prueba de BCrypt (hash y verificación)</h2>
    <%
        String hashPrueba = PasswordUtil.hashear("123456");
        boolean verifica = PasswordUtil.verificar("123456", hashPrueba);
    %>
    <p>Hash generado: <code><%= hashPrueba %></code></p>
    <p>¿Verifica "123456"?: <strong><%= verifica %></strong></p>

</body>
</html>
