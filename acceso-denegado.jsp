<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Acceso denegado</title>
</head>
<body>
<%@ include file="WEB-INF/jspf/cabecera.jspf" %>
<main class="auth-page">
    <div class="surface-card text-center" style="max-width:620px;width:100%;margin:auto;">
        <span class="material-symbols-outlined text-danger" style="font-size:52px">lock</span>
        <div class="eyebrow mt-3">Control de acceso</div>
        <h1 class="page-title">Acceso denegado</h1>
        <p class="page-subtitle mb-4">No tienes el rol necesario para acceder a esta secci&#243;n.</p>
        <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-primary">Volver al inicio</a>
    </div>
</main>
<%@ include file="WEB-INF/jspf/pie.jspf" %>
</body>
</html>
