<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");

    List<Map<String, Object>> propiedadesCiudad =
            (List<Map<String, Object>>) request.getAttribute("propiedadesCiudad");
    List<Map<String, Object>> citasEstado =
            (List<Map<String, Object>>) request.getAttribute("citasEstado");
    List<Map<String, Object>> solicitudesInmobiliaria =
            (List<Map<String, Object>>) request.getAttribute("solicitudesInmobiliaria");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Reportes</title>
</head>
<body>
<%@ include file="../../WEB-INF/jspf/cabecera.jspf" %>

<main class="page-wrap">
    <div class="container app-container">
        <div class="page-header d-flex flex-column flex-md-row justify-content-between align-items-md-end gap-3">
            <div>
                <div class="eyebrow">Administración</div>
                <h1 class="page-title">Reportes</h1>
                <p class="page-subtitle">Resumen de la información registrada en el sistema.</p>
            </div>
            <a href="<%= request.getContextPath() %>/paneles/administrador.jsp"
               class="btn btn-outline-primary btn-sm rounded-pill">Volver al panel</a>
        </div>

        <div class="row g-4">
            <div class="col-lg-4">
                <div class="table-card h-100">
                    <div class="p-4">
                        <h2 class="h5 fw-bold mb-1">Propiedades por ciudad</h2>
                        <p class="text-muted small mb-0">Propiedades disponibles agrupadas por ciudad.</p>
                    </div>
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead>
                            <tr>
                                <th>Ciudad</th>
                                <th class="text-end">Total</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% if (propiedadesCiudad == null || propiedadesCiudad.isEmpty()) { %>
                                <tr><td colspan="2" class="text-center py-4">No hay datos.</td></tr>
                            <% } else { %>
                                <% for (Map<String, Object> fila : propiedadesCiudad) { %>
                                    <tr>
                                        <td><%= fila.get("nombre") %></td>
                                        <td class="text-end"><strong><%= fila.get("total") %></strong></td>
                                    </tr>
                                <% } %>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="table-card h-100">
                    <div class="p-4">
                        <h2 class="h5 fw-bold mb-1">Citas por estado</h2>
                        <p class="text-muted small mb-0">Cantidad de citas según su estado.</p>
                    </div>
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead>
                            <tr>
                                <th>Estado</th>
                                <th class="text-end">Total</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% if (citasEstado == null || citasEstado.isEmpty()) { %>
                                <tr><td colspan="2" class="text-center py-4">No hay datos.</td></tr>
                            <% } else { %>
                                <% for (Map<String, Object> fila : citasEstado) { %>
                                    <tr>
                                        <td><%= fila.get("nombre") %></td>
                                        <td class="text-end"><strong><%= fila.get("total") %></strong></td>
                                    </tr>
                                <% } %>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="table-card h-100">
                    <div class="p-4">
                        <h2 class="h5 fw-bold mb-1">Solicitudes por inmobiliaria</h2>
                        <p class="text-muted small mb-0">Solicitudes agrupadas por inmobiliaria.</p>
                    </div>
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead>
                            <tr>
                                <th>Inmobiliaria</th>
                                <th class="text-end">Total</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% if (solicitudesInmobiliaria == null || solicitudesInmobiliaria.isEmpty()) { %>
                                <tr><td colspan="2" class="text-center py-4">No hay datos.</td></tr>
                            <% } else { %>
                                <% for (Map<String, Object> fila : solicitudesInmobiliaria) { %>
                                    <tr>
                                        <td><%= fila.get("nombre") %></td>
                                        <td class="text-end"><strong><%= fila.get("total") %></strong></td>
                                    </tr>
                                <% } %>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<%@ include file="../../WEB-INF/jspf/pie.jspf" %>
</body>
</html>
