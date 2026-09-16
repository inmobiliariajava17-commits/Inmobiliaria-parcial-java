<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mis Propiedades</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background:#f6f8fb; }
        .page-title { color:#1e3a8a; font-weight:700; }
        .property-card { border:0; border-radius:16px; box-shadow:0 3px 15px rgba(0,0,0,.06); }
        .status { font-size:.75rem; border-radius:20px; padding:.35rem .7rem; font-weight:600; }
        .status-disponible { background:#dcfce7; color:#166534; }
        .status-arrendada { background:#fef3c7; color:#92400e; }
        .status-vendida { background:#e0e7ff; color:#3730a3; }
        .status-inactiva { background:#e5e7eb; color:#374151; }
    </style>
</head>
<body>

<%@ include file="../../WEB-INF/jspf/cabecera.jspf" %>

<main class="container py-4">
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
        <div>
            <div class="text-secondary small fw-semibold text-uppercase">Gestión inmobiliaria</div>
            <h1 class="page-title mb-1">Mis Propiedades</h1>
            <p class="text-secondary mb-0">Administra los inmuebles registrados por tu inmobiliaria.</p>
        </div>
        <a href="<%= request.getContextPath() %>/propiedades?accion=nueva" class="btn btn-primary">
            + Registrar propiedad
        </a>
    </div>

    <% if (request.getParameter("mensaje") != null) { %>
        <div class="alert alert-success">
            <% if ("creada".equals(request.getParameter("mensaje"))) { %>
                Propiedad registrada correctamente.
            <% } else if ("editada".equals(request.getParameter("mensaje"))) { %>
                Propiedad actualizada correctamente.
            <% } else { %>
                Propiedad dada de baja correctamente.
            <% } %>
        </div>
    <% } %>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
    <% } %>

    <form method="get" action="<%= request.getContextPath() %>/propiedades"
          class="card property-card p-3 mb-4">
        <div class="row g-3 align-items-end">
            <div class="col-md-3">
                <label class="form-label fw-semibold">Ciudad</label>
                <select name="ciudad" class="form-select">
                    <option value="">Todas</option>
                    <%
                        List<String[]> ciudades = (List<String[]>) request.getAttribute("ciudades");
                        if (ciudades != null) {
                            for (String[] ciudad : ciudades) {
                    %>
                    <option value="<%= ciudad[0] %>"
                        <%= ciudad[0].equals(request.getParameter("ciudad")) ? "selected" : "" %>>
                        <%= ciudad[1] %>
                    </option>
                    <% }} %>
                </select>
            </div>

            <div class="col-md-3">
                <label class="form-label fw-semibold">Tipo</label>
                <select name="tipo" class="form-select">
                    <option value="">Todos</option>
                    <%
                        List<String[]> tipos = (List<String[]>) request.getAttribute("tipos");
                        if (tipos != null) {
                            for (String[] tipo : tipos) {
                    %>
                    <option value="<%= tipo[0] %>"
                        <%= tipo[0].equals(request.getParameter("tipo")) ? "selected" : "" %>>
                        <%= tipo[1] %>
                    </option>
                    <% }} %>
                </select>
            </div>

            <div class="col-md-3">
                <label class="form-label fw-semibold">Estado</label>
                <select name="estado" class="form-select">
                    <option value="">Todos</option>
                    <option value="DISPONIBLE" <%= "DISPONIBLE".equals(request.getParameter("estado")) ? "selected" : "" %>>Disponible</option>
                    <option value="ARRENDADA" <%= "ARRENDADA".equals(request.getParameter("estado")) ? "selected" : "" %>>Arrendada</option>
                    <option value="VENDIDA" <%= "VENDIDA".equals(request.getParameter("estado")) ? "selected" : "" %>>Vendida</option>
                    <option value="INACTIVA" <%= "INACTIVA".equals(request.getParameter("estado")) ? "selected" : "" %>>Inactiva</option>
                </select>
            </div>

            <div class="col-md-2">
                <label class="form-label fw-semibold">Precio máximo</label>
                <input type="number" name="precioMax" min="0"
                       value="<%= request.getParameter("precioMax") == null ? "" : request.getParameter("precioMax") %>"
                       class="form-control" placeholder="Ej. 500000000">
            </div>

            <div class="col-md-1">
                <button class="btn btn-outline-primary w-100">Buscar</button>
            </div>
        </div>
    </form>

    <%
        List<Map<String, Object>> propiedades =
                (List<Map<String, Object>>) request.getAttribute("propiedades");
    %>

    <% if (propiedades == null || propiedades.isEmpty()) { %>
        <div class="card property-card text-center p-5">
            <h4>No se encontraron propiedades</h4>
            <p class="text-secondary mb-0">
                No hay inmuebles que coincidan con los filtros seleccionados.
            </p>
        </div>
    <% } else { %>
        <div class="row g-4">
            <% for (Map<String, Object> p : propiedades) {
                String estado = String.valueOf(p.get("estado")).toLowerCase();
            %>
            <div class="col-md-6 col-xl-4">
                <div class="card property-card h-100">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-start gap-2 mb-3">
                            <span class="text-secondary small"><%= p.get("ciudad") %> · <%= p.get("tipo") %></span>
                            <span class="status status-<%= estado %>"><%= p.get("estado") %></span>
                        </div>

                        <div class="text-secondary small mb-2">
                            Matrícula: <%= p.get("matricula") %>
                        </div>

                        <h4 class="h5 fw-bold"><%= p.get("titulo") %></h4>

                        <p class="text-secondary small" style="min-height:45px;">
                            <%= p.get("descripcion") == null ? "" : p.get("descripcion") %>
                        </p>

                        <div class="fs-5 fw-bold text-primary mb-3">
                            $ <%= p.get("precio") %>
                        </div>

                        <div class="d-flex gap-2">
                            <a class="btn btn-outline-primary btn-sm flex-grow-1"
                               href="<%= request.getContextPath() %>/propiedades?accion=editar&id=<%= p.get("id") %>">
                                Editar
                            </a>

                            <% if (!"INACTIVA".equals(p.get("estado"))) { %>
                            <form method="post" action="<%= request.getContextPath() %>/propiedades"
                                  onsubmit="return confirm('¿Dar de baja esta propiedad?');">
                                <input type="hidden" name="accion" value="eliminar">
                                <input type="hidden" name="idPropiedad" value="<%= p.get("id") %>">
                                <button class="btn btn-outline-danger btn-sm">Dar de baja</button>
                            </form>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    <% } %>
</main>

<%@ include file="../../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
