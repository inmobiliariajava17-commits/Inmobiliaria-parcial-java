<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    if (!tieneRol(session, "INMOBILIARIA")) {
        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
        return;
    }
%>

<%
    Map<String,Object> propiedad = (Map<String,Object>) request.getAttribute("propiedad");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Gestionar propiedad</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background:#f6f8fb; }
        .card-box { border:0; border-radius:18px; box-shadow:0 4px 18px rgba(0,0,0,.06); }
        .page-title { color:#1e3a8a; font-weight:700; }
        .property-image { height:190px; width:100%; object-fit:cover; border-radius:12px; background:#eef2f7; }
    </style>
</head>
<body>
<%@ include file="../../WEB-INF/jspf/cabecera.jspf" %>

<main class="container py-4">
    <% if (propiedad == null || propiedad.isEmpty()) { %>
        <div class="alert alert-danger">No fue posible cargar la informaci&#243;n de la propiedad. Intenta nuevamente o vuelve a tu cartera.</div>
        <a href="<%= request.getContextPath() %>/acciones/propiedades.jsp" class="btn btn-primary">Volver a mis propiedades</a>
    <% } else { %>
    <div class="mb-4">
        <a href="<%= request.getContextPath() %>/acciones/propiedades.jsp" class="text-decoration-none">&#8592; Mis propiedades</a>
        <h1 class="page-title mt-2">Gestionar propiedad</h1>
        <p class="text-secondary mb-0"><strong><%= propiedad.get("titulo") %></strong> &#183; Matr&#237;cula <%= propiedad.get("matricula") %></p>
    </div>

    <% if (request.getParameter("mensaje") != null) { %>
        <div class="alert alert-success">
            <% if ("subir".equals(request.getParameter("mensaje"))) { %>Imagen agregada correctamente.
            <% } else if ("eliminar".equals(request.getParameter("mensaje"))) { %>Imagen eliminada correctamente.
            <% } else { %>Caracter&#237;sticas guardadas correctamente.<% } %>
        </div>
    <% } %>
    <% if (request.getParameter("error") != null) { %>
        <div class="alert alert-danger">No se pudo completar la operaci&#243;n. Verifica los datos e int&#233;ntalo nuevamente.</div>
    <% } %>
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
    <% } %>

    <div class="row g-4">
        <div class="col-lg-7">
            <div class="card card-box">
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <div>
                            <h2 class="h4 mb-1">Galer&#237;a de im&#225;genes</h2>
                            <p class="text-secondary small mb-0">Agrega las im&#225;genes que aparecer&#225;n en el detalle del inmueble.</p>
                        </div>
                    </div>

                    <form method="post" enctype="multipart/form-data" action="<%= request.getContextPath() %>/acciones/imagenes-propiedad.jsp" class="mb-4">
                        <input type="hidden" name="accion" value="subir">
                        <input type="hidden" name="idPropiedad" value="<%= propiedad.get("id") %>">
                        <div class="input-group">
                            <input type="file" name="imagen" class="form-control" accept="image/jpeg,image/png,image/gif,image/webp" required>
                            <button class="btn btn-primary">Agregar imagen</button>
                        </div>
                        <div class="form-text">JPG, JPEG, PNG, GIF o WEBP. M&#225;ximo 5 MB.</div>
                    </form>

                    <div class="row g-3">
                    <% List<Map<String,Object>> imagenes = (List<Map<String,Object>>) request.getAttribute("imagenes"); %>
                    <% if (imagenes == null || imagenes.isEmpty()) { %>
                        <div class="col-12 text-center py-4 text-secondary">Todav&#237;a no hay im&#225;genes para esta propiedad.</div>
                    <% } else { for (Map<String,Object> imagen : imagenes) { %>
                        <div class="col-md-6">
                            <div class="border rounded-3 p-2">
                                <img src="<%= imagen.get("url") %>" class="property-image" alt="Imagen de la propiedad">
                                <% if (Boolean.TRUE.equals(imagen.get("principal"))) { %>
                                    <div class="mt-2"><span class="badge bg-success">&#9733; Imagen principal</span></div>
                                <% } else { %>
                                    <form method="post" action="<%= request.getContextPath() %>/acciones/imagenes-propiedad.jsp" class="mt-2">
                                        <input type="hidden" name="accion" value="principal">
                                        <input type="hidden" name="idPropiedad" value="<%= propiedad.get("id") %>">
                                        <input type="hidden" name="idImagen" value="<%= imagen.get("id") %>">
                                        <button class="btn btn-outline-success btn-sm w-100">&#9733; Establecer como principal</button>
                                    </form>
                                <% } %>
                                <form method="post" action="<%= request.getContextPath() %>/acciones/imagenes-propiedad.jsp" class="mt-2" onsubmit="return confirm('&#191;Eliminar esta imagen?');">
                                    <input type="hidden" name="accion" value="eliminar">
                                    <input type="hidden" name="idPropiedad" value="<%= propiedad.get("id") %>">
                                    <input type="hidden" name="idImagen" value="<%= imagen.get("id") %>">
                                    <button class="btn btn-outline-danger btn-sm w-100">Eliminar imagen</button>
                                </form>
                            </div>
                        </div>
                    <% }} %>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-lg-5">
            <div class="card card-box">
                <div class="card-body p-4">
                    <h2 class="h4 mb-1">Caracter&#237;sticas</h2>
                    <p class="text-secondary small mb-3">Selecciona las caracter&#237;sticas y, cuando corresponda, indica la cantidad.</p>

                    <form method="post" action="<%= request.getContextPath() %>/acciones/caracteristicas-propiedad.jsp">
                        <input type="hidden" name="idPropiedad" value="<%= propiedad.get("id") %>">
                        <% List<Map<String,Object>> disponibles = (List<Map<String,Object>>) request.getAttribute("caracteristicasDisponibles"); %>
                        <% if (disponibles == null || disponibles.isEmpty()) { %>
                            <div class="alert alert-light border">No hay caracter&#237;sticas creadas en el cat&#225;logo.</div>
                        <% } else { for (Map<String,Object> c : disponibles) {
                            int cantidad = ((Number)c.get("cantidad")).intValue();
                        %>
                            <div class="border rounded-3 p-3 mb-2">
                                <div class="d-flex align-items-center gap-2">
                                    <input class="form-check-input mt-0" type="checkbox" name="caracteristica" value="<%= c.get("id") %>" id="car_<%= c.get("id") %>" <%= cantidad > 0 ? "checked" : "" %>>
                                    <label class="form-check-label flex-grow-1" for="car_<%= c.get("id") %>"><%= c.get("nombre") %></label>
                                    <input type="number" min="1" name="cantidad_<%= c.get("id") %>" value="<%= cantidad > 0 ? cantidad : 1 %>" class="form-control" style="width:80px" title="Cantidad">
                                </div>
                            </div>
                        <% }} %>

                        <button class="btn btn-primary w-100 mt-2">Guardar caracter&#237;sticas</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <% } %>
</main>

<%@ include file="../../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
