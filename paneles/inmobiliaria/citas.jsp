<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    if (!tieneRol(session, "INMOBILIARIA")) {
        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
        return;
    }
%>

<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
    List<Map<String, Object>> citas = (List<Map<String, Object>>) request.getAttribute("citas");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Citas - Inmobiliaria</title>
</head>
<body>
<%@ include file="../../WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header d-flex flex-column flex-md-row justify-content-between gap-3">
            <div>
                <div class="eyebrow">Operaci&#243;n de la inmobiliaria</div>
                <h1 class="page-title">Gesti&#243;n de citas</h1>
                <p class="page-subtitle">Consulta las visitas solicitadas por los clientes y actualiza su estado.</p>
            </div>
            <a href="<%= request.getContextPath() %>/paneles/inmobiliaria.jsp" class="btn btn-outline-primary align-self-start">Volver al panel</a>
        </div>

        <% if ("confirmar".equals(request.getParameter("mensaje"))) { %>
            <div class="alert alert-success">La cita fue confirmada correctamente.</div>
        <% } else if ("cancelar".equals(request.getParameter("mensaje"))) { %>
            <div class="alert alert-success">La cita fue cancelada correctamente.</div>
        <% } else if ("realizar".equals(request.getParameter("mensaje"))) { %>
            <div class="alert alert-success">La cita fue marcada como realizada.</div>
        <% } else if (request.getAttribute("error") != null || "guardar".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">No se pudo actualizar o cargar la cita.</div>
        <% } else if ("datos".equals(request.getParameter("error"))) { %>
            <div class="alert alert-warning">Los datos de la cita no son v&#225;lidos.</div>
        <% } %>

        <div class="surface-card mb-4">
            <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3">
                <div>
                    <strong>Filtrar por estado</strong>
                    <div class="small text-muted">Puedes consultar todas las citas o solo las que est&#233;n pendientes, confirmadas o realizadas.</div>
                </div>
                <div class="d-flex flex-wrap gap-2">
                    <a href="<%= request.getContextPath() %>/acciones/citas-inmobiliaria.jsp" class="btn btn-sm <%= request.getParameter("estado") == null ? "btn-primary" : "btn-outline-primary" %>">Todas</a>
                    <a href="<%= request.getContextPath() %>/acciones/citas-inmobiliaria.jsp?estado=PENDIENTE" class="btn btn-sm <%= "PENDIENTE".equals(request.getParameter("estado")) ? "btn-primary" : "btn-outline-primary" %>">Pendientes</a>
                    <a href="<%= request.getContextPath() %>/acciones/citas-inmobiliaria.jsp?estado=CONFIRMADA" class="btn btn-sm <%= "CONFIRMADA".equals(request.getParameter("estado")) ? "btn-primary" : "btn-outline-primary" %>">Confirmadas</a>
                    <a href="<%= request.getContextPath() %>/acciones/citas-inmobiliaria.jsp?estado=REALIZADA" class="btn btn-sm <%= "REALIZADA".equals(request.getParameter("estado")) ? "btn-primary" : "btn-outline-primary" %>">Realizadas</a>
                    <a href="<%= request.getContextPath() %>/acciones/citas-inmobiliaria.jsp?estado=CANCELADA" class="btn btn-sm <%= "CANCELADA".equals(request.getParameter("estado")) ? "btn-primary" : "btn-outline-primary" %>">Canceladas</a>
                </div>
            </div>
        </div>

        <% if (citas == null || citas.isEmpty()) { %>
            <div class="empty-state surface-card">
                <span class="material-symbols-outlined">event_busy</span>
                <h2 class="h5 fw-bold mt-2">No hay citas para mostrar</h2>
                <p class="text-muted mb-0">Cuando un cliente agende una visita para una de tus propiedades, aparecer&#225; aqu&#237;.</p>
            </div>
        <% } else { %>
            <div class="row g-4">
                <% for (Map<String, Object> cita : citas) {
                    String estado = String.valueOf(cita.get("estado"));
                    String nombres = String.valueOf(cita.get("nombres"));
                    String apellidos = String.valueOf(cita.get("apellidos"));
                    String cliente = (nombres + " " + apellidos).trim();
                    if (cliente.isBlank()) cliente = String.valueOf(cita.get("correo"));
                %>
                    <div class="col-lg-6">
                        <div class="surface-card h-100">
                            <div class="d-flex justify-content-between align-items-start gap-3 mb-3">
                                <div>
                                    <div class="small text-muted">Cita #<%= cita.get("id") %></div>
                                    <h2 class="h5 fw-bold mb-1"><%= cita.get("titulo") %></h2>
                                    <div class="small text-muted"><%= cita.get("ciudad") %> &#183; Matr&#237;cula <%= cita.get("matricula") %></div>
                                </div>
                                <span class="badge text-bg-light border"><%= estado %></span>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-sm-6">
                                    <div class="small text-muted">Fecha y hora</div>
                                    <strong><%= cita.get("fechaHora") %></strong>
                                </div>
                                <div class="col-sm-6">
                                    <div class="small text-muted">Cliente</div>
                                    <strong><%= cliente %></strong>
                                </div>
                                <div class="col-sm-6">
                                    <div class="small text-muted">Correo</div>
                                    <span><%= cita.get("correo") %></span>
                                </div>
                                <div class="col-sm-6">
                                    <div class="small text-muted">Tel&#233;fono</div>
                                    <span><%= cita.get("telefono") == null || String.valueOf(cita.get("telefono")).isBlank() ? "No registrado" : cita.get("telefono") %></span>
                                </div>
                            </div>

                            <div class="d-flex flex-wrap gap-2">
                                <% if ("PENDIENTE".equals(estado)) { %>
                                    <form method="post" action="<%= request.getContextPath() %>/acciones/citas-inmobiliaria.jsp" class="d-inline">
                                        <input type="hidden" name="idCita" value="<%= cita.get("id") %>">
                                        <input type="hidden" name="accion" value="confirmar">
                                        <button type="submit" class="btn btn-primary btn-sm">Confirmar cita</button>
                                    </form>
                                    <form method="post" action="<%= request.getContextPath() %>/acciones/citas-inmobiliaria.jsp" class="d-inline">
                                        <input type="hidden" name="idCita" value="<%= cita.get("id") %>">
                                        <input type="hidden" name="accion" value="cancelar">
                                        <button type="submit" class="btn btn-outline-danger btn-sm">Cancelar</button>
                                    </form>
                                <% } else if ("CONFIRMADA".equals(estado)) { %>
                                    <form method="post" action="<%= request.getContextPath() %>/acciones/citas-inmobiliaria.jsp" class="d-inline">
                                        <input type="hidden" name="idCita" value="<%= cita.get("id") %>">
                                        <input type="hidden" name="accion" value="realizar">
                                        <button type="submit" class="btn btn-primary btn-sm">Marcar realizada</button>
                                    </form>
                                    <form method="post" action="<%= request.getContextPath() %>/acciones/citas-inmobiliaria.jsp" class="d-inline">
                                        <input type="hidden" name="idCita" value="<%= cita.get("id") %>">
                                        <input type="hidden" name="accion" value="cancelar">
                                        <button type="submit" class="btn btn-outline-danger btn-sm">Cancelar</button>
                                    </form>
                                <% } else { %>
                                    <span class="small text-muted">No hay acciones disponibles para este estado.</span>
                                <% } %>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>
</main>
<%@ include file="../../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
