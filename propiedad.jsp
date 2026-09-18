<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.text.NumberFormat, java.util.Locale" %>
<%
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");
    NumberFormat formatoPrecio = NumberFormat.getNumberInstance(new Locale("es", "CO"));
    formatoPrecio.setMaximumFractionDigits(0);
    formatoPrecio.setMinimumFractionDigits(0);
    Map<String, Object> propiedad = (Map<String, Object>) request.getAttribute("propiedad");
    List<String> imagenes = (List<String>) request.getAttribute("imagenes");
    List<Map<String, Object>> caracteristicas = (List<Map<String, Object>>) request.getAttribute("caracteristicas");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Detalle de propiedad - Inmobiliaria</title>
</head>
<body>
<%@ include file="WEB-INF/jspf/cabecera.jspf" %>
<main class="page-wrap">
    <div class="container app-container">
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } else if (propiedad != null) { %>
            <div class="page-header d-flex flex-column flex-md-row justify-content-between gap-3">
                <div>
                    <div class="eyebrow">Detalle de propiedad</div>
                    <h1 class="page-title"><%= propiedad.get("titulo") %></h1>
                    <p class="page-subtitle"><%= propiedad.get("tipo") %> &#183; <%= propiedad.get("ciudad") %> &#183; Publicada por <%= propiedad.get("agencia") %></p>
                </div>
                <a href="<%= request.getContextPath() %>/acciones/buscar.jsp" class="btn btn-outline-primary align-self-start">Volver al cat&#225;logo</a>
            </div>

            <% if ("agregado".equals(request.getParameter("favorito"))) { %>
                <div class="alert alert-success">Propiedad agregada a favoritos.</div>
            <% } else if ("quitado".equals(request.getParameter("favorito"))) { %>
                <div class="alert alert-success">Propiedad retirada de favoritos.</div>
            <% } %>

            <div class="row g-4">
                <div class="col-lg-7">
                    <div class="surface-card property-gallery">
                        <% if (imagenes != null && !imagenes.isEmpty()) { %>
                            <div class="row g-2">
                                <% for (String imagen : imagenes) { %>
                                    <div class="col-12 col-md-6">
                                        <img src="<%= imagen %>" alt="Imagen de <%= propiedad.get("titulo") %>" class="property-detail-image">
                                    </div>
                                <% } %>
                            </div>
                        <% } else { %>
                            <div class="property-detail-placeholder">
                                <span class="material-symbols-outlined">home_work</span>
                                <span>Esta propiedad todav&#237;a no tiene im&#225;genes registradas.</span>
                            </div>
                        <% } %>
                    </div>
                </div>

                <div class="col-lg-5">
                    <div class="surface-card h-100">
                        <div class="property-card-top mb-3">
                            <span class="property-type"><%= propiedad.get("tipo") %></span>
                            <span class="property-status status-available"><%= propiedad.get("estado") %></span>
                        </div>
                        <div class="property-price property-detail-price">$<%= formatoPrecio.format(propiedad.get("precio")) %></div>
                        <p class="property-detail-description"><%= propiedad.get("descripcion") == null || propiedad.get("descripcion").toString().isBlank() ? "Sin descripción." : propiedad.get("descripcion") %></p>

                        <div class="detail-list">
                            <div><span>Ciudad</span><strong><%= propiedad.get("ciudad") %></strong></div>
                            <div><span>Tipo</span><strong><%= propiedad.get("tipo") %></strong></div>
                            <div><span>Inmobiliaria</span><strong><%= propiedad.get("agencia") %></strong></div>
                            <div><span>Matr&#237;cula</span><strong><%= propiedad.get("matricula") %></strong></div>
                        </div>

                        <div class="d-grid gap-2 mt-4">
                            <%
                                boolean esCliente = false;
                                boolean esFavorito = false;
                                Object rolesObj = session.getAttribute("roles");
                                if (rolesObj instanceof java.util.List) {
                                    esCliente = ((java.util.List<?>) rolesObj).contains("CLIENTE");
                                }
                                if (esCliente && request.getAttribute("esFavorito") != null) {
                                    esFavorito = Boolean.TRUE.equals(request.getAttribute("esFavorito"));
                                }
                            %>
                            <% if (esCliente) { %>
                                <form method="post" action="<%= request.getContextPath() %>/acciones/favoritos.jsp">
                                    <input type="hidden" name="idPropiedad" value="<%= propiedad.get("id") %>">
                                    <input type="hidden" name="accion" value="<%= esFavorito ? "quitar" : "agregar" %>">
                                    <button type="submit" class="btn <%= esFavorito ? "btn-outline-danger" : "btn-primary" %> w-100">
                                        <span class="material-symbols-outlined align-middle" style="font-size:18px"><%= esFavorito ? "favorite" : "favorite_border" %></span>
                                        <%= esFavorito ? "Quitar de favoritos" : "Agregar a favoritos" %>
                                    </button>
                                </form>
                                <a href="<%= request.getContextPath() %>/acciones/detalle-propiedad.jsp?id=<%= propiedad.get("id") %>&nueva=<%= propiedad.get("id") %>" class="btn btn-primary">Agendar visita</a>
                                <a href="#solicitud" id="btnIniciarSolicitud" class="btn btn-outline-primary">Iniciar solicitud</a>
                                <a href="<%= request.getContextPath() %>/paneles/cliente.jsp" class="btn btn-outline-primary">Ir a mi panel</a>
                            <% } else if (session.getAttribute("idUsuario") != null) { %>
                                <a href="<%= request.getContextPath() %>/paneles/cliente.jsp" class="btn btn-primary">Ir a mi panel</a>
                            <% } else { %>
                                <a href="<%= request.getContextPath() %>/login.jsp" class="btn btn-primary">Ingresar para continuar</a>
                                <a href="<%= request.getContextPath() %>/registro.jsp" class="btn btn-outline-primary">Crear una cuenta</a>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>

            <% if ("tipo".equals(request.getParameter("solicitud"))) { %>
                <div class="alert alert-danger">Selecciona un tipo de solicitud v&#225;lido: compra o arriendo.</div>
            <% } else if ("existente".equals(request.getParameter("solicitud"))) { %>
                <div class="alert alert-warning">Ya tienes una solicitud activa para esta propiedad.</div>
            <% } else if ("no-disponible".equals(request.getParameter("solicitud"))) { %>
                <div class="alert alert-danger">Esta propiedad ya no est&#225; disponible para iniciar una solicitud.</div>
            <% } %>

            <% if ("fecha".equals(request.getParameter("cita"))) { %>
                <div class="alert alert-danger">La fecha y hora seleccionadas no son v&#225;lidas.</div>
            <% } else if ("pasada".equals(request.getParameter("cita"))) { %>
                <div class="alert alert-danger">La visita debe programarse para una fecha y hora futuras.</div>
            <% } else if ("horario".equals(request.getParameter("cita"))) { %>
                <div class="alert alert-danger">Selecciona uno de los horarios disponibles, cada 45 minutos entre las 8:00 a. m. y las 5:45 p. m.</div>
            <% } else if ("no-disponible".equals(request.getParameter("cita"))) { %>
                <div class="alert alert-danger">Esta propiedad ya no est&#225; disponible para agendar visitas.</div>
            <% } %>

            <% if (esCliente) { %>
                <% String estadoSolicitud = request.getParameter("solicitud"); %>
                <div class="surface-card mt-4<%= (estadoSolicitud == null ? " d-none" : "") %>" id="solicitud">
                    <div class="eyebrow">Tr&#225;mite de propiedad</div>
                    <h2 class="h5 fw-bold mb-2">Iniciar solicitud</h2>
                    <p class="text-muted">Selecciona el tipo de tr&#225;mite y guarda primero los documentos requeridos. Despu&#233;s podr&#225;s revisar la documentaci&#243;n y enviar la solicitud.</p>

                    <% if ("documentos".equals(request.getParameter("solicitud"))) { %>
                        <div class="alert alert-warning">Debes adjuntar al menos un documento para enviar la solicitud.</div>
                    <% } else if ("formato".equals(request.getParameter("solicitud"))) { %>
                        <div class="alert alert-danger">Solo se permiten documentos PDF, JPG, JPEG o PNG.</div>
                    <% } %>

                    <form method="post" action="<%= request.getContextPath() %>/acciones/solicitudes.jsp" enctype="multipart/form-data" class="row g-3">
                        <input type="hidden" name="accion" value="guardarDocumentos">
                        <input type="hidden" name="idPropiedad" value="<%= propiedad.get("id") %>">

                        <div class="col-md-4">
                            <label for="tipoSolicitud" class="form-label">Tipo de solicitud</label>
                            <select id="tipoSolicitud" name="tipo" class="form-select" required>
                                <option value="">Selecciona una opci&#243;n</option>
                                <option value="COMPRA">Compra</option>
                                <option value="ARRIENDO">Arriendo</option>
                            </select>
                        </div>

                        <div class="col-12">
                            <div class="p-3 rounded border bg-light">
                                <strong>Documentos requeridos</strong>
                                <p class="small text-muted mb-2">Estos son los documentos solicitados para este tr&#225;mite dentro de la aplicaci&#243;n. La inmobiliaria puede pedir documentaci&#243;n adicional durante la revisi&#243;n.</p>
                                <ul id="listaRequisitosSolicitud" class="small mb-0">
                                    <li>Selecciona primero si la solicitud es de compra o arriendo.</li>
                                </ul>
                            </div>
                        </div>

                        <div class="col-md-4">
                            <label for="documentoIdentidad" class="form-label">Documento de identidad <span class="text-danger">*</span></label>
                            <input type="file" id="documentoIdentidad" name="documentoIdentidad" class="form-control" accept=".pdf,.jpg,.jpeg,.png" required>
                        </div>

                        <div class="col-md-4">
                            <label for="soporteIngresos" class="form-label">Soporte de ingresos <span class="text-danger">*</span></label>
                            <input type="file" id="soporteIngresos" name="soporteIngresos" class="form-control" accept=".pdf,.jpg,.jpeg,.png" required>
                        </div>

                        <div class="col-md-4" id="campoCompra">
                            <label for="certificacionLaboral" class="form-label">Certificaci&#243;n laboral <span class="text-danger">*</span></label>
                            <input type="file" id="certificacionLaboral" name="certificacionLaboral" class="form-control" accept=".pdf,.jpg,.jpeg,.png">
                        </div>

                        <div class="col-md-4 d-none" id="campoArriendo">
                            <label for="referencia" class="form-label">Referencia <span class="text-danger">*</span></label>
                            <input type="file" id="referencia" name="referencia" class="form-control" accept=".pdf,.jpg,.jpeg,.png">
                        </div>

                        <div class="col-12">
                            <small class="text-muted">Formatos permitidos: PDF, JPG, JPEG y PNG. M&#225;ximo 5 MB por archivo.</small>
                        </div>

                        <div class="col-12 d-flex justify-content-end">
                            <button type="submit" class="btn btn-primary">Guardar documentos</button>
                        </div>
                    </form>
                </div>
            <% } %>

            <% if (esCliente && request.getParameter("nueva") != null && request.getParameter("nueva").equals(String.valueOf(propiedad.get("id")))) { %>
                <div class="surface-card mt-4">
                    <div class="eyebrow">Nueva visita</div>
                    <h2 class="h5 fw-bold mb-2">Agendar visita</h2>
                    <p class="text-muted">Selecciona una fecha y hora futura para solicitar la visita.</p>
                    <form method="post" action="<%= request.getContextPath() %>/acciones/citas.jsp" class="row g-3">
                        <input type="hidden" name="accion" value="agendar">
                        <input type="hidden" name="idPropiedad" value="<%= propiedad.get("id") %>">
                        <div class="col-md-4">
                            <label for="fechaVisita" class="form-label">Fecha</label>
                            <input type="date" id="fechaVisita" name="fechaVisita" class="form-control" min="<%= java.time.LocalDate.now() %>" required>
                        </div>
                        <div class="col-md-4">
                            <label for="horaVisita" class="form-label">Hora</label>
                            <select id="horaVisita" name="horaVisita" class="form-select" required disabled>
                                <option value="">Primero selecciona una fecha</option>
                            </select>
                            <small class="text-muted">Horarios cada 45 minutos, de 8:00 a. m. a 5:45 p. m.</small>
                        </div>
                        <div class="col-md-4 d-flex align-items-end">
                            <button type="submit" class="btn btn-primary w-100">Confirmar visita</button>
                        </div>
                    </form>
                </div>
            <% } %>


<script>
document.addEventListener("DOMContentLoaded", function () {
    const btnIniciarSolicitud = document.getElementById("btnIniciarSolicitud");
    const seccionSolicitud = document.getElementById("solicitud");

    if (btnIniciarSolicitud && seccionSolicitud) {
        btnIniciarSolicitud.addEventListener("click", function (evento) {
            evento.preventDefault();
            seccionSolicitud.classList.remove("d-none");
            seccionSolicitud.scrollIntoView({ behavior: "smooth", block: "start" });
        });
    }
});
</script>

<script>
document.addEventListener("DOMContentLoaded", function () {
    const tipoSolicitud = document.getElementById("tipoSolicitud");
    const listaRequisitos = document.getElementById("listaRequisitosSolicitud");
    const campoCompra = document.getElementById("campoCompra");
    const campoArriendo = document.getElementById("campoArriendo");
    const certificacionLaboral = document.getElementById("certificacionLaboral");
    const referencia = document.getElementById("referencia");

    function actualizarRequisitos() {
        if (!tipoSolicitud || !listaRequisitos) return;
        if (tipoSolicitud.value === "COMPRA") {
            listaRequisitos.innerHTML =
                "<li>Documento de identidad</li>" +
                "<li>Soporte de ingresos</li>" +
                "<li>Certificaci&#243;n laboral</li>";
            campoCompra.classList.remove("d-none");
            campoArriendo.classList.add("d-none");
            certificacionLaboral.required = true;
            referencia.required = false;
        } else if (tipoSolicitud.value === "ARRIENDO") {
            listaRequisitos.innerHTML =
                "<li>Documento de identidad</li>" +
                "<li>Soporte de ingresos</li>" +
                "<li>Referencia</li>";
            campoCompra.classList.add("d-none");
            campoArriendo.classList.remove("d-none");
            certificacionLaboral.required = false;
            referencia.required = true;
        } else {
            listaRequisitos.innerHTML = "<li>Selecciona primero si la solicitud es de compra o arriendo.</li>";
            campoCompra.classList.remove("d-none");
            campoArriendo.classList.add("d-none");
            certificacionLaboral.required = false;
            referencia.required = false;
        }
    }

    if (tipoSolicitud) {
        tipoSolicitud.addEventListener("change", actualizarRequisitos);
        actualizarRequisitos();
    }
});
</script>

<script>
document.addEventListener("DOMContentLoaded", function () {
    const fecha = document.getElementById("fechaVisita");
    const hora = document.getElementById("horaVisita");

    if (!fecha || !hora) return;

    const horarios = [
        "08:00", "08:45", "09:30", "10:15",
        "11:00", "11:45", "12:30", "13:15",
        "14:00", "14:45", "15:30", "16:15",
        "17:00", "17:45"
    ];

    fecha.addEventListener("change", function () {
        cargarHorariosDisponibles();
    });

    function cargarHorariosDisponibles() {
        hora.innerHTML = "<option value=\"\">Cargando horarios...</option>";
        hora.disabled = true;

        if (!fecha.value) {
            hora.innerHTML = "<option value=\"\">Primero selecciona una fecha</option>";
            return;
        }

        const idPropiedad = "<%= propiedad.get("id") %>";
        const url = "<%= request.getContextPath() %>/acciones/detalle-propiedad.jsp?accion=horarios&idPropiedad=" +
                    encodeURIComponent(idPropiedad) + "&fecha=" + encodeURIComponent(fecha.value);

        fetch(url)
            .then(function (respuesta) {
                if (!respuesta.ok) throw new Error("No se pudieron consultar los horarios");
                return respuesta.json();
            })
            .then(function (ocupados) {
                const ocupadosSet = new Set(ocupados);
                hora.innerHTML = "<option value=\"\">Selecciona una hora</option>";

                horarios.forEach(function (valor) {
                    if (ocupadosSet.has(valor)) return;

                    const opcion = document.createElement("option");
                    opcion.value = valor;
                    opcion.textContent = formatearHora(valor);
                    hora.appendChild(opcion);
                });

                if (hora.options.length === 1) {
                    hora.innerHTML = "<option value=\"\">No hay horarios disponibles para esta fecha</option>";
                }

                hora.disabled = hora.options.length === 1 && !hora.options[0].value;
            })
            .catch(function () {
                hora.innerHTML = "<option value=\"\">No se pudieron cargar los horarios</option>";
                hora.disabled = true;
            });
    }

    function formatearHora(valor) {
        const partes = valor.split(":");
        const horas = parseInt(partes[0], 10);
        const minutos = partes[1];
        const periodo = horas >= 12 ? "p. m." : "a. m.";
        const hora12 = horas % 12 || 12;
        return hora12 + ":" + minutos + " " + periodo;
    }
});
</script>

            <div class="row g-4 mt-1">
                <div class="col-lg-8">
                    <div class="surface-card">
                        <div class="eyebrow">Caracter&#237;sticas</div>
                        <h2 class="h5 fw-bold mb-3">Lo que ofrece esta propiedad</h2>
                        <% if (caracteristicas != null && !caracteristicas.isEmpty()) { %>
                            <div class="d-flex flex-wrap gap-2">
                                <% for (Map<String, Object> caracteristica : caracteristicas) { %>
                                    <span class="detail-feature">
                                        <span class="material-symbols-outlined">check_circle</span>
                                        <%= caracteristica.get("nombre") %>
                                        <% if (caracteristica.get("cantidad") != null && ((Integer) caracteristica.get("cantidad")) > 1) { %>
                                            (<%= caracteristica.get("cantidad") %>)
                                        <% } %>
                                    </span>
                                <% } %>
                            </div>
                        <% } else { %>
                            <p class="text-muted mb-0">No hay caracter&#237;sticas registradas para esta propiedad.</p>
                        <% } %>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="info-panel h-100">
                        <h2>&#191;Te interesa?</h2>
                        <p>Si quieres visitar esta propiedad o iniciar una solicitud, entra a tu panel de cliente. Estas acciones se habilitar&#225;n desde all&#237;.</p>
                    </div>
                </div>
            </div>
        <% } %>
    </div>
</main>
<%@ include file="WEB-INF/jspf/pie.jspf" %>
</body>
</html>
