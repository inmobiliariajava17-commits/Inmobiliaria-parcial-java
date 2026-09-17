<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.Map" %>
<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
    Map<String, Object> perfil = (Map<String, Object>) request.getAttribute("perfil");
    if (perfil == null) perfil = new java.util.HashMap<>();

    String valorNombres = perfil.get("nombres") == null ? "" : String.valueOf(perfil.get("nombres"));
    String valorApellidos = perfil.get("apellidos") == null ? "" : String.valueOf(perfil.get("apellidos"));
    String valorDocumento = perfil.get("documento") == null ? "" : String.valueOf(perfil.get("documento"));
    String valorTelefono = perfil.get("telefono") == null ? "" : String.valueOf(perfil.get("telefono"));
    String valorDireccion = perfil.get("direccion") == null ? "" : String.valueOf(perfil.get("direccion"));
    String valorFoto = perfil.get("fotoUrl") == null ? "" : String.valueOf(perfil.get("fotoUrl"));
    boolean tieneFoto = !valorFoto.trim().isEmpty();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mi perfil</title>
    <style>
        .perfil-grid { display: grid; grid-template-columns: minmax(280px, 360px) 1fr; gap: 24px; align-items: start; }
        .perfil-card { text-align: center; position: sticky; top: 20px; }
        .foto-perfil { width: 150px; height: 150px; border-radius: 50%; object-fit: cover; display: block; margin: 0 auto 16px; border: 4px solid #fff; box-shadow: 0 4px 18px rgba(0,0,0,.12); }
        .foto-placeholder { width: 150px; height: 150px; border-radius: 50%; margin: 0 auto 16px; display: flex; align-items: center; justify-content: center; background: #f1f3f5; color: #6c757d; font-size: 52px; font-weight: 600; }
        .dato-perfil { text-align: left; padding: 12px 0; border-bottom: 1px solid #eee; }
        .dato-perfil:last-child { border-bottom: 0; }
        .dato-label { font-size: .82rem; color: #6c757d; margin-bottom: 2px; }
        .dato-valor { font-weight: 500; word-break: break-word; }
        @media (max-width: 767px) {
            .perfil-grid { grid-template-columns: 1fr; }
            .perfil-card { position: static; }
        }
    </style>
</head>
<body>
<%@ include file="../../WEB-INF/jspf/cabecera.jspf" %>

<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header d-flex flex-column flex-md-row justify-content-between align-items-md-end gap-3">
            <div>
                <div class="eyebrow">Cuenta del cliente</div>
                <h1 class="page-title">Mi perfil</h1>
                <p class="page-subtitle">Completa tus datos y revisa cómo quedará tu información.</p>
            </div>
            <a href="<%= request.getContextPath() %>/paneles/cliente.jsp" class="btn btn-outline-secondary">Volver al panel</a>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if ("1".equals(request.getParameter("guardado"))) { %>
            <div class="alert alert-success">Los datos del perfil se guardaron correctamente.</div>
        <% } %>

        <div class="perfil-grid">
            <div class="surface-card perfil-card">
                <h2 class="section-title mb-3">Así se verá tu perfil</h2>

                <% if (tieneFoto) { %>
                    <img id="fotoVista" class="foto-perfil" src="<%= valorFoto %>" alt="Foto de perfil">
                <% } else { %>
                    <div id="fotoPlaceholder" class="foto-placeholder">👤</div>
                    <img id="fotoVista" class="foto-perfil" src="" alt="Foto de perfil" style="display:none;">
                <% } %>

                <h3 id="nombreVista" class="mb-1"><%= valorNombres.isEmpty() && valorApellidos.isEmpty() ? "Tu nombre" : valorNombres + " " + valorApellidos %></h3>
                <p id="documentoVista" class="text-muted mb-3"><%= valorDocumento.isEmpty() ? "Documento pendiente" : "Documento: " + valorDocumento %></p>

                <div class="dato-perfil">
                    <div class="dato-label">Teléfono</div>
                    <div id="telefonoVista" class="dato-valor"><%= valorTelefono.isEmpty() ? "No registrado" : valorTelefono %></div>
                </div>
                <div class="dato-perfil">
                    <div class="dato-label">Dirección</div>
                    <div id="direccionVista" class="dato-valor"><%= valorDireccion.isEmpty() ? "No registrada" : valorDireccion %></div>
                </div>
            </div>

            <div class="surface-card">
                <div class="mb-4">
                    <h2 class="section-title">Editar datos</h2>
                    <p class="text-muted mb-0">Los campos marcados con * son obligatorios.</p>
                </div>

                <form method="post" action="<%= request.getContextPath() %>/perfil" enctype="multipart/form-data">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label" for="nombres">Nombres *</label>
                            <input class="form-control" type="text" id="nombres" name="nombres" maxlength="100" required value="<%= valorNombres %>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="apellidos">Apellidos *</label>
                            <input class="form-control" type="text" id="apellidos" name="apellidos" maxlength="100" required value="<%= valorApellidos %>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="documento">Documento *</label>
                            <input class="form-control" type="text" id="documento" name="documento" maxlength="30" required value="<%= valorDocumento %>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="telefono">Teléfono</label>
                            <input class="form-control" type="text" id="telefono" name="telefono" maxlength="20" value="<%= valorTelefono %>">
                        </div>
                        <div class="col-12">
                            <label class="form-label" for="direccion">Dirección</label>
                            <input class="form-control" type="text" id="direccion" name="direccion" maxlength="200" value="<%= valorDireccion %>">
                        </div>
                        <div class="col-12">
                            <label class="form-label" for="foto">Foto de perfil</label>
                            <input class="form-control" type="file" id="foto" name="foto" accept="image/jpeg,image/png,image/gif,image/webp">
                            <div class="form-text">Selecciona una imagen desde tu computador. Máximo 2 MB.</div>
                            <% if (tieneFoto) { %>
                                <div class="form-check mt-2">
                                    <input class="form-check-input" type="checkbox" id="eliminarFoto" name="eliminarFoto" value="1">
                                    <label class="form-check-label" for="eliminarFoto">Eliminar foto actual</label>
                                </div>
                            <% } %>
                        </div>
                    </div>

                    <div class="d-flex flex-column flex-sm-row justify-content-end gap-2 mt-4">
                        <a href="<%= request.getContextPath() %>/paneles/cliente.jsp" class="btn btn-outline-secondary">Cancelar</a>
                        <button type="submit" class="btn btn-primary">Guardar cambios</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>

<script>
    const nombres = document.getElementById('nombres');
    const apellidos = document.getElementById('apellidos');
    const documento = document.getElementById('documento');
    const telefono = document.getElementById('telefono');
    const direccion = document.getElementById('direccion');
    const foto = document.getElementById('foto');
    const nombreVista = document.getElementById('nombreVista');
    const documentoVista = document.getElementById('documentoVista');
    const telefonoVista = document.getElementById('telefonoVista');
    const direccionVista = document.getElementById('direccionVista');
    const fotoVista = document.getElementById('fotoVista');
    const fotoPlaceholder = document.getElementById('fotoPlaceholder');

    function actualizarVista() {
        const nombreCompleto = (nombres.value.trim() + ' ' + apellidos.value.trim()).trim();
        nombreVista.textContent = nombreCompleto || 'Tu nombre';
        documentoVista.textContent = documento.value.trim() ? 'Documento: ' + documento.value.trim() : 'Documento pendiente';
        telefonoVista.textContent = telefono.value.trim() || 'No registrado';
        direccionVista.textContent = direccion.value.trim() || 'No registrada';
    }

    [nombres, apellidos, documento, telefono, direccion].forEach(campo => {
        campo.addEventListener('input', actualizarVista);
    });

    const eliminarFoto = document.getElementById('eliminarFoto');
    if (eliminarFoto) {
        eliminarFoto.addEventListener('change', function () {
            if (this.checked) {
                foto.value = '';
                fotoVista.src = '';
                fotoVista.style.display = 'none';
                if (fotoPlaceholder) fotoPlaceholder.style.display = 'flex';
            }
        });
    }

    foto.addEventListener('change', function () {
        const archivo = this.files && this.files[0];
        if (!archivo) return;

        if (archivo.size > 2 * 1024 * 1024) {
            alert('La imagen no puede superar los 2 MB.');
            this.value = '';
            return;
        }

        if (!archivo.type.startsWith('image/')) {
            alert('Selecciona un archivo de imagen.');
            this.value = '';
            return;
        }

        const lector = new FileReader();
        lector.onload = function (e) {
            fotoVista.src = e.target.result;
            fotoVista.style.display = 'block';
            if (fotoPlaceholder) fotoPlaceholder.style.display = 'none';
        };
        lector.readAsDataURL(archivo);
    });
</script>

<%@ include file="../../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
