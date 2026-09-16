<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.inmobiliaria.util.ConexionBD" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>InmoApp - Encuentra tu propiedad</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>

<%@ include file="WEB-INF/jspf/cabecera.jspf" %>

<!-- Hero -->
<div class="bg-dark text-light py-5">
    <div class="container text-center">
        <h1>Encuentra tu próxima propiedad</h1>
        <p class="lead">Casas, apartamentos, locales y más en Santander</p>
    </div>
</div>

<!-- Buscador rápido -->
<div class="container mt-4">
    <form method="get" action="<%= request.getContextPath() %>/buscar" class="row g-2 justify-content-center">
        <div class="col-md-4">
            <select name="ciudad" class="form-select">
                <option value="">Todas las ciudades</option>
                <%
                    try (Connection con = ConexionBD.obtenerConexion();
                         PreparedStatement ps = con.prepareStatement(
                             "SELECT nombre_ciudad FROM ciudad ORDER BY nombre_ciudad");
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                %>
                            <option value="<%= rs.getString("nombre_ciudad") %>">
                                <%= rs.getString("nombre_ciudad") %>
                            </option>
                <%
                        }
                    } catch (Exception e) {
                %>
                        <option value="">(error cargando ciudades)</option>
                <%
                    }
                %>
            </select>
        </div>
        <div class="col-md-4">
            <select name="tipo" class="form-select">
                <option value="">Todos los tipos</option>
                <%
                    try (Connection con = ConexionBD.obtenerConexion();
                         PreparedStatement ps = con.prepareStatement(
                             "SELECT nombre_tipo FROM tipo_propiedad ORDER BY nombre_tipo");
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                %>
                            <option value="<%= rs.getString("nombre_tipo") %>">
                                <%= rs.getString("nombre_tipo") %>
                            </option>
                <%
                        }
                    } catch (Exception e) {
                %>
                        <option value="">(error cargando tipos)</option>
                <%
                    }
                %>
            </select>
        </div>
        <div class="col-md-2">
            <button type="submit" class="btn btn-primary w-100">Buscar</button>
        </div>
    </form>
</div>

<!-- Propiedades destacadas -->
<div class="container mt-5">
    <h2 class="mb-3">Propiedades destacadas</h2>
    <div class="row">
        <%
            try (Connection con = ConexionBD.obtenerConexion();
                 PreparedStatement ps = con.prepareStatement(
                     "SELECT p.titulo, p.precio, c.nombre_ciudad, tp.nombre_tipo " +
                     "FROM propiedad p " +
                     "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
                     "INNER JOIN tipo_propiedad tp ON p.id_tipo = tp.id_tipo " +
                     "WHERE p.estado = 'DISPONIBLE' " +
                     "ORDER BY p.fecha_publicacion DESC LIMIT 6");
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
        %>
                <div class="col-md-4 mb-4">
                    <div class="card h-100">
                        <div class="card-body">
                            <h5 class="card-title"><%= rs.getString("titulo") %></h5>
                            <p class="card-text">
                                <%= rs.getString("nombre_tipo") %> en <%= rs.getString("nombre_ciudad") %>
                            </p>
                            <p class="fw-bold">$<%= rs.getBigDecimal("precio") %></p>
                        </div>
                    </div>
                </div>
        <%
                }
            } catch (Exception e) {
        %>
                <p class="text-danger">No se pudieron cargar las propiedades destacadas.</p>
        <%
            }
        %>
    </div>
</div>

<%@ include file="WEB-INF/jspf/pie.jspf" %>
</body>
</html>
