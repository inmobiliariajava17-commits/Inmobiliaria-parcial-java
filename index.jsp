<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.text.NumberFormat, java.util.Locale" %>
<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
    NumberFormat formatoPrecio = NumberFormat.getNumberInstance(new Locale("es", "CO"));
    formatoPrecio.setMaximumFractionDigits(0);
    formatoPrecio.setMinimumFractionDigits(0);
%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Inmobiliaria - Encuentra tu propiedad</title>
</head>
<body>
<%@ include file="WEB-INF/jspf/cabecera.jspf" %>

<section class="hero">
    <div class="container app-container text-center hero-content">
        <div class="eyebrow text-white-50">Encuentra tu pr&#243;ximo espacio</div>
        <h1>Encuentra una propiedad que se adapte a ti</h1>
        <p>Consulta casas, apartamentos, locales y oficinas publicadas en nuestro cat&#225;logo.</p>
    </div>
</section>

<section class="search-panel">
    <div class="container app-container">
        <div class="search-panel-inner">
            <div class="d-flex align-items-center gap-2 mb-3">
                <span class="material-symbols-outlined text-primary">search</span>
                <div>
                    <strong class="d-block">B&#250;squeda r&#225;pida</strong>
                    <small class="text-muted">Filtra el cat&#225;logo por ciudad y tipo de propiedad.</small>
                </div>
            </div>
            <form method="get" action="<%= request.getContextPath() %>/acciones/buscar.jsp" class="row g-3 align-items-end">
                <div class="col-md-5">
                    <label class="form-label">Ciudad</label>
                    <select name="ciudad" class="form-select">
                        <option value="">Todas las ciudades</option>
                        <%
                            try (Connection con = obtenerConexion();
                                 PreparedStatement ps = con.prepareStatement("SELECT nombre_ciudad FROM ciudad ORDER BY nombre_ciudad");
                                 ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                        %>
                            <option value="<%= rs.getString("nombre_ciudad") %>"><%= rs.getString("nombre_ciudad") %></option>
                        <%
                                }
                            } catch (Exception e) {
                        %>
                            <option value="">No se pudieron cargar las ciudades</option>
                        <% } %>
                    </select>
                </div>
                <div class="col-md-5">
                    <label class="form-label">Tipo de propiedad</label>
                    <select name="tipo" class="form-select">
                        <option value="">Todos los tipos</option>
                        <%
                            try (Connection con = obtenerConexion();
                                 PreparedStatement ps = con.prepareStatement("SELECT nombre_tipo FROM tipo_propiedad ORDER BY nombre_tipo");
                                 ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                        %>
                            <option value="<%= rs.getString("nombre_tipo") %>"><%= rs.getString("nombre_tipo") %></option>
                        <%
                                }
                            } catch (Exception e) {
                        %>
                            <option value="">No se pudieron cargar los tipos</option>
                        <% } %>
                    </select>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary w-100 py-2">Buscar</button>
                </div>
            </form>
        </div>
    </div>
</section>

<section class="section">
    <div class="container app-container">
        <div class="mb-4">
            <div class="eyebrow">Cat&#225;logo</div>
            <h2 class="section-title">Propiedades destacadas</h2>
            <p class="section-text">Algunas de las propiedades disponibles actualmente.</p>
        </div>
        <div class="row g-4">
            <%
                try (Connection con = obtenerConexion();
                     PreparedStatement ps = con.prepareStatement(
                         "SELECT p.id_propiedad, p.titulo, p.descripcion, p.precio, c.nombre_ciudad, tp.nombre_tipo, " +
                         "COALESCE((SELECT ip.url_imagen FROM imagen_propiedad ip " +
                         "WHERE ip.id_propiedad = p.id_propiedad AND ip.es_principal = TRUE " +
                         "ORDER BY ip.id_imagen LIMIT 1), " +
                         "(SELECT ip.url_imagen FROM imagen_propiedad ip " +
                         "WHERE ip.id_propiedad = p.id_propiedad ORDER BY ip.id_imagen LIMIT 1), '') AS imagen " +
                         "FROM propiedad p " +
                         "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
                         "INNER JOIN tipo_propiedad tp ON p.id_tipo = tp.id_tipo " +
                         "WHERE p.estado = 'DISPONIBLE' " +
                         "ORDER BY p.fecha_publicacion DESC LIMIT 6");
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
            %>
                <div class="col-md-6 col-xl-4">
                    <article class="property-card">
                        <div class="property-image">
                            <% if (rs.getString("imagen") != null && !rs.getString("imagen").isBlank()) { %>
                                <img src="<%= rs.getString("imagen") %>" alt="Imagen de <%= rs.getString("titulo") %>" class="w-100 h-100 object-fit-cover">
                            <% } else { %>
                                <span class="material-symbols-outlined">apartment</span>
                            <% } %>
                        </div>
                        <div class="property-body">
                            <div class="property-card-top">
                                <span class="property-type"><%= rs.getString("nombre_tipo") %></span>
                                <span class="property-status status-available">Disponible</span>
                            </div>
                            <h3 class="property-title"><%= rs.getString("titulo") %></h3>
                            <p class="property-description"><%= rs.getString("descripcion") == null ? "Sin descripción." : rs.getString("descripcion") %></p>
                            <div class="property-price">$<%= formatoPrecio.format(rs.getBigDecimal("precio")) %></div>
                            <div class="property-meta">
                                <span><span class="material-symbols-outlined" style="font-size:15px">location_on</span> <%= rs.getString("nombre_ciudad") %></span>
                                <a href="<%= request.getContextPath() %>/acciones/detalle-propiedad.jsp?id=<%= rs.getInt("id_propiedad") %>" class="text-decoration-none fw-semibold">Ver detalle</a>
                            </div>
                        </div>
                    </article>
                </div>
            <%
                    }
                } catch (Exception e) {
            %>
                <div class="col-12"><div class="alert alert-danger">No se pudieron cargar las propiedades destacadas.</div></div>
            <% } %>
        </div>
    </div>
</section>

<%@ include file="WEB-INF/jspf/pie.jspf" %>
</body>
</html>
