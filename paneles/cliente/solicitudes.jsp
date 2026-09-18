<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.NumberFormat, java.util.Locale" %>
<%
    if (!tieneRol(session, "CLIENTE")) {
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
    List<Map<String, Object>> solicitudes = (List<Map<String, Object>>) request.getAttribute("solicitudes");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mis solicitudes - Inmobiliaria</title>
</head>
<body>
<%@ include file="../../WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header d-flex flex-column flex-md-row justify-content-between gap-3">
            <div>
                <div class="eyebrow">Espacio del cliente</div>
                <h1 class="page-title">Mis solicitudes</h1>
                <p class="page-subtitle">Consulta tus solicitudes y contin&#250;a las que todav&#237;a est&#225;n en borrador.</p>
            </div>
            <a href="<%= request.getContextPath() %>/paneles/cliente.jsp" class="btn btn-outline-primary align-self-start">Volver al panel</a>
        </div>

        <% if ("creada".equals(request.getParameter("mensaje"))) { %>
            <div class="alert alert-success">La solicitud fue registrada correctamente y qued&#243; en revisi&#243;n.</div>
        <% } else if ("existente".equals(request.getParameter("error"))) { %>
            <div class="alert alert-warning">Ya tienes una solicitud activa para esta propiedad.</div>
        <% } else if (request.getAttribute("error") != null || "guardar".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">No se pudo registrar o cargar la solicitud.</div>
        <% } %>

        <% if (solicitudes == null || solicitudes.isEmpty()) { %>
            <div class="empty-state surface-card">
                <span class="material-symbols-outlined">description</span>
                <h2 class="h5 fw-bold mt-2">Todav&#237;a no tienes solicitudes</h2>
                <p class="text-muted mb-3">Cuando quieras iniciar un tr&#225;mite de compra o arriendo, puedes hacerlo desde el detalle de una propiedad.</p>
                <a href="<%= request.getContextPath() %>/acciones/buscar.jsp" class="btn btn-primary">Explorar propiedades</a>
            </div>
        <% } else { %>
            <div class="row g-4">
                <% for (Map<String, Object> solicitud : solicitudes) { %>
                    <div class="col-md-6 col-xl-4">
                        <div class="surface-card h-100 d-flex flex-column">
                            <div class="property-card-top mb-3">
                                <span class="property-type"><%= solicitud.get("tipoPropiedad") %></span>
                                <span class="badge text-bg-light border"><%= solicitud.get("estado") %></span>
                            </div>
                            <h2 class="h5 fw-bold"><%= solicitud.get("titulo") %></h2>
                            <p class="text-muted mb-2"><%= solicitud.get("ciudad") %> &#183; <%= solicitud.get("tipo") %></p>
                            <div class="property-price mb-3">$<%= formatoPrecio.format(solicitud.get("precio")) %></div>
                            <p class="small text-muted">Solicitud #<%= solicitud.get("id") %> &#183; <%= solicitud.get("fecha") %></p>
                            <div class="mt-auto d-grid gap-2">
                                <a href="<%= request.getContextPath() %>/acciones/detalle-propiedad.jsp?id=<%= solicitud.get("idPropiedad") %>" class="btn btn-outline-primary">Ver propiedad</a>
                                <a href="<%= request.getContextPath() %>/acciones/documentos-solicitud.jsp?idSolicitud=<%= solicitud.get("id") %>" class="btn btn-primary"><%= "BORRADOR".equals(solicitud.get("estado")) ? "Continuar solicitud" : "Gestionar documentos" %></a>
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
