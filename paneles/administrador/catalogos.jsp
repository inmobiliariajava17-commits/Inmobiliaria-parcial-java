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
    List<Map<String, Object>> ciudades = (List<Map<String, Object>>) request.getAttribute("ciudades");
    List<Map<String, Object>> tipos = (List<Map<String, Object>>) request.getAttribute("tipos");
    List<Map<String, Object>> caracteristicas = (List<Map<String, Object>>) request.getAttribute("caracteristicas");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cat&#225;logos | Administraci&#243;n</title>
</head>
<body>
<%@ include file="../../WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header d-flex flex-column flex-md-row justify-content-between align-items-md-end gap-3">
            <div>
                <div class="eyebrow">Administraci&#243;n</div>
                <h1 class="page-title">Cat&#225;logos</h1>
                <p class="page-subtitle">Administra las ciudades, tipos de propiedad y caracter&#237;sticas disponibles.</p>
            </div>
            <a href="<%= request.getContextPath() %>/paneles/administrador.jsp" class="btn btn-outline-primary btn-sm rounded-pill">Volver al panel</a>
        </div>

        <% String mensaje = request.getParameter("mensaje"); %>
        <% String error = request.getParameter("error"); %>
        <% if ("creado".equals(mensaje)) { %>
            <div class="alert alert-success">Registro creado correctamente.</div>
        <% } else if ("editado".equals(mensaje)) { %>
            <div class="alert alert-success">Registro actualizado correctamente.</div>
        <% } else if ("eliminado".equals(mensaje)) { %>
            <div class="alert alert-success">Registro eliminado correctamente.</div>
        <% } else if ("duplicado".equals(error)) { %>
            <div class="alert alert-warning">Ya existe un registro con ese nombre.</div>
        <% } else if ("usado".equals(error)) { %>
            <div class="alert alert-warning">No se puede eliminar porque el registro est&#225; siendo utilizado por otros datos.</div>
        <% } else if ("datos".equals(error)) { %>
            <div class="alert alert-warning">Revisa los datos enviados.</div>
        <% } else if ("bd".equals(error)) { %>
            <div class="alert alert-danger">No se pudo completar la operaci&#243;n. Intenta nuevamente.</div>
        <% } %>

        <div class="row g-4">
            <div class="col-lg-4">
                <div class="surface-card h-100">
                    <div class="dashboard-icon mb-3"><span class="material-symbols-outlined">location_city</span></div>
                    <h2 class="h5 fw-bold">Ciudades</h2>
                    <p class="text-muted small">Ciudades disponibles para ubicar las propiedades.</p>
                    <form method="post" action="<%= request.getContextPath() %>/acciones/administrador-catalogos.jsp" class="mb-4">
                        <input type="hidden" name="catalogo" value="ciudad">
                        <input type="hidden" name="accion" value="crear">
                        <label class="form-label">Nueva ciudad</label>
                        <div class="input-group">
                            <input type="text" name="nombre" class="form-control" maxlength="100" required>
                            <button class="btn btn-primary" type="submit">Agregar</button>
                        </div>
                    </form>
                    <div class="catalog-list">
                        <% for (Map<String, Object> item : ciudades) { %>
                            <div class="catalog-row">
                                <form method="post" action="<%= request.getContextPath() %>/acciones/administrador-catalogos.jsp" class="d-flex gap-2 flex-grow-1">
                                    <input type="hidden" name="catalogo" value="ciudad">
                                    <input type="hidden" name="accion" value="editar">
                                    <input type="hidden" name="id" value="<%= item.get("id") %>">
                                    <input type="text" name="nombre" value="<%= item.get("nombre") %>" class="form-control form-control-sm" maxlength="100" required>
                                    <button class="btn btn-outline-primary btn-sm" type="submit">Guardar</button>
                                </form>
                                <form method="post" action="<%= request.getContextPath() %>/acciones/administrador-catalogos.jsp">
                                    <input type="hidden" name="catalogo" value="ciudad">
                                    <input type="hidden" name="accion" value="eliminar">
                                    <input type="hidden" name="id" value="<%= item.get("id") %>">
                                    <button class="btn btn-outline-danger btn-sm" type="submit" onclick="return confirm('&#191;Eliminar esta ciudad?');">Eliminar</button>
                                </form>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="surface-card h-100">
                    <div class="dashboard-icon mb-3"><span class="material-symbols-outlined">home_work</span></div>
                    <h2 class="h5 fw-bold">Tipos de propiedad</h2>
                    <p class="text-muted small">Tipos usados para clasificar las propiedades.</p>
                    <form method="post" action="<%= request.getContextPath() %>/acciones/administrador-catalogos.jsp" class="mb-4">
                        <input type="hidden" name="catalogo" value="tipo">
                        <input type="hidden" name="accion" value="crear">
                        <label class="form-label">Nuevo tipo</label>
                        <div class="input-group">
                            <input type="text" name="nombre" class="form-control" maxlength="50" required>
                            <button class="btn btn-primary" type="submit">Agregar</button>
                        </div>
                    </form>
                    <div class="catalog-list">
                        <% for (Map<String, Object> item : tipos) { %>
                            <div class="catalog-row">
                                <form method="post" action="<%= request.getContextPath() %>/acciones/administrador-catalogos.jsp" class="d-flex gap-2 flex-grow-1">
                                    <input type="hidden" name="catalogo" value="tipo">
                                    <input type="hidden" name="accion" value="editar">
                                    <input type="hidden" name="id" value="<%= item.get("id") %>">
                                    <input type="text" name="nombre" value="<%= item.get("nombre") %>" class="form-control form-control-sm" maxlength="50" required>
                                    <button class="btn btn-outline-primary btn-sm" type="submit">Guardar</button>
                                </form>
                                <form method="post" action="<%= request.getContextPath() %>/acciones/administrador-catalogos.jsp">
                                    <input type="hidden" name="catalogo" value="tipo">
                                    <input type="hidden" name="accion" value="eliminar">
                                    <input type="hidden" name="id" value="<%= item.get("id") %>">
                                    <button class="btn btn-outline-danger btn-sm" type="submit" onclick="return confirm('&#191;Eliminar este tipo?');">Eliminar</button>
                                </form>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="surface-card h-100">
                    <div class="dashboard-icon mb-3"><span class="material-symbols-outlined">tune</span></div>
                    <h2 class="h5 fw-bold">Caracter&#237;sticas</h2>
                    <p class="text-muted small">Caracter&#237;sticas que pueden asociarse a una propiedad.</p>
                    <form method="post" action="<%= request.getContextPath() %>/acciones/administrador-catalogos.jsp" class="mb-4">
                        <input type="hidden" name="catalogo" value="caracteristica">
                        <input type="hidden" name="accion" value="crear">
                        <label class="form-label">Nueva caracter&#237;stica</label>
                        <div class="input-group">
                            <input type="text" name="nombre" class="form-control" maxlength="60" required>
                            <button class="btn btn-primary" type="submit">Agregar</button>
                        </div>
                    </form>
                    <div class="catalog-list">
                        <% for (Map<String, Object> item : caracteristicas) { %>
                            <div class="catalog-row">
                                <form method="post" action="<%= request.getContextPath() %>/acciones/administrador-catalogos.jsp" class="d-flex gap-2 flex-grow-1">
                                    <input type="hidden" name="catalogo" value="caracteristica">
                                    <input type="hidden" name="accion" value="editar">
                                    <input type="hidden" name="id" value="<%= item.get("id") %>">
                                    <input type="text" name="nombre" value="<%= item.get("nombre") %>" class="form-control form-control-sm" maxlength="60" required>
                                    <button class="btn btn-outline-primary btn-sm" type="submit">Guardar</button>
                                </form>
                                <form method="post" action="<%= request.getContextPath() %>/acciones/administrador-catalogos.jsp">
                                    <input type="hidden" name="catalogo" value="caracteristica">
                                    <input type="hidden" name="accion" value="eliminar">
                                    <input type="hidden" name="id" value="<%= item.get("id") %>">
                                    <button class="btn btn-outline-danger btn-sm" type="submit" onclick="return confirm('&#191;Eliminar esta caracter&#237;stica?');">Eliminar</button>
                                </form>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <div class="info-panel mt-4">
            <h2>Control de integridad</h2>
            <p class="mb-0">Para proteger la informaci&#243;n, no se pueden eliminar ciudades, tipos o caracter&#237;sticas que est&#233;n actualmente en uso.</p>
        </div>
    </div>
</main>
<%@ include file="../../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
