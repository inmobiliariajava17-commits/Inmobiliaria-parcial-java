<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
%>
<%
    if (!tieneRol(session, "ADMINISTRADOR")) {
        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Panel Administrador</title>
</head>
<body>
<%@ include file="../WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header">
            <div class="eyebrow">Administraci&#243;n y operaciones</div>
            <h1 class="page-title">Panel de administraci&#243;n</h1>
            <p class="page-subtitle">Gestiona cuentas, propiedades, cat&#225;logos y actividad de la plataforma.</p>
        </div>
        <div class="row g-4">
            <div class="col-md-6 col-lg-3"><div class="dashboard-card"><div class="dashboard-icon"><span class="material-symbols-outlined">group</span></div><h2>Usuarios y roles</h2><p>Administra las cuentas y los permisos de acceso.</p><a href="<%= request.getContextPath() %>/acciones/administrador-usuarios.jsp" class="btn btn-outline-primary btn-sm rounded-pill">Gestionar</a></div></div>
            <div class="col-md-6 col-lg-3"><div class="dashboard-card"><div class="dashboard-icon"><span class="material-symbols-outlined">home_work</span></div><h2>Propiedades</h2><p>Consulta las propiedades y actualiza su estado.</p><a href="<%= request.getContextPath() %>/acciones/administrador-propiedades.jsp" class="btn btn-outline-primary btn-sm rounded-pill">Gestionar</a></div></div>
            <div class="col-md-6 col-lg-3"><div class="dashboard-card"><div class="dashboard-icon"><span class="material-symbols-outlined">category</span></div><h2>Cat&#225;logos</h2><p>Gestiona ciudades, tipos de propiedad y caracter&#237;sticas.</p><a href="<%= request.getContextPath() %>/acciones/administrador-catalogos.jsp" class="btn btn-outline-primary btn-sm rounded-pill">Gestionar</a></div></div>
            <div class="col-md-6 col-lg-3"><div class="dashboard-card"><div class="dashboard-icon"><span class="material-symbols-outlined">bar_chart</span></div><h2>Reportes</h2><p>Consulta indicadores y reportes de la operaci&#243;n.</p><a href="<%= request.getContextPath() %>/acciones/administrador-reportes.jsp" class="btn btn-outline-primary btn-sm rounded-pill">Consultar</a></div></div>
            <div class="col-md-6 col-lg-3"><div class="dashboard-card"><div class="dashboard-icon"><span class="material-symbols-outlined">history</span></div><h2>Auditor&#237;a</h2><p>Consulta la actividad y los cambios realizados.</p><a href="<%= request.getContextPath() %>/acciones/administrador-auditoria.jsp" class="btn btn-outline-primary btn-sm rounded-pill">Consultar</a></div></div>
        </div>
        <div class="info-panel mt-4"><h2>Gesti&#243;n de accesos</h2><p class="mb-0">Los accesos y permisos se gestionan de acuerdo con el tipo de cuenta.</p></div>
    </div>
</main>
<%@ include file="../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
