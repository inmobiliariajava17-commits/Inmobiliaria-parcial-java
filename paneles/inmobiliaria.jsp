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
    <title>Panel Inmobiliaria</title>
</head>
<body>
<%@ include file="../WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header d-flex flex-column flex-md-row justify-content-between align-items-md-end gap-3">
            <div>
                <div class="eyebrow">Gestión de activos • Java JSP/Servlet</div>
                <h1 class="page-title">Panel de inmobiliaria</h1>
                <p class="page-subtitle">Administra el catálogo de propiedades y consulta los módulos de operación.</p>
            </div>
            <span class="badge rounded-pill text-bg-light border px-3 py-2">Rol: INMOBILIARIA</span>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-6 col-lg-3"><div class="kpi-card"><div class="kpi-label">Propiedades</div><div class="kpi-value">—</div><div class="kpi-note">Consulta tu cartera</div></div></div>
            <div class="col-6 col-lg-3"><div class="kpi-card"><div class="kpi-label">Disponibles</div><div class="kpi-value">—</div><div class="kpi-note">Estado del catálogo</div></div></div>
            <div class="col-6 col-lg-3"><div class="kpi-card"><div class="kpi-label">Citas</div><div class="kpi-value">—</div><div class="kpi-note">Módulo de Sprint 3</div></div></div>
            <div class="col-6 col-lg-3"><div class="kpi-card"><div class="kpi-label">Solicitudes</div><div class="kpi-value">—</div><div class="kpi-note">Módulo de Sprint 3</div></div></div>
        </div>

        <div class="quick-actions mb-4 d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3">
            <div class="d-flex align-items-center gap-3">
                <div class="quick-icon"><span class="material-symbols-outlined">bolt</span></div>
                <div><strong>Acciones operativas</strong><p class="mb-0 text-muted small">Accede directamente al módulo que ya está implementado.</p></div>
            </div>
            <a href="<%= request.getContextPath() %>/propiedades" class="btn btn-primary">Ver mis propiedades</a>
        </div>

        <div class="row g-4">
            <div class="col-lg-7">
                <div class="dashboard-card">
                    <div class="dashboard-icon"><span class="material-symbols-outlined">real_estate_agent</span></div>
                    <h2>Mis propiedades</h2>
                    <p>Consulta las propiedades registradas por tu inmobiliaria con información de precio, estado, ciudad, tipo y matrícula.</p>
                    <a href="<%= request.getContextPath() %>/propiedades" class="btn btn-primary btn-sm">Abrir cartera</a>
                </div>
            </div>
            <div class="col-lg-5">
                <div class="dashboard-card dashboard-card-disabled">
                    <div class="dashboard-icon"><span class="material-symbols-outlined">calendar_month</span></div>
                    <h2>Citas y solicitudes</h2>
                    <p>Estos módulos forman parte del núcleo operativo previsto para el Sprint 3 y todavía no se activan para no alterar las funciones actuales.</p>
                    <span class="badge text-bg-light border">Próximamente</span>
                </div>
            </div>
        </div>
    </div>
</main>
<%@ include file="../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
