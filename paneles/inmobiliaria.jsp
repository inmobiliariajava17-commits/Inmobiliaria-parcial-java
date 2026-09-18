<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
%>
<%
    if (!tieneRol(session, "INMOBILIARIA")) {
        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
        return;
    }

    int totalPropiedades = 0;
    int propiedadesDisponibles = 0;
    int citasPendientes = 0;
    int solicitudesRevision = 0;
    String errorKpi = null;

    int idUsuarioInmobiliaria = obtenerIdUsuario(session);

    String sqlKpi =
        "SELECT " +
        "(SELECT COUNT(*) FROM propiedad p WHERE p.id_inmobiliaria = " +
        "(SELECT i.id_inmobiliaria FROM inmobiliaria i WHERE i.id_usuario = ?)) AS total_propiedades, " +
        "(SELECT COUNT(*) FROM propiedad p WHERE p.id_inmobiliaria = " +
        "(SELECT i.id_inmobiliaria FROM inmobiliaria i WHERE i.id_usuario = ?) " +
        "AND p.estado = 'DISPONIBLE') AS propiedades_disponibles, " +
        "(SELECT COUNT(*) FROM cita c INNER JOIN propiedad p ON p.id_propiedad = c.id_propiedad " +
        "WHERE p.id_inmobiliaria = (SELECT i.id_inmobiliaria FROM inmobiliaria i WHERE i.id_usuario = ?) " +
        "AND c.estado = 'PENDIENTE') AS citas_pendientes, " +
        "(SELECT COUNT(*) FROM solicitud s INNER JOIN propiedad p ON p.id_propiedad = s.id_propiedad " +
        "WHERE p.id_inmobiliaria = (SELECT i.id_inmobiliaria FROM inmobiliaria i WHERE i.id_usuario = ?) " +
        "AND s.estado = 'EN_REVISION') AS solicitudes_revision";

    try (Connection con = obtenerConexion();
         PreparedStatement ps = con.prepareStatement(sqlKpi)) {
        ps.setInt(1, idUsuarioInmobiliaria);
        ps.setInt(2, idUsuarioInmobiliaria);
        ps.setInt(3, idUsuarioInmobiliaria);
        ps.setInt(4, idUsuarioInmobiliaria);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                totalPropiedades = rs.getInt("total_propiedades");
                propiedadesDisponibles = rs.getInt("propiedades_disponibles");
                citasPendientes = rs.getInt("citas_pendientes");
                solicitudesRevision = rs.getInt("solicitudes_revision");
            }
        }
    } catch (Exception e) {
        errorKpi = e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Panel de gesti&#243;n | Inmobiliaria</title>
</head>
<body>
<%@ include file="../WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header d-flex flex-column flex-md-row justify-content-between align-items-md-end gap-3">
            <div>
                <div class="eyebrow">Gesti&#243;n de propiedades</div>
                <h1 class="page-title">Panel de inmobiliaria</h1>
                <p class="page-subtitle">Administra el cat&#225;logo de propiedades y consulta los m&#243;dulos de operaci&#243;n.</p>
            </div>
            <span class="badge rounded-pill text-bg-light border px-3 py-2">Cuenta inmobiliaria</span>
        </div>

        <% if (errorKpi != null) { %>
            <div class="alert alert-warning">No se pudieron cargar los indicadores del panel. El resto del m&#243;dulo puede seguir utiliz&#225;ndose.</div>
        <% } %>

        <div class="row g-3 mb-4">
            <div class="col-6 col-lg-3"><div class="kpi-card"><div class="kpi-label">Propiedades</div><div class="kpi-value"><%= totalPropiedades %></div><div class="kpi-note">Registradas por tu inmobiliaria</div></div></div>
            <div class="col-6 col-lg-3"><div class="kpi-card"><div class="kpi-label">Disponibles</div><div class="kpi-value"><%= propiedadesDisponibles %></div><div class="kpi-note">Con estado disponible</div></div></div>
            <div class="col-6 col-lg-3"><div class="kpi-card"><div class="kpi-label">Citas</div><div class="kpi-value"><%= citasPendientes %></div><div class="kpi-note">Pendientes de confirmar</div></div></div>
            <div class="col-6 col-lg-3"><div class="kpi-card"><div class="kpi-label">Solicitudes</div><div class="kpi-value"><%= solicitudesRevision %></div><div class="kpi-note">En revisi&#243;n</div></div></div>
        </div>

        <div class="quick-actions mb-4 d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3">
            <div class="d-flex align-items-center gap-3">
                <div class="quick-icon"><span class="material-symbols-outlined">bolt</span></div>
                <div><strong>Acciones operativas</strong><p class="mb-0 text-muted small">Accede r&#225;pidamente a las herramientas de gesti&#243;n de tu cartera.</p></div>
            </div>
            <a href="<%= request.getContextPath() %>/acciones/propiedades.jsp" class="btn btn-primary">Ver mis propiedades</a>
        </div>

        <div class="row g-4">
            <div class="col-lg-7">
                <div class="dashboard-card">
                    <div class="dashboard-icon"><span class="material-symbols-outlined">real_estate_agent</span></div>
                    <h2>Mis propiedades</h2>
                    <p>Consulta las propiedades registradas por tu inmobiliaria con informaci&#243;n de precio, estado, ciudad, tipo y matr&#237;cula.</p>
                    <a href="<%= request.getContextPath() %>/acciones/propiedades.jsp" class="btn btn-primary btn-sm">Abrir cartera</a>
                </div>
            </div>
            <div class="col-lg-5">
                <div class="dashboard-card dashboard-card-disabled">
                    <div class="dashboard-icon"><span class="material-symbols-outlined">calendar_month</span></div>
                    <h2>Citas y solicitudes</h2>
                    <p>Gestiona las visitas y revisa los tr&#225;mites enviados por los clientes.</p>
                    <div class="d-flex flex-wrap gap-2">
                        <a href="<%= request.getContextPath() %>/acciones/citas-inmobiliaria.jsp" class="btn btn-primary btn-sm">Gestionar citas</a>
                        <a href="<%= request.getContextPath() %>/acciones/solicitudes-inmobiliaria.jsp" class="btn btn-outline-primary btn-sm">Gestionar solicitudes</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>
<%@ include file="../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
