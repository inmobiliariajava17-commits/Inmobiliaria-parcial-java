<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
    List<Map<String, Object>> documentos = (List<Map<String, Object>>) request.getAttribute("documentos");
    Object idSolicitudObj = request.getAttribute("idSolicitud");
    String estadoSolicitud = request.getAttribute("estadoSolicitud") == null ? "" : String.valueOf(request.getAttribute("estadoSolicitud"));
    String tipoSolicitud = request.getAttribute("tipoSolicitud") == null ? "" : String.valueOf(request.getAttribute("tipoSolicitud"));
    String idSolicitud = idSolicitudObj == null ? request.getParameter("idSolicitud") : String.valueOf(idSolicitudObj);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Documentos de solicitud - Inmobiliaria</title>
</head>
<body>
<%@ include file="../../WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header d-flex flex-column flex-md-row justify-content-between gap-3">
            <div>
                <div class="eyebrow">Solicitud #<%= idSolicitud %></div>
                <h1 class="page-title">Documentos</h1>
                <p class="page-subtitle">Revisa la documentación de tu solicitud y envía el trámite cuando todos los documentos requeridos estén guardados.</p>
            </div>
            <a href="<%= request.getContextPath() %>/solicitudes" class="btn btn-outline-primary align-self-start">Volver a solicitudes</a>
        </div>

        <% if ("subido".equals(request.getParameter("mensaje"))) { %>
            <div class="alert alert-success">El documento fue cargado correctamente.</div>
        <% } else if ("eliminado".equals(request.getParameter("mensaje"))) { %>
            <div class="alert alert-success">El documento fue eliminado.</div>
        <% } else if ("archivo".equals(request.getParameter("error"))) { %>
            <div class="alert alert-warning">Selecciona un archivo antes de cargarlo.</div>
        <% } else if ("formato".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">Solo se permiten archivos PDF, JPG, JPEG o PNG.</div>
        <% } else if ("incompletos".equals(request.getParameter("error"))) { %>
            <div class="alert alert-warning">Faltan documentos requeridos. Revísalos antes de enviar la solicitud.</div>
        <% } else if ("no-disponible".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">La propiedad ya no está disponible para continuar con la solicitud.</div>
        <% } else if (request.getAttribute("error") != null || "guardar-documento".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">No se pudo procesar el documento.</div>
        <% } %>

        <% if ("BORRADOR".equals(estadoSolicitud)) { %>
            <div class="surface-card mb-4">
                <h2 class="h5 fw-bold mb-2">Solicitud en borrador</h2>
                <p class="text-muted">Los documentos ya están guardados. Cuando todos los requisitos estén completos puedes enviar la solicitud para revisión.</p>
                <form method="post" action="<%= request.getContextPath() %>/solicitudes">
                    <input type="hidden" name="accion" value="enviar">
                    <input type="hidden" name="idSolicitud" value="<%= idSolicitud %>">
                    <button type="submit" class="btn btn-primary">Enviar solicitud a revisión</button>
                </form>
            </div>
        <% } %>

        <div class="surface-card mb-4">
            <h2 class="h5 fw-bold mb-2">Cargar documento adicional</h2>
            <p class="text-muted">Puedes agregar documentación adicional. Los documentos requeridos ya guardados aparecen en la lista inferior.</p>
            <form method="post" action="<%= request.getContextPath() %>/documentos-solicitud" enctype="multipart/form-data" class="row g-3 align-items-end">
                <input type="hidden" name="accion" value="subir">
                <input type="hidden" name="idSolicitud" value="<%= idSolicitud %>">
                <div class="col-md-8">
                    <label for="archivo" class="form-label">Documento</label>
                    <input type="file" id="archivo" name="archivo" class="form-control" accept=".pdf,.jpg,.jpeg,.png" required>
                </div>
                <div class="col-md-4">
                    <button type="submit" class="btn btn-primary w-100">Cargar documento</button>
                </div>
            </form>
        </div>

        <% if (documentos == null || documentos.isEmpty()) { %>
            <div class="empty-state surface-card">
                <span class="material-symbols-outlined">folder_open</span>
                <h2 class="h5 fw-bold mt-2">No hay documentos cargados</h2>
                <p class="text-muted mb-0">Los documentos que enviaste al crear la solicitud aparecerán aquí. También puedes agregar documentos adicionales si la inmobiliaria los solicita.</p>
            </div>
        <% } else { %>
            <div class="row g-4">
                <% for (Map<String, Object> documento : documentos) { %>
                    <div class="col-md-6 col-xl-4">
                        <div class="surface-card h-100 d-flex flex-column">
                            <div class="d-flex align-items-center gap-2 mb-2">
                                <span class="material-symbols-outlined">description</span>
                                <strong><%= documento.get("tipo") == null ? "Documento" : documento.get("tipo") %></strong>
                            </div>
                            <p class="mb-1"><%= documento.get("nombre") == null ? "Documento cargado" : documento.get("nombre") %></p>
                            <p class="small text-muted mb-3">Cargado: <%= documento.get("fecha") %></p>
                            <div class="mt-auto d-flex gap-2">
                                <a href="<%= documento.get("url") %>" target="_blank" rel="noopener" class="btn btn-outline-primary flex-grow-1">Ver documento</a>
                                <form method="post" action="<%= request.getContextPath() %>/documentos-solicitud">
                                    <input type="hidden" name="accion" value="eliminar">
                                    <input type="hidden" name="idSolicitud" value="<%= idSolicitud %>">
                                    <input type="hidden" name="idDocumento" value="<%= documento.get("id") %>">
                                    <button type="submit" class="btn btn-outline-danger">Eliminar</button>
                                </form>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>
</main>
<%@ include file="../../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
