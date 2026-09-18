<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
%>
<%
    if (!tieneRol(session, "CLIENTE")) {
        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Panel Cliente</title>
</head>
<body>
<%@ include file="../WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header">
            <div class="eyebrow">Espacio del cliente</div>
            <h1 class="page-title">Panel del cliente</h1>
            <p class="page-subtitle">Aqu&#237; se concentrar&#225;n tus b&#250;squedas, favoritos, citas y solicitudes.</p>
        </div>
        <div class="row g-4">
            <div class="col-md-6 col-xl-3"><div class="dashboard-card"><div class="dashboard-icon"><span class="material-symbols-outlined">search</span></div><h2>Buscar propiedades</h2><p>Explora el cat&#225;logo p&#250;blico y utiliza los filtros disponibles.</p><a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-primary btn-sm">Buscar</a></div></div>
            <div class="col-md-6 col-xl-3"><div class="dashboard-card"><div class="dashboard-icon"><span class="material-symbols-outlined">favorite</span></div><h2>Favoritos</h2><p>Consulta aqu&#237; las propiedades que marques para guardar.</p><a href="<%= request.getContextPath() %>/acciones/favoritos.jsp" class="btn btn-primary btn-sm">Ver favoritos</a></div></div>
            <div class="col-md-6 col-xl-3"><div class="dashboard-card"><div class="dashboard-icon"><span class="material-symbols-outlined">calendar_month</span></div><h2>Mis citas</h2><p>Consulta tus visitas y horarios programados.</p><a href="<%= request.getContextPath() %>/acciones/citas.jsp" class="btn btn-primary btn-sm">Ver citas</a></div></div>
            <div class="col-md-6 col-xl-3"><div class="dashboard-card"><div class="dashboard-icon"><span class="material-symbols-outlined">description</span></div><h2>Mis solicitudes</h2><p>Consulta el estado de tus tr&#225;mites de compra o arriendo.</p><a href="<%= request.getContextPath() %>/acciones/solicitudes.jsp" class="btn btn-primary btn-sm">Ver solicitudes</a></div></div>
            <div class="col-md-6 col-xl-3"><div class="dashboard-card"><div class="dashboard-icon"><span class="material-symbols-outlined">person</span></div><h2>Mi perfil</h2><p>Completa o actualiza tus datos personales.</p><a href="<%= request.getContextPath() %>/acciones/perfil.jsp" class="btn btn-primary btn-sm">Editar perfil</a></div></div>
        </div>
        <div class="info-panel mt-4"><h2>Estado del m&#243;dulo</h2><p class="mb-0">La interfaz ya queda preparada para crecer con las funciones previstas en el Sprint 3, sin cambiar las funciones que actualmente est&#225;n operativas.</p></div>
    </div>
</main>
<%@ include file="../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
