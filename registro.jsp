<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Registro - Inmobiliaria</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

<%@ include file="WEB-INF/jspf/cabecera.jspf" %>

<div class="container mt-5" style="max-width: 450px;">
    <h2 class="mb-4">Crear cuenta</h2>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
    <% } %>

    <form method="post" action="<%= request.getContextPath() %>/registrar">
        <div class="mb-3">
            <label class="form-label">Correo electrónico</label>
            <input type="email" name="correo" class="form-control" required>
        </div>
        <div class="mb-3">
            <label class="form-label">Contraseña</label>
            <input type="password" name="password" class="form-control" required minlength="6">
        </div>
        <div class="mb-3">
            <label class="form-label">Confirmar contraseña</label>
            <input type="password" name="confirmar" class="form-control" required minlength="6">
        </div>
        <button type="submit" class="btn btn-primary w-100">Registrarme</button>
    </form>

    <p class="mt-3">¿Ya tienes cuenta? <a href="login.jsp">Inicia sesión</a></p>
</div>

<%@ include file="WEB-INF/jspf/pie.jspf" %>
</body>
</html>
