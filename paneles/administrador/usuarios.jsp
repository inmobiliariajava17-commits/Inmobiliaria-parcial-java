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
    List<Map<String, Object>> usuarios = (List<Map<String, Object>>) request.getAttribute("usuarios");
    List<String[]> roles = (List<String[]>) request.getAttribute("roles");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Usuarios y roles</title>
</head>
<body>
<%@ include file="../../WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header d-flex flex-column flex-md-row justify-content-between align-items-md-end gap-3">
            <div>
                <div class="eyebrow">Administraci&#243;n</div>
                <h1 class="page-title">Usuarios y roles</h1>
                <p class="page-subtitle">Consulta las cuentas, cambia su estado y asigna roles del sistema.</p>
            </div>
            <a href="<%= request.getContextPath() %>/paneles/administrador.jsp" class="btn btn-outline-primary btn-sm rounded-pill">Volver al panel</a>
        </div>

        <% if ("estado".equals(request.getParameter("mensaje"))) { %>
            <div class="alert alert-success">Estado del usuario actualizado correctamente.</div>
        <% } else if ("rol".equals(request.getParameter("mensaje"))) { %>
            <div class="alert alert-success">Rol asignado correctamente.</div>
        <% } else if ("propio".equals(request.getParameter("error"))) { %>
            <div class="alert alert-warning">No puedes cambiar el estado de tu propia cuenta.</div>
        <% } else if ("rol".equals(request.getParameter("error"))) { %>
            <div class="alert alert-warning">Ese usuario ya tiene ese rol o los datos no son v&#225;lidos.</div>
        <% } else if ("bd".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">No se pudo guardar el cambio. Intenta nuevamente.</div>
        <% } %>

        <div class="table-card">
            <div class="table-responsive">
                <table class="table align-middle">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Correo</th>
                        <th>Roles</th>
                        <th>Estado</th>
                        <th>Registro</th>
                        <th>Estado</th>
                        <th>Asignar rol</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% if (usuarios == null || usuarios.isEmpty()) { %>
                        <tr><td colspan="7" class="text-center py-4">No hay usuarios registrados.</td></tr>
                    <% } else { %>
                        <% for (Map<String, Object> usuario : usuarios) { %>
                            <tr>
                                <td><strong>#<%= usuario.get("id") %></strong></td>
                                <td><%= usuario.get("correo") %></td>
                                <td><span class="badge text-bg-light border"><%= usuario.get("roles") %></span></td>
                                <td>
                                    <% String estadoActual = String.valueOf(usuario.get("estado")); %>
                                    <% if ("ACTIVO".equals(estadoActual)) { %>
                                        <span class="badge bg-success-subtle text-success-emphasis">ACTIVO</span>
                                    <% } else if ("INACTIVO".equals(estadoActual)) { %>
                                        <span class="badge bg-secondary-subtle text-secondary-emphasis">INACTIVO</span>
                                    <% } else { %>
                                        <span class="badge bg-danger-subtle text-danger-emphasis"><%= estadoActual %></span>
                                    <% } %>
                                </td>
                                <td><%= usuario.get("fecha") %></td>
                                <td>
                                    <form method="post" action="<%= request.getContextPath() %>/acciones/administrador-usuarios.jsp" class="d-flex gap-1">
                                        <input type="hidden" name="accion" value="estado">
                                        <input type="hidden" name="idUsuario" value="<%= usuario.get("id") %>">
                                        <select name="estado" class="form-select form-select-sm" style="min-width:120px">
                                            <option value="ACTIVO" <%= "ACTIVO".equals(estadoActual) ? "selected" : "" %>>Activo</option>
                                            <option value="INACTIVO" <%= "INACTIVO".equals(estadoActual) ? "selected" : "" %>>Inactivo</option>
                                            <option value="BLOQUEADO" <%= "BLOQUEADO".equals(estadoActual) ? "selected" : "" %>>Bloqueado</option>
                                        </select>
                                        <button class="btn btn-outline-primary btn-sm" type="submit">Guardar</button>
                                    </form>
                                </td>
                                <td>
                                    <form method="post" action="<%= request.getContextPath() %>/acciones/administrador-usuarios.jsp" class="d-flex gap-1">
                                        <input type="hidden" name="accion" value="rol">
                                        <input type="hidden" name="idUsuario" value="<%= usuario.get("id") %>">
                                        <select name="idRol" class="form-select form-select-sm" required>
                                            <option value="">Seleccionar</option>
                                            <% for (String[] rol : roles) { %>
                                                <option value="<%= rol[0] %>"><%= rol[1] %></option>
                                            <% } %>
                                        </select>
                                        <button class="btn btn-primary btn-sm" type="submit">Asignar</button>
                                    </form>
                                </td>
                            </tr>
                        <% } %>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="info-panel mt-4">
            <h2>Control de acceso</h2>
            <p class="mb-0">Los cambios realizados aqu&#237; se aplican a las cuentas y sus permisos de acceso.</p>
        </div>
    </div>
</main>
<%@ include file="../../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
