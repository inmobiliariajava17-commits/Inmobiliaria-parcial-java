<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    if (!tieneRol(session, "ADMINISTRADOR")) {
        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
        return;
    }
%>

<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
    List<Map<String, Object>> registros = (List<Map<String, Object>>) request.getAttribute("registros");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Auditor&#237;a</title>
</head>
<body>
<%@ include file="../../WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header d-flex flex-column flex-md-row justify-content-between align-items-md-end gap-3">
            <div>
                <div class="eyebrow">Administraci&#243;n</div>
                <h1 class="page-title">Auditor&#237;a</h1>
                <p class="page-subtitle">Consulta las &#250;ltimas acciones registradas en el sistema.</p>
            </div>
            <a href="<%= request.getContextPath() %>/paneles/administrador.jsp" class="btn btn-outline-primary btn-sm rounded-pill">Volver al panel</a>
        </div>

        <div class="info-panel mb-4">
            <h2 class="h6 fw-bold">Registro de actividad</h2>
            <p class="mb-0">Se muestran las &#250;ltimas 100 acciones. El usuario se obtiene mediante la relaci&#243;n con la tabla de auditor&#237;a.</p>
        </div>

        <div class="table-card">
            <div class="table-responsive">
                <table class="table align-middle">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Usuario</th>
                        <th>Acci&#243;n</th>
                        <th>Fecha</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% if (registros == null || registros.isEmpty()) { %>
                        <tr><td colspan="4" class="text-center py-4">No hay registros de auditor&#237;a.</td></tr>
                    <% } else { %>
                        <% for (Map<String, Object> registro : registros) { %>
                            <tr>
                                <td><strong>#<%= registro.get("id") %></strong></td>
                                <td>
                                    <% if (registro.get("correo") != null) { %>
                                        <%= registro.get("correo") %>
                                    <% } else { %>
                                        Usuario eliminado
                                    <% } %>
                                </td>
                                <td><%= registro.get("accion") %></td>
                                <td><%= registro.get("fecha") %></td>
                            </tr>
                        <% } %>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>
<%@ include file="../../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
