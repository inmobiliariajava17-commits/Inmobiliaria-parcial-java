<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%@ page import="java.text.NumberFormat, java.util.Locale" %>
<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
    NumberFormat formatoPrecio = NumberFormat.getNumberInstance(new Locale("es", "CO"));
    formatoPrecio.setMaximumFractionDigits(0);
    formatoPrecio.setMinimumFractionDigits(0);
    List<Map<String, Object>> favoritos = (List<Map<String, Object>>) request.getAttribute("favoritos");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mis favoritos</title>
</head>
<body>
<%@ include file="../../WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header d-flex flex-column flex-md-row justify-content-between gap-3">
            <div>
                <div class="eyebrow">Espacio del cliente</div>
                <h1 class="page-title">Mis favoritos</h1>
                <p class="page-subtitle">Aquí tienes las propiedades que guardaste para revisarlas después.</p>
            </div>
            <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-outline-primary align-self-start">Buscar propiedades</a>
        </div>

        <% if (request.getParameter("mensaje") != null) { %>
            <div class="alert alert-success">Propiedad retirada de favoritos.</div>
        <% } %>
        <% if (request.getParameter("error") != null || request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">No se pudo completar la operación.</div>
        <% } %>

        <% if (favoritos == null || favoritos.isEmpty()) { %>
            <div class="empty-panel surface-card">
                <span class="material-symbols-outlined">favorite_border</span>
                <h2 class="h5 fw-bold">Todavía no tienes favoritos</h2>
                <p class="text-muted mb-3">Guarda una propiedad desde su detalle para encontrarla rápidamente aquí.</p>
                <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-primary">Explorar propiedades</a>
            </div>
        <% } else { %>
            <div class="row g-4">
                <% for (Map<String, Object> propiedad : favoritos) {
                    String estado = String.valueOf(propiedad.get("estado"));
                %>
                    <div class="col-md-6 col-xl-4">
                        <article class="property-card surface-card h-100">
                            <div class="property-image">
                                <% if (propiedad.get("imagen") != null && !propiedad.get("imagen").toString().isBlank()) { %>
                                    <img src="<%= propiedad.get("imagen") %>" alt="Imagen de <%= propiedad.get("titulo") %>" class="w-100 h-100 object-fit-cover">
                                <% } else { %>
                                    <span class="material-symbols-outlined">home_work</span>
                                <% } %>
                            </div>
                            <div class="property-body">
                                <div class="property-card-top">
                                    <span class="property-type"><%= propiedad.get("tipo") %></span>
                                    <span class="property-status <%= "DISPONIBLE".equals(estado) ? "status-available" : "status-other" %>"><%= estado %></span>
                                </div>
                                <h2 class="property-title"><%= propiedad.get("titulo") %></h2>
                                <p class="property-description">Propiedad ubicada en <%= propiedad.get("ciudad") %>.</p>
                                <div class="property-price">$<%= formatoPrecio.format(propiedad.get("precio")) %></div>
                                <div class="d-flex gap-2 mt-3">
                                    <a href="<%= request.getContextPath() %>/propiedad?id=<%= propiedad.get("id") %>" class="btn btn-outline-primary btn-sm flex-grow-1">Ver detalle</a>
                                    <form method="post" action="<%= request.getContextPath() %>/favoritos">
                                        <input type="hidden" name="accion" value="quitar">
                                        <input type="hidden" name="idPropiedad" value="<%= propiedad.get("id") %>">
                                        <input type="hidden" name="volver" value="lista">
                                        <button type="submit" class="btn btn-outline-danger btn-sm">Quitar</button>
                                    </form>
                                </div>
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
