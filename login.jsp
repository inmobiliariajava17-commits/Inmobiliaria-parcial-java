<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Ingresar - Inmobiliaria</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

<%@ include file="WEB-INF/jspf/cabecera.jspf" %>

<div class="container mt-5" style="max-width: 400px;">
    <h2 class="mb-4">Iniciar sesión</h2>

    <% if (request.getAttribute("mensaje") != null) { %>
        <div class="alert alert-success"><%= request.getAttribute("mensaje") %></div>
    <% } %>
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
    <% } %>
    <% if ("sesion".equals(request.getParameter("error"))) { %>
        <div class="alert alert-warning">Debes iniciar sesión para continuar</div>
    <% } %>

    <form method="post" action="<%= request.getContextPath() %>/ingresar">
        <div class="mb-3">
            <label class="form-label">Correo electrónico</label>
            <input type="email" name="correo" class="form-control" required>
        </div>
        <div class="mb-3">
            <label class="form-label">Contraseña</label>
            <input type="password" name="password" class="form-control" required>
        </div>
        <button type="submit" class="btn btn-primary w-100">Ingresar</button>
    </form>

    <p class="mt-3">¿No tienes cuenta? <a href="registro.jsp">Regístrate</a></p>
</div>

<%@ include file="WEB-INF/jspf/pie.jspf" %>
</body>
</html>
