<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
%>
<%@ page import="com.inmobiliaria.util.ConexionBD" %>
<%@ page import="com.inmobiliaria.util.PasswordUtil" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Prueba de conexión</title>
</head>
<body>
<%@ include file="WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header">
            <div class="eyebrow">Herramientas de desarrollo</div>
            <h1 class="page-title">Prueba del sistema</h1>
            <p class="page-subtitle">Comprobaciones de conexión JDBC, consulta PostgreSQL y BCrypt.</p>
        </div>

        <div class="row g-4">
            <div class="col-lg-6">
                <section class="surface-card h-100">
                    <div class="d-flex align-items-center gap-2 mb-3"><span class="material-symbols-outlined text-primary">database</span><h2 class="h5 fw-bold mb-0">Conexión JDBC</h2></div>
                    <% boolean conexionOk = ConexionBD.probarConexion(); %>
                    <% if (conexionOk) { %>
                        <div class="alert alert-success mb-0"><strong>Conexión exitosa.</strong> La aplicación puede comunicarse con PostgreSQL.</div>
                    <% } else { %>
                        <div class="alert alert-danger mb-0"><strong>No se pudo conectar.</strong> Revisa la configuración de la base de datos.</div>
                    <% } %>
                </section>
            </div>

            <div class="col-lg-6">
                <section class="surface-card h-100">
                    <div class="d-flex align-items-center gap-2 mb-3"><span class="material-symbols-outlined text-primary">lock</span><h2 class="h5 fw-bold mb-0">Prueba de BCrypt</h2></div>
                    <%
                        String hashPrueba = PasswordUtil.hashear("123456");
                        boolean verifica = PasswordUtil.verificar("123456", hashPrueba);
                    %>
                    <p class="small text-muted">La contraseña de prueba se procesa mediante el mismo utilitario utilizado por el sistema.</p>
                    <div class="p-3 rounded-3" style="background:var(--surface-low)"><strong>Verificación:</strong> <%= verifica %></div>
                </section>
            </div>

            <div class="col-12">
                <section class="table-card">
                    <div class="p-3 border-bottom"><h2 class="h5 fw-bold mb-1">Consulta de propiedades</h2><p class="small text-muted mb-0">Listado obtenido directamente mediante JDBC.</p></div>
                    <div class="table-responsive">
                        <% if (conexionOk) { %>
                            <table class="table align-middle">
                                <thead><tr><th>Título</th><th>Precio</th><th>Estado</th></tr></thead>
                                <tbody>
                                <%
                                    try (Connection con = ConexionBD.obtenerConexion();
                                         PreparedStatement ps = con.prepareStatement("SELECT titulo, precio, estado FROM propiedad ORDER BY id_propiedad");
                                         ResultSet rs = ps.executeQuery()) {
                                        while (rs.next()) {
                                %>
                                    <tr><td><%= rs.getString("titulo") %></td><td>$<%= String.format("%,.0f", rs.getBigDecimal("precio")) %></td><td><span class="property-status status-available"><%= rs.getString("estado") %></span></td></tr>
                                <%      }
                                    } catch (Exception e) { %>
                                    <tr><td colspan="3" class="text-danger">Error en la consulta: <%= e.getMessage() %></td></tr>
                                <% } %>
                                </tbody>
                            </table>
                        <% } else { %>
                            <div class="p-4 text-muted">La consulta no se ejecutó porque la conexión no está disponible.</div>
                        <% } %>
                    </div>
                </section>
            </div>
        </div>
    </div>
</main>
<%@ include file="WEB-INF/jspf/pie.jspf" %>
</body>
</html>
