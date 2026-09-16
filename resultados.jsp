<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Resultados - Inmobiliaria</title>
</head>
<body>
<%@ include file="WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header d-flex flex-column flex-md-row justify-content-between gap-3">
            <div>
                <div class="eyebrow">Catálogo público</div>
                <h1 class="page-title">Resultados de búsqueda</h1>
                <p class="page-subtitle">
                    <% if (request.getAttribute("ciudadBuscada") != null && !((String) request.getAttribute("ciudadBuscada")).isBlank()) { %>
                        Ciudad: <strong><%= request.getAttribute("ciudadBuscada") %></strong>
                    <% } %>
                    <% if (request.getAttribute("tipoBuscado") != null && !((String) request.getAttribute("tipoBuscado")).isBlank()) { %>
                        &nbsp;•&nbsp; Tipo: <strong><%= request.getAttribute("tipoBuscado") %></strong>
                    <% } %>
                </p>
            </div>
            <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-outline-primary align-self-start">Nueva búsqueda</a>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>

        <%
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> resultados = (List<Map<String, Object>>) request.getAttribute("resultados");
        %>
        <% if (resultados == null || resultados.isEmpty()) { %>
            <div class="empty-panel">
                <span class="material-symbols-outlined">search_off</span>
                <h2 class="h5 fw-bold">No encontramos propiedades</h2>
                <p class="text-muted mb-0">Prueba con otros filtros para ampliar la búsqueda.</p>
            </div>
        <% } else { %>
            <div class="row g-4">
                <% for (Map<String, Object> propiedad : resultados) { %>
                    <div class="col-md-6 col-xl-4">
                        <article class="property-card">
                            <div class="property-image"><span class="material-symbols-outlined">home_work</span></div>
                            <div class="property-body">
                                <div class="property-card-top">
                                    <span class="property-type"><%= propiedad.get("tipo") %></span>
                                    <span class="property-status status-available"><%= propiedad.get("estado") %></span>
                                </div>
                                <h2 class="property-title"><%= propiedad.get("titulo") %></h2>
                                <p class="property-description mb-2">Propiedad ubicada en <%= propiedad.get("ciudad") %>.</p>
                                <div class="property-price">$<%= propiedad.get("precio") %></div>
                                <div class="property-meta"><span>Disponible en catálogo</span><strong><%= propiedad.get("ciudad") %></strong></div>
                            </div>
                        </article>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>
</main>
<%@ include file="WEB-INF/jspf/pie.jspf" %>
</body>
</html>
