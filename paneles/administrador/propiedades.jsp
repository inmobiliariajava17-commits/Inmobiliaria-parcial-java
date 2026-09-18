<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.NumberFormat, java.util.Locale" %>
<%
    if (!tieneRol(session, "ADMINISTRADOR")) {
        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
        return;
    }
%>

<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
    NumberFormat formatoPrecio = NumberFormat.getNumberInstance(new Locale("es", "CO"));
    formatoPrecio.setMaximumFractionDigits(0);
    formatoPrecio.setMinimumFractionDigits(0);
    List<Map<String, Object>> propiedades = (List<Map<String, Object>>) request.getAttribute("propiedades");
    List<String[]> ciudades = (List<String[]>) request.getAttribute("ciudades");
    List<String[]> tipos = (List<String[]>) request.getAttribute("tipos");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Propiedades | Administraci&#243;n</title>
</head>
<body>
<%@ include file="../../WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header d-flex flex-column flex-md-row justify-content-between align-items-md-end gap-3">
            <div>
                <div class="eyebrow">Administraci&#243;n</div>
                <h1 class="page-title">Propiedades</h1>
                <p class="page-subtitle">Consulta las propiedades publicadas por las inmobiliarias y controla su estado.</p>
            </div>
            <a href="<%= request.getContextPath() %>/paneles/administrador.jsp" class="btn btn-outline-primary btn-sm rounded-pill">Volver al panel</a>
        </div>

        <% if ("estado".equals(request.getParameter("mensaje"))) { %>
            <div class="alert alert-success">Estado de la propiedad actualizado correctamente.</div>
        <% } else if ("estado".equals(request.getParameter("error"))) { %>
            <div class="alert alert-warning">El estado seleccionado no es v&#225;lido.</div>
        <% } else if ("noEncontrada".equals(request.getParameter("error"))) { %>
            <div class="alert alert-warning">No se encontr&#243; la propiedad.</div>
        <% } else if ("bd".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">No se pudo guardar el cambio. Intenta nuevamente.</div>
        <% } %>

        <div class="surface-card mb-4">
            <form method="get" action="<%= request.getContextPath() %>/acciones/administrador-propiedades.jsp">
                <div class="row g-3 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label">Ciudad</label>
                        <select name="ciudad" class="form-select">
                            <option value="">Todas</option>
                            <% if (ciudades != null) { for (String[] ciudad : ciudades) { %>
                                <option value="<%= ciudad[0] %>" <%= ciudad[0].equals(request.getParameter("ciudad")) ? "selected" : "" %>><%= ciudad[1] %></option>
                            <% }} %>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Tipo de propiedad</label>
                        <select name="tipo" class="form-select">
                            <option value="">Todos</option>
                            <% if (tipos != null) { for (String[] tipo : tipos) { %>
                                <option value="<%= tipo[0] %>" <%= tipo[0].equals(request.getParameter("tipo")) ? "selected" : "" %>><%= tipo[1] %></option>
                            <% }} %>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Estado</label>
                        <select name="estado" class="form-select">
                            <option value="">Todos</option>
                            <option value="DISPONIBLE" <%= "DISPONIBLE".equals(request.getParameter("estado")) ? "selected" : "" %>>Disponible</option>
                            <option value="ARRENDADA" <%= "ARRENDADA".equals(request.getParameter("estado")) ? "selected" : "" %>>Arrendada</option>
                            <option value="VENDIDA" <%= "VENDIDA".equals(request.getParameter("estado")) ? "selected" : "" %>>Vendida</option>
                            <option value="INACTIVA" <%= "INACTIVA".equals(request.getParameter("estado")) ? "selected" : "" %>>Inactiva</option>
                        </select>
                    </div>
                    <div class="col-md-1 d-grid">
                        <button class="btn btn-primary" type="submit">Filtrar</button>
                    </div>
                </div>
            </form>
        </div>

        <% if (propiedades == null || propiedades.isEmpty()) { %>
            <div class="empty-panel">
                <span class="material-symbols-outlined">home_work</span>
                <h2>No hay propiedades para mostrar</h2>
                <p class="text-muted mb-0">Prueba cambiando los filtros o registra una propiedad desde una cuenta inmobiliaria.</p>
            </div>
        <% } else { %>
            <div class="table-card">
                <div class="table-responsive">
                    <table class="table align-middle">
                        <thead>
                        <tr>
                            <th>ID</th>
                            <th>Propiedad</th>
                            <th>Inmobiliaria</th>
                            <th>Ubicaci&#243;n</th>
                            <th>Precio</th>
                            <th>Estado</th>
                            <th>Actualizar</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (Map<String, Object> p : propiedades) { %>
                            <tr>
                                <td><strong>#<%= p.get("id") %></strong><br><small class="text-muted"><%= p.get("matricula") %></small></td>
                                <td><strong><%= p.get("titulo") %></strong><br><small class="text-muted"><%= p.get("tipo") %></small></td>
                                <td><%= p.get("agencia") %></td>
                                <td><%= p.get("ciudad") %></td>
                                <td>$ <%= formatoPrecio.format(p.get("precio")) %></td>
                                <td><span class="badge text-bg-light border"><%= p.get("estado") %></span></td>
                                <td>
                                    <form method="post" action="<%= request.getContextPath() %>/acciones/administrador-propiedades.jsp" class="d-flex gap-1">
                                        <input type="hidden" name="accion" value="estado">
                                        <input type="hidden" name="idPropiedad" value="<%= p.get("id") %>">
                                        <select name="estado" class="form-select form-select-sm" style="min-width:120px">
                                            <option value="DISPONIBLE" <%= "DISPONIBLE".equals(p.get("estado")) ? "selected" : "" %>>Disponible</option>
                                            <option value="ARRENDADA" <%= "ARRENDADA".equals(p.get("estado")) ? "selected" : "" %>>Arrendada</option>
                                            <option value="VENDIDA" <%= "VENDIDA".equals(p.get("estado")) ? "selected" : "" %>>Vendida</option>
                                            <option value="INACTIVA" <%= "INACTIVA".equals(p.get("estado")) ? "selected" : "" %>>Inactiva</option>
                                        </select>
                                        <button class="btn btn-outline-primary btn-sm" type="submit">Guardar</button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        <% } %>

        <div class="info-panel mt-4">
            <h2>Control administrativo</h2>
            <p class="mb-0">El administrador puede consultar propiedades de todas las inmobiliarias y actualizar su estado. Cada cambio queda registrado en la tabla de auditor&#237;a.</p>
        </div>
    </div>
</main>
<%@ include file="../../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
