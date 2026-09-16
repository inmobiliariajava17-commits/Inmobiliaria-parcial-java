<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Resultados de búsqueda</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>

<%@ include file="WEB-INF/jspf/cabecera.jspf" %>

<div class="container mt-4">
    <h2>Resultados de búsqueda</h2>
    <p class="text-muted">
        <% if (request.getAttribute("ciudadBuscada") != null && !((String) request.getAttribute("ciudadBuscada")).isBlank()) { %>
            Ciudad: <%= request.getAttribute("ciudadBuscada") %>
        <% } %>
        <% if (request.getAttribute("tipoBuscado") != null && !((String) request.getAttribute("tipoBuscado")).isBlank()) { %>
            - Tipo: <%= request.getAttribute("tipoBuscado") %>
        <% } %>
    </p>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
    <% } %>

    <%
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> resultados = (List<Map<String, Object>>) request.getAttribute("resultados");
    %>

    <% if (resultados == null || resultados.isEmpty()) { %>
        <p>No se encontraron propiedades con esos filtros.</p>
    <% } else { %>
        <div class="row">
            <% for (Map<String, Object> propiedad : resultados) { %>
                <div class="col-md-4 mb-4">
                    <div class="card h-100">
                        <div class="card-body">
                            <h5 class="card-title"><%= propiedad.get("titulo") %></h5>
                            <p class="card-text">
                                <%= propiedad.get("tipo") %> en <%= propiedad.get("ciudad") %>
                            </p>
                            <p class="fw-bold">$<%= propiedad.get("precio") %></p>
                        </div>
                    </div>
                </div>
            <% } %>
        </div>
    <% } %>

    <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-secondary mt-3">Volver</a>
</div>

<%@ include file="WEB-INF/jspf/pie.jspf" %>
</body>
</html>
