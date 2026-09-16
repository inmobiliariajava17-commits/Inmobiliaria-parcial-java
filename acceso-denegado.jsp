<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Acceso denegado</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

<%@ include file="WEB-INF/jspf/cabecera.jspf" %>

<div class="container mt-5 text-center">
    <h2>Acceso denegado</h2>
    <p>No tienes permiso para ver esta página con tu rol actual.</p>
    <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-primary">Volver al inicio</a>
</div>

<%@ include file="WEB-INF/jspf/pie.jspf" %>
</body>
</html>
