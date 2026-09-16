<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.math.BigDecimal" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mis Propiedades</title>
</head>
<body>
<%@ include file="../../WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header d-flex flex-column flex-md-row justify-content-between align-items-md-end gap-3">
            <div>
                <div class="eyebrow">Gestión de cartera • Portafolio activo</div>
                <h1 class="page-title">Mis propiedades</h1>
                <p class="page-subtitle">Administra y consulta los inmuebles asociados a tu inmobiliaria.</p>
            </div>
            <a href="<%= request.getContextPath() %>/paneles/inmobiliaria.jsp" class="btn btn-outline-primary">Volver al panel</a>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>

        <%
            List<Map<String, Object>> propiedades = (List<Map<String, Object>>) request.getAttribute("propiedades");
        %>

        <% if (propiedades == null || propiedades.isEmpty()) { %>
            <div class="empty-panel">
                <span class="material-symbols-outlined">home_work</span>
                <h2 class="h5 fw-bold">No hay propiedades registradas</h2>
                <p class="text-muted mb-0">Cuando existan propiedades asociadas a la inmobiliaria aparecerán aquí.</p>
            </div>
        <% } else { %>
            <div class="surface-card mb-4">
                <div class="row g-3 align-items-end">
                    <div class="col-lg-6">
                        <label class="form-label">Búsqueda visual</label>
                        <input type="text" class="form-control" placeholder="Título, ciudad o matrícula..." id="propertySearch">
                    </div>
                    <div class="col-sm-6 col-lg-3">
                        <label class="form-label">Estado</label>
                        <select class="form-select" id="propertyStatus"><option value="">Todos</option><option value="DISPONIBLE">Disponible</option><option value="VENDIDA">Vendida</option><option value="ARRENDADA">Arrendada</option></select>
                    </div>
                    <div class="col-sm-6 col-lg-3"><div class="p-2 rounded-3" style="background:var(--surface-low);font-size:.75rem;color:var(--muted)"><strong class="d-block text-dark"><%= propiedades.size() %></strong> propiedades cargadas desde PostgreSQL</div></div>
                </div>
            </div>

            <div class="row g-4" id="propertyGrid">
                <% for (Map<String, Object> propiedad : propiedades) {
                    String estado = String.valueOf(propiedad.get("estado"));
                    String estadoClase = "DISPONIBLE".equals(estado) ? "status-available" : "VENDIDA".equals(estado) ? "status-sold" : "status-other";
                    BigDecimal precio = (BigDecimal) propiedad.get("precio");
                %>
                    <div class="col-md-6 col-xl-4 property-item" data-search="<%= (propiedad.get("titulo") + " " + propiedad.get("ciudad") + " " + propiedad.get("matricula")).toLowerCase() %>" data-status="<%= estado %>">
                        <article class="property-card">
                            <div class="property-image"><span class="material-symbols-outlined">apartment</span></div>
                            <div class="property-body">
                                <div class="property-card-top">
                                    <span class="property-type"><%= propiedad.get("tipo") %></span>
                                    <span class="property-status <%= estadoClase %>"><%= estado %></span>
                                </div>
                                <h2 class="property-title"><%= propiedad.get("titulo") %></h2>
                                <p class="property-description"><%= propiedad.get("descripcion") == null ? "Sin descripción." : propiedad.get("descripcion") %></p>
                                <div class="property-price">$<%= String.format("%,.0f", precio) %></div>
                                <div class="property-meta"><span><%= propiedad.get("ciudad") %></span><strong><%= propiedad.get("matricula") %></strong></div>
                            </div>
                        </article>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>
</main>

<%@ include file="../../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
