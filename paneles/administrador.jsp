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
    <title>Panel Administrador</title>
</head>
<body>
<%@ include file="../WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header">
            <div class="eyebrow">Administración del sistema</div>
            <h1 class="page-title">Panel del administrador</h1>
            <p class="page-subtitle">Control general de usuarios, roles, catálogos y auditoría.</p>
        </div>
        <div class="row g-4">
            <div class="col-md-6 col-lg-3"><div class="dashboard-card"><div class="dashboard-icon"><span class="material-symbols-outlined">group</span></div><h2>Usuarios y roles</h2><p>Gestión de cuentas y asignación de permisos del sistema.</p><span class="badge text-bg-light border">Próximamente</span></div></div>
            <div class="col-md-6 col-lg-3"><div class="dashboard-card"><div class="dashboard-icon"><span class="material-symbols-outlined">category</span></div><h2>Catálogos</h2><p>Tipos de propiedad, ciudades y características.</p><span class="badge text-bg-light border">Próximamente</span></div></div>
            <div class="col-md-6 col-lg-3"><div class="dashboard-card"><div class="dashboard-icon"><span class="material-symbols-outlined">bar_chart</span></div><h2>Reportes</h2><p>Consultas consolidadas y agregaciones del sistema.</p><span class="badge text-bg-light border">Próximamente</span></div></div>
            <div class="col-md-6 col-lg-3"><div class="dashboard-card"><div class="dashboard-icon"><span class="material-symbols-outlined">history</span></div><h2>Auditoría</h2><p>Seguimiento de accesos y cambios registrados.</p><span class="badge text-bg-light border">Próximamente</span></div></div>
        </div>
        <div class="info-panel mt-4"><h2>Control por servidor</h2><p class="mb-0">El filtro de acceso continúa siendo la barrera real de las rutas privadas. Esta renovación es visual y no sustituye las validaciones del servidor.</p></div>
    </div>
</main>
<%@ include file="../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
