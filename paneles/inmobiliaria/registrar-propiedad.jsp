<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Registrar Nueva Propiedad</title>
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
        <a href="<%= request.getContextPath() %>/propiedades" class="text-decoration-none">â† Mis propiedades</a>
        <h1 class="page-title mt-2">Registrar Nueva Propiedad</h1>
        <p class="text-secondary">Diligencia los datos bÃ¡sicos del inmueble para publicarlo en el catÃ¡logo.</p>
    </div>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
    <% } %>

    <div class="card form-card">
        <div class="card-body p-4 p-md-5">
            <form method="post" action="<%= request.getContextPath() %>/propiedades">

                <input type="hidden" name="accion" value="crear">

                <div class="row g-4">
                    <div class="col-md-8">
                        <label class="form-label fw-semibold">TÃ­tulo de la propiedad *</label>
                        <input type="text" name="titulo" class="form-control" maxlength="150" required
                               placeholder="Ej. Casa moderna en Floridablanca">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label fw-semibold">MatrÃ­cula inmobiliaria *</label>
                        <input type="text" name="matricula" class="form-control" maxlength="50" required
                               placeholder="Ej. MI-000011">
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Ciudad *</label>
                        <select name="idCiudad" class="form-select" required>
                            <option value="">Seleccione...</option>
                            <%
                                List<String[]> ciudades = (List<String[]>) request.getAttribute("ciudades");
                                if (ciudades != null) {
                                    for (String[] ciudad : ciudades) {
                            %>
                            <option value="<%= ciudad[0] %>"><%= ciudad[1] %></option>
                            <% }} %>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Tipo de propiedad *</label>
                        <select name="idTipo" class="form-select" required>
                            <option value="">Seleccione...</option>
                            <%
                                List<String[]> tipos = (List<String[]>) request.getAttribute("tipos");
                                if (tipos != null) {
                                    for (String[] tipo : tipos) {
                            %>
                            <option value="<%= tipo[0] %>"><%= tipo[1] %></option>
                            <% }} %>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Precio (COP) *</label>
                        <input type="number" name="precio" class="form-control" min="0" step="0.01" required>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Estado</label>
                        <select name="estado" class="form-select">
                            <option value="DISPONIBLE">Disponible</option>
                            <option value="ARRENDADA">Arrendada</option>
                            <option value="VENDIDA">Vendida</option>
                        </select>
                    </div>

                    <div class="col-12">
                        <label class="form-label fw-semibold">DescripciÃ³n</label>
                        <textarea name="descripcion" class="form-control" rows="5" maxlength="2000"
                                  placeholder="Describe el inmueble, su ubicaciÃ³n y caracterÃ­sticas principales."></textarea>
                    </div>
                </div>

                <div class="d-flex flex-column flex-sm-row justify-content-end gap-2 mt-4">
                    <a href="<%= request.getContextPath() %>/propiedades" class="btn btn-outline-secondary">Cancelar</a>
                    <button type="submit" class="btn btn-primary">Guardar propiedad</button>
                </div>
            </form>
        </div>
    </div>
</main>

<%@ include file="../../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
