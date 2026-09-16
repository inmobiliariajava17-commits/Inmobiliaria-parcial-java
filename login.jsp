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
    <title>Ingresar - Inmobiliaria</title>
</head>
<body>
<%@ include file="WEB-INF/jspf/cabecera.jspf" %>

<main class="auth-page">
    <div class="auth-card row g-0">
        <div class="col-lg-5 auth-side">
            <div class="eyebrow text-white-50">Acceso seguro</div>
            <h1>Bienvenido de nuevo</h1>
            <p>Ingresa para acceder a las funciones que corresponden a tus roles dentro del sistema inmobiliario.</p>
            <div class="auth-side-item"><span class="material-symbols-outlined">verified_user</span><span>Contraseñas protegidas mediante BCrypt.</span></div>
            <div class="auth-side-item"><span class="material-symbols-outlined">admin_panel_settings</span><span>Control de acceso por rol desde el servidor.</span></div>
        </div>
        <div class="col-lg-7 auth-form">
            <h2>Iniciar sesión</h2>
            <p class="help mb-4">Utiliza el correo y la contraseña de tu cuenta.</p>

            <% if (request.getAttribute("mensaje") != null) { %>
                <div class="alert alert-success"><%= request.getAttribute("mensaje") %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
            <% } %>
            <% if ("sesion".equals(request.getParameter("error"))) { %>
                <div class="alert alert-warning">Debes iniciar sesión para continuar.</div>
            <% } %>

            <form method="post" action="<%= request.getContextPath() %>/ingresar">
                <div class="mb-3">
                    <label class="form-label">Correo electrónico</label>
                    <input type="email" name="correo" class="form-control" placeholder="correo@ejemplo.com" required>
                </div>
                <div class="mb-4">
                    <label class="form-label">Contraseña</label>
                    <input type="password" name="password" class="form-control" placeholder="••••••••" required>
                </div>
                <button type="submit" class="btn btn-primary w-100 py-2">Ingresar</button>
            </form>
            <p class="help mt-4 mb-0">¿No tienes cuenta? <a href="registro.jsp" class="fw-semibold text-decoration-none">Regístrate aquí</a></p>
        </div>
    </div>
</main>

<%@ include file="WEB-INF/jspf/pie.jspf" %>
</body>
</html>
