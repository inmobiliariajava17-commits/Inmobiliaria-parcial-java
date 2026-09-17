<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    List<Map<String,Object>> solicitudes = (List<Map<String,Object>>) request.getAttribute("solicitudes");
    Map<String,Object> detalle = (Map<String,Object>) request.getAttribute("solicitudDetalle");
    List<Map<String,Object>> documentos = (List<Map<String,Object>>) request.getAttribute("documentosDetalle");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Solicitudes - Inmobiliaria</title>
</head>
<body>
<%@ include file="../../WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap"><div class="container app-container">
    <div class="page-header d-flex flex-column flex-md-row justify-content-between gap-3">
        <div><div class="eyebrow">Operación de la inmobiliaria</div><h1 class="page-title">Solicitudes de clientes</h1><p class="page-subtitle">Revisa trámites y documentos de tus propiedades.</p></div>
        <a href="<%= request.getContextPath() %>/paneles/inmobiliaria.jsp" class="btn btn-outline-primary align-self-start">Volver al panel</a>
    </div>

    <% String mensaje=request.getParameter("mensaje"); String error=request.getParameter("error"); %>
    <% if ("aprobar".equals(mensaje)) { %><div class="alert alert-success">La solicitud fue aprobada correctamente.</div><% } %>
    <% if ("rechazar".equals(mensaje)) { %><div class="alert alert-success">La solicitud fue rechazada correctamente.</div><% } %>
    <% if (error != null) { %><div class="alert alert-danger">No se pudo procesar la solicitud. Verifica que esté en revisión.</div><% } %>

    <div class="surface-card mb-4"><div class="d-flex flex-wrap gap-2">
        <a class="btn btn-sm <%= request.getParameter("estado")==null ? "btn-primary":"btn-outline-primary" %>" href="<%=request.getContextPath()%>/solicitudes-inmobiliaria">Todas</a>
        <a class="btn btn-sm <%= "EN_REVISION".equals(request.getParameter("estado")) ? "btn-primary":"btn-outline-primary" %>" href="<%=request.getContextPath()%>/solicitudes-inmobiliaria?estado=EN_REVISION">En revisión</a>
        <a class="btn btn-sm <%= "APROBADA".equals(request.getParameter("estado")) ? "btn-primary":"btn-outline-primary" %>" href="<%=request.getContextPath()%>/solicitudes-inmobiliaria?estado=APROBADA">Aprobadas</a>
        <a class="btn btn-sm <%= "RECHAZADA".equals(request.getParameter("estado")) ? "btn-primary":"btn-outline-primary" %>" href="<%=request.getContextPath()%>/solicitudes-inmobiliaria?estado=RECHAZADA">Rechazadas</a>
        <a class="btn btn-sm <%= "BORRADOR".equals(request.getParameter("estado")) ? "btn-primary":"btn-outline-primary" %>" href="<%=request.getContextPath()%>/solicitudes-inmobiliaria?estado=BORRADOR">Borradores</a>
    </div></div>

    <% if (solicitudes == null || solicitudes.isEmpty()) { %>
        <div class="empty-state surface-card"><span class="material-symbols-outlined">description</span><h2 class="h5 fw-bold mt-2">No hay solicitudes</h2><p class="text-muted mb-0">Las solicitudes relacionadas con tus propiedades aparecerán aquí.</p></div>
    <% } else { %>
        <div class="row g-4 align-items-start">
        <% for (Map<String,Object> s : solicitudes) {
            String cliente=(String.valueOf(s.get("nombres"))+" "+String.valueOf(s.get("apellidos"))).trim();
            if(cliente.isBlank()) cliente=String.valueOf(s.get("correo"));
            boolean seleccionada = detalle != null && String.valueOf(detalle.get("id")).equals(String.valueOf(s.get("id")));
        %>
            <div class="col-lg-6 align-self-start" id="solicitud-<%=s.get("id")%>"><div class="surface-card">
                <div class="d-flex justify-content-between align-items-start gap-3 mb-3"><div><div class="small text-muted">Solicitud #<%=s.get("id")%></div><h2 class="h5 fw-bold mb-1"><%=s.get("titulo")%></h2><div class="small text-muted"><%=s.get("ciudad")%> · Matrícula <%=s.get("matricula")%></div></div><span class="badge text-bg-light border solicitud-card-status"><%=s.get("estado")%></span></div>
                <div class="row g-2 small mb-3"><div class="col-sm-6"><span class="text-muted">Cliente:</span> <strong><%=cliente%></strong></div><div class="col-sm-6"><span class="text-muted">Trámite:</span> <strong><%=s.get("tipo")%></strong></div><div class="col-sm-6"><span class="text-muted">Documentos:</span> <strong><%=s.get("documentos")%></strong></div><div class="col-sm-6"><span class="text-muted">Fecha:</span> <%=s.get("fecha")%></div></div>
                <% if (!seleccionada) { %>
                    <a class="btn btn-primary btn-sm" href="<%=request.getContextPath()%>/solicitudes-inmobiliaria?idSolicitud=<%=s.get("id")%>#solicitud-<%=s.get("id")%>">Ver solicitud</a>
                <% } else { %>
                    <div class="border-top pt-3 mt-2">
                        <div class="d-flex justify-content-between align-items-start gap-3 mb-3">
                            <div><div class="eyebrow">Detalle</div><h3 class="h5 fw-bold mb-0">Información de la solicitud</h3></div>
                            <a class="btn btn-outline-secondary btn-sm" href="<%=request.getContextPath()%>/solicitudes-inmobiliaria#solicitud-<%=s.get("id")%>">Cerrar</a>
                        </div>
                        <div class="row g-3 small mb-4">
                            <div class="col-md-6"><strong>Cliente</strong><br><%=detalle.get("nombres")%> <%=detalle.get("apellidos")%></div>
                            <div class="col-md-6"><strong>Correo</strong><br><%=detalle.get("correo")%></div>
                            <div class="col-md-6"><strong>Teléfono</strong><br><%=String.valueOf(detalle.get("telefono")).isBlank()?"No registrado":detalle.get("telefono")%></div>
                            <div class="col-md-6"><strong>Trámite</strong><br><%=detalle.get("tipo")%></div>
                            <div class="col-md-6"><strong>Propiedad</strong><br><%=detalle.get("titulo")%></div>
                            <div class="col-md-6"><strong>Ciudad</strong><br><%=detalle.get("ciudad")%></div>
                        </div>
                        <h4 class="h6 fw-bold">Documentos</h4>
                        <% if (documentos == null || documentos.isEmpty()) { %>
                            <p class="text-muted small">No hay documentos cargados.</p>
                        <% } else { %>
                            <div class="list-group mb-4"><% for(Map<String,Object> d: documentos){ %><div class="list-group-item d-flex justify-content-between align-items-center gap-3"><div><strong><%=d.get("tipo")%></strong><div class="small text-muted"><%=d.get("nombre")%> · <%=d.get("fecha")%></div></div><a class="btn btn-outline-primary btn-sm" target="_blank" href="<%=d.get("url")%>">Ver documento</a></div><% } %></div>
                        <% } %>
                        <% if ("EN_REVISION".equals(String.valueOf(detalle.get("estado")))) { %>
                            <div class="d-flex flex-wrap gap-2"><form method="post"><input type="hidden" name="idSolicitud" value="<%=detalle.get("id")%>"><input type="hidden" name="accion" value="aprobar"><button class="btn btn-primary" type="submit">Aprobar solicitud</button></form><form method="post"><input type="hidden" name="idSolicitud" value="<%=detalle.get("id")%>"><input type="hidden" name="accion" value="rechazar"><button class="btn btn-outline-danger" type="submit">Rechazar solicitud</button></form></div>
                        <% } else { %>
                            <p class="small text-muted mb-0">Esta solicitud no está en revisión y no tiene acciones disponibles.</p>
                        <% } %>
                    </div>
                <% } %>
            </div></div>
        <% } %></div>
    <% } %>

    <style>
        .solicitud-card-status {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: auto !important;
            height: auto !important;
            min-height: 0 !important;
            padding: .38rem .62rem !important;
            border-radius: 999px !important;
            font-size: .68rem !important;
            font-weight: 700 !important;
            white-space: nowrap;
            line-height: 1.2;
            flex: 0 0 auto;
        }
        .solicitud-card .surface-card {
            height: auto;
        }
        html { scroll-behavior: smooth; }
        [id^="solicitud-"] { scroll-margin-top: 90px; }
    </style>
</div></main>
<%@ include file="../../WEB-INF/jspf/pie.jspf" %>
</body></html>
