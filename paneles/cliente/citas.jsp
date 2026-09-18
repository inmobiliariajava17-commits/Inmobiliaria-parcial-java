<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map, java.sql.Timestamp" %>
<%
    if (!tieneRol(session, "CLIENTE")) {
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
    <title>Mis citas</title>
</head>
<body>
<%@ include file="../../WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header d-flex flex-column flex-md-row justify-content-between gap-3">
            <div>
                <div class="eyebrow">Espacio del cliente</div>
                <h1 class="page-title">Mis citas</h1>
                <p class="page-subtitle">Consulta las visitas que has agendado para conocer las propiedades.</p>
            </div>
            <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-outline-primary align-self-start">Buscar propiedades</a>
        </div>

        <% if ("agendada".equals(request.getParameter("mensaje"))) { %>
            <div class="alert alert-success">La visita fue agendada correctamente.</div>
        <% } else if ("cancelada".equals(request.getParameter("mensaje"))) { %>
            <div class="alert alert-success">La cita fue cancelada.</div>
        <% } else if (request.getParameter("error") != null || request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">No se pudo completar la operaci&#243;n.</div>
        <% } %>

        <% if (citas == null || citas.isEmpty()) { %>
            <div class="empty-panel surface-card">
                <span class="material-symbols-outlined">calendar_month</span>
                <h2 class="h5 fw-bold">Todav&#237;a no tienes citas</h2>
                <p class="text-muted mb-3">Cuando quieras visitar una propiedad, podr&#225;s agendar la visita desde su detalle.</p>
                <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-primary">Explorar propiedades</a>
            </div>
        <% } else { %>
            <div class="row g-4">
                <% for (Map<String, Object> cita : citas) {
                    String estado = String.valueOf(cita.get("estado"));
                    Timestamp fechaHora = (Timestamp) cita.get("fechaHora");
                %>
                    <div class="col-md-6 col-xl-4">
                        <article class="surface-card h-100 p-4">
                            <div class="property-card-top mb-3">
                                <span class="property-type"><%= cita.get("tipo") %></span>
                                <span class="property-status <%= "PENDIENTE".equals(estado) || "CONFIRMADA".equals(estado) ? "status-available" : "status-other" %>"><%= estado %></span>
                            </div>
                            <h2 class="h5 fw-bold mb-2"><%= cita.get("titulo") %></h2>
                            <p class="text-muted mb-2"><%= cita.get("ciudad") %></p>
                            <div class="detail-list mb-3">
                                <div><span>Fecha</span><strong><%= String.format("%02d/%02d/%04d", fechaHora.toLocalDateTime().getDayOfMonth(), fechaHora.toLocalDateTime().getMonthValue(), fechaHora.toLocalDateTime().getYear()) %></strong></div>
                                <div><span>Hora</span><strong><%= String.format("%02d:%02d", fechaHora.toLocalDateTime().getHour(), fechaHora.toLocalDateTime().getMinute()) %></strong></div>
                            </div>
                            <div class="d-flex gap-2">
                                <a href="<%= request.getContextPath() %>/acciones/detalle-propiedad.jsp?id=<%= cita.get("idPropiedad") %>" class="btn btn-outline-primary btn-sm flex-grow-1">Ver propiedad</a>
                                <% if ("PENDIENTE".equals(estado) || "CONFIRMADA".equals(estado)) { %>
                                    <form method="post" action="<%= request.getContextPath() %>/acciones/citas.jsp" onsubmit="return confirm('&#191;Deseas cancelar esta cita?');">
                                        <input type="hidden" name="accion" value="cancelar">
                                        <input type="hidden" name="idCita" value="<%= cita.get("id") %>">
                                        <button type="submit" class="btn btn-outline-danger btn-sm">Cancelar</button>
                                    </form>
                                <% } %>
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
