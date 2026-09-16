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

<div class="container mt-5 mb-5" style="max-width: 450px;">
    <h2 class="mb-4">Crear cuenta</h2>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
    <% } %>

    <form method="post" action="<%= request.getContextPath() %>/registrar">
        <div class="mb-3">
            <label class="form-label">Tipo de cuenta</label>
            <select name="tipoCuenta" id="tipoCuenta" class="form-select" required onchange="mostrarDatosInmobiliaria()">
                <option value="CLIENTE">Cliente</option>
                <option value="INMOBILIARIA">Inmobiliaria</option>
            </select>
        </div>

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

        <div id="datosInmobiliaria" style="display: none;">
            <hr>
            <h5 class="mb-3">Datos de la inmobiliaria</h5>

            <div class="mb-3">
                <label class="form-label">Nombre de la agencia</label>
                <input type="text" name="nombreAgencia" id="nombreAgencia" class="form-control">
            </div>

            <div class="mb-3">
                <label class="form-label">NIT</label>
                <input type="text" name="nit" id="nit" class="form-control">
            </div>
        </div>

        <button type="submit" class="btn btn-primary w-100">Registrarme</button>
    </form>

    <p class="mt-3">¿Ya tienes cuenta? <a href="login.jsp">Inicia sesión</a></p>
</div>

<script>
    function mostrarDatosInmobiliaria() {
        const tipo = document.getElementById("tipoCuenta").value;
        const datos = document.getElementById("datosInmobiliaria");
        const nombre = document.getElementById("nombreAgencia");
        const nit = document.getElementById("nit");

        if (tipo === "INMOBILIARIA") {
            datos.style.display = "block";
            nombre.required = true;
            nit.required = true;
        } else {
            datos.style.display = "none";
            nombre.required = false;
            nit.required = false;
        }
    }
</script>

<%@ include file="WEB-INF/jspf/pie.jspf" %>
</body>
</html>
