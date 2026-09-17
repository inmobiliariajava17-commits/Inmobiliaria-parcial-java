<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map, java.text.NumberFormat, java.util.Locale" %>
<%
    Map<String,Object> propiedad = (Map<String,Object>) request.getAttribute("propiedad");
    NumberFormat formatoPrecio = NumberFormat.getNumberInstance(new Locale("es", "CO"));
    formatoPrecio.setMaximumFractionDigits(0);
    formatoPrecio.setMinimumFractionDigits(0);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Editar Inmueble</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background:#f6f8fb; }
        .form-card { border:0; border-radius:18px; box-shadow:0 4px 18px rgba(0,0,0,.06); }
        .page-title { color:#1e3a8a; font-weight:700; }
    </style>
</head>
<body>
<%@ include file="../../WEB-INF/jspf/cabecera.jspf" %>

<main class="container py-4">
    <div class="mb-4">
        <a href="<%= request.getContextPath() %>/propiedades" class="text-decoration-none">← Mis propiedades</a>
        <h1 class="page-title mt-2">Editar Inmueble</h1>
        <p class="text-secondary">Actualiza la información de una propiedad registrada por tu inmobiliaria.</p>
    </div>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
    <% } %>

    <div class="card form-card">
        <div class="card-body p-4 p-md-5">
            <form method="post" action="<%= request.getContextPath() %>/propiedades" id="form-editar-propiedad">

                <input type="hidden" name="accion" value="editar">
                <input type="hidden" name="idPropiedad" value="<%= propiedad.get("id") %>">

                <%
                    Object selectedCiudad = propiedad.get("idCiudad");
                    Object selectedTipo = propiedad.get("idTipo");
                %>

                <div class="row g-4">
                    <div class="col-md-8">
                        <label class="form-label fw-semibold">Título de la propiedad *</label>
                        <input type="text" name="titulo" class="form-control" maxlength="150" required
                               value="<%= propiedad.get("titulo") %>">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Matrícula inmobiliaria *</label>
                        <input type="text" name="matricula" class="form-control" maxlength="50" required
                               value="<%= propiedad.get("matricula") %>">
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Ciudad *</label>
                        <select name="idCiudad" class="form-select" required>
                            <%
                                List<String[]> ciudades = (List<String[]>) request.getAttribute("ciudades");
                                if (ciudades != null) {
                                    for (String[] ciudad : ciudades) {
                            %>
                            <option value="<%= ciudad[0] %>"
                                <%= String.valueOf(selectedCiudad).equals(ciudad[0]) ? "selected" : "" %>>
                                <%= ciudad[1] %>
                            </option>
                            <% }} %>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Tipo de propiedad *</label>
                        <select name="idTipo" class="form-select" required>
                            <%
                                List<String[]> tipos = (List<String[]>) request.getAttribute("tipos");
                                if (tipos != null) {
                                    for (String[] tipo : tipos) {
                            %>
                            <option value="<%= tipo[0] %>"
                                <%= String.valueOf(selectedTipo).equals(tipo[0]) ? "selected" : "" %>>
                                <%= tipo[1] %>
                            </option>
                            <% }} %>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Precio (COP) *</label>
                        <input type="text" name="precio" id="precio" class="form-control" inputmode="numeric" autocomplete="off" required
                               value="<%= formatoPrecio.format(propiedad.get("precio")) %>">
                        <div class="form-text">Escribe el valor en pesos. Los puntos se agregan automáticamente.</div>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Estado</label>
                        <select name="estado" class="form-select">
                            <option value="DISPONIBLE" <%= "DISPONIBLE".equals(propiedad.get("estado")) ? "selected" : "" %>>Disponible</option>
                            <option value="ARRENDADA" <%= "ARRENDADA".equals(propiedad.get("estado")) ? "selected" : "" %>>Arrendada</option>
                            <option value="VENDIDA" <%= "VENDIDA".equals(propiedad.get("estado")) ? "selected" : "" %>>Vendida</option>
                            <option value="INACTIVA" <%= "INACTIVA".equals(propiedad.get("estado")) ? "selected" : "" %>>Inactiva</option>
                        </select>
                    </div>

                    <div class="col-12">
                        <label class="form-label fw-semibold">Descripción</label>
                        <textarea name="descripcion" class="form-control" rows="5" maxlength="2000"><%= propiedad.get("descripcion") == null ? "" : propiedad.get("descripcion") %></textarea>
                    </div>
                </div>

                <div class="d-flex flex-column flex-sm-row justify-content-end gap-2 mt-4">
                    <a href="<%= request.getContextPath() %>/propiedades" class="btn btn-outline-secondary">Cancelar</a>
                    <a href="<%= request.getContextPath() %>/imagenes-propiedad?id=<%= propiedad.get("id") %>" class="btn btn-outline-primary">Imágenes y características</a>
                    <button type="submit" class="btn btn-primary">Guardar cambios</button>
                </div>
            </form>
        </div>
    </div>
</main>

<%@ include file="../../WEB-INF/jspf/pie.jspf" %>

<script>
(function () {
    const input = document.getElementById('precio');
    const form = document.getElementById('form-editar-propiedad');
    if (!input || !form) return;

    function formatear(valor) {
        const digitos = valor.replace(/\D/g, '');
        if (!digitos) return '';
        return Number(digitos).toLocaleString('es-CO');
    }

    input.addEventListener('input', function () {
        const inicio = this.selectionStart;
        const antes = this.value.length;
        this.value = formatear(this.value);
        const diferencia = this.value.length - antes;
        const nuevaPos = Math.max(0, (inicio || 0) + diferencia);
        this.setSelectionRange(nuevaPos, nuevaPos);
    });

    form.addEventListener('submit', function () {
        input.value = input.value.replace(/\./g, '').replace(/,/g, '');
    });
})();
</script>
</body>
</html>
