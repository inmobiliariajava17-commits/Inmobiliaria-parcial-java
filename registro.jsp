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
    <title>Crear cuenta - Inmobiliaria</title>
</head>
<body>
<%@ include file="WEB-INF/jspf/cabecera.jspf" %>

<main class="auth-page">
    <div class="auth-card row g-0">
        <div class="col-lg-5 auth-side">
            <div class="eyebrow text-white-50">Nuevo usuario</div>
            <h1>Crea tu cuenta</h1>
            <p>El registro crea una cuenta de usuario y la asigna al rol de cliente, manteniendo el acceso controlado.</p>
            <div class="auth-side-item"><span class="material-symbols-outlined">mail</span><span>El correo se valida y no puede repetirse.</span></div>
            <div class="auth-side-item"><span class="material-symbols-outlined">lock</span><span>La contraseña se almacena cifrada.</span></div>
        </div>
        <div class="col-lg-7 auth-form">
            <h2>Crear cuenta</h2>
            <p class="help mb-4">Completa los datos para registrarte.</p>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
            <% } %>

            <form method="post" action="<%= request.getContextPath() %>/registrar">
                <div class="mb-3">
                    <label class="form-label">Correo electrónico</label>
                    <input type="email" name="correo" class="form-control" placeholder="correo@ejemplo.com" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Contraseña</label>
                    <input type="password" name="password" class="form-control" placeholder="Mínimo 6 caracteres" required minlength="6">
                </div>
                <div class="mb-4">
                    <label class="form-label">Confirmar contraseña</label>
                    <input type="password" name="confirmar" class="form-control" placeholder="Repite la contraseña" required minlength="6">
                </div>
                <button type="submit" class="btn btn-primary w-100 py-2">Crear cuenta</button>
            </form>
            <p class="help mt-4 mb-0">¿Ya tienes cuenta? <a href="login.jsp" class="fw-semibold text-decoration-none">Inicia sesión</a></p>
        </div>
    </div>
</main>

<%@ include file="WEB-INF/jspf/pie.jspf" %>
</body>
</html>
