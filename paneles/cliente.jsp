<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
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
            <p class="page-subtitle">Aquí se concentrarán tus búsquedas, favoritos, citas y solicitudes.</p>
        </div>
        <div class="row g-4">
            <div class="col-md-6 col-xl-3"><div class="dashboard-card"><div class="dashboard-icon"><span class="material-symbols-outlined">search</span></div><h2>Buscar propiedades</h2><p>Explora el catálogo público y utiliza los filtros disponibles.</p><a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-primary btn-sm">Buscar</a></div></div>
            <div class="col-md-6 col-xl-3"><div class="dashboard-card dashboard-card-disabled"><div class="dashboard-icon"><span class="material-symbols-outlined">favorite</span></div><h2>Favoritos</h2><p>Consulta aquí las propiedades que marques para guardar.</p><span class="badge text-bg-light border">Próximamente</span></div></div>
            <div class="col-md-6 col-xl-3"><div class="dashboard-card dashboard-card-disabled"><div class="dashboard-icon"><span class="material-symbols-outlined">calendar_month</span></div><h2>Mis citas</h2><p>Consulta tus visitas y horarios cuando este módulo esté activo.</p><span class="badge text-bg-light border">Próximamente</span></div></div>
            <div class="col-md-6 col-xl-3"><div class="dashboard-card dashboard-card-disabled"><div class="dashboard-icon"><span class="material-symbols-outlined">description</span></div><h2>Mis solicitudes</h2><p>Consulta el estado de tus trámites de compra o arriendo.</p><span class="badge text-bg-light border">Próximamente</span></div></div>
        </div>
        <div class="info-panel mt-4"><h2>Estado del módulo</h2><p class="mb-0">La interfaz ya queda preparada para crecer con las funciones previstas en el Sprint 3, sin cambiar las funciones que actualmente están operativas.</p></div>
    </div>
</main>
<%@ include file="../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
