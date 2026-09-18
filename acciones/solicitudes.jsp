<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="javax.servlet.ServletException" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.nio.file.Files" %>
<%@ page import="java.nio.file.Path" %>
<%@ page import="java.nio.file.Paths" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.UUID" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="javax.servlet.http.Part" %>
<%!
private static final String[] EXTENSIONES_PERMITIDAS = {"pdf", "jpg", "jpeg", "png"};
private void guardarDocumentos(HttpServletRequest request, HttpServletResponse response, int idUsuario)
            throws SQLException, IOException, ServletException {

        String idPropiedadTexto = request.getParameter("idPropiedad");
        String tipo = request.getParameter("tipo");

        if (idPropiedadTexto == null || idPropiedadTexto.isBlank() || tipo == null || tipo.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/acciones/solicitudes.jsp?error=datos");
            return;
        }

        int idPropiedad = Integer.parseInt(idPropiedadTexto);
        tipo = tipo.toUpperCase();

        if (!"COMPRA".equals(tipo) && !"ARRIENDO".equals(tipo)) {
            response.sendRedirect(request.getContextPath() + "/acciones/detalle-propiedad.jsp?id=" + idPropiedad + "&solicitud=tipo");
            return;
        }

        List<DocumentoRequerido> documentos = obtenerDocumentosRequeridos(request, tipo);
        for (DocumentoRequerido documento : documentos) {
            if (documento.part == null || documento.part.getSize() == 0) {
                response.sendRedirect(request.getContextPath() + "/acciones/detalle-propiedad.jsp?id=" + idPropiedad + "&solicitud=documentos");
                return;
            }

            String nombreOriginal = Paths.get(documento.part.getSubmittedFileName()).getFileName().toString();
            if (!extensionPermitida(obtenerExtension(nombreOriginal))) {
                response.sendRedirect(request.getContextPath() + "/acciones/detalle-propiedad.jsp?id=" + idPropiedad + "&solicitud=formato");
                return;
            }
        }

        String verificarPropiedad =
                "SELECT 1 FROM propiedad WHERE id_propiedad = ? AND estado = 'DISPONIBLE'";

        String verificarSolicitud =
                "SELECT 1 FROM solicitud WHERE id_usuario = ? AND id_propiedad = ? " +
                "AND estado IN ('BORRADOR', 'EN_REVISION', 'APROBADA')";

        String insertarSolicitud =
                "INSERT INTO solicitud (id_propiedad, id_usuario, tipo, estado) " +
                "VALUES (?, ?, ?, 'BORRADOR') RETURNING id_solicitud";

        String insertarDocumento =
                "INSERT INTO documento_solicitud " +
                "(id_solicitud, url_documento, nombre_documento, tipo_documento) VALUES (?, ?, ?, ?)";

        List<Path> archivosGuardados = new ArrayList<>();
        int idSolicitud;

        try (Connection con = obtenerConexion()) {
            try (PreparedStatement ps = con.prepareStatement(verificarPropiedad)) {
                ps.setInt(1, idPropiedad);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect(request.getContextPath() + "/acciones/detalle-propiedad.jsp?id=" + idPropiedad + "&solicitud=no-disponible");
                        return;
                    }
                }
            }

            try (PreparedStatement ps = con.prepareStatement(verificarSolicitud)) {
                ps.setInt(1, idUsuario);
                ps.setInt(2, idPropiedad);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        response.sendRedirect(request.getContextPath() + "/acciones/detalle-propiedad.jsp?id=" + idPropiedad + "&solicitud=existente");
                        return;
                    }
                }
            }

            con.setAutoCommit(false);
            try {
                try (PreparedStatement ps = con.prepareStatement(insertarSolicitud)) {
                    ps.setInt(1, idPropiedad);
                    ps.setInt(2, idUsuario);
                    ps.setString(3, tipo);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new SQLException("No se pudo obtener el ID de la solicitud.");
                        }
                        idSolicitud = rs.getInt("id_solicitud");
                    }
                }

                Path carpeta = Paths.get(request.getServletContext().getRealPath("/uploads/solicitudes/" + idSolicitud));
                Files.createDirectories(carpeta);

                try (PreparedStatement psDocumento = con.prepareStatement(insertarDocumento)) {
                    for (DocumentoRequerido documento : documentos) {
                        Part archivo = documento.part;
                        String nombreOriginal = Paths.get(archivo.getSubmittedFileName()).getFileName().toString();
                        String extension = obtenerExtension(nombreOriginal);
                        String nombreArchivo = UUID.randomUUID() + "." + extension;
                        Path destino = carpeta.resolve(nombreArchivo);

                        archivo.write(destino.toString());
                        archivosGuardados.add(destino);

                        String url = request.getContextPath() + "/uploads/solicitudes/" + idSolicitud + "/" + nombreArchivo;
                        psDocumento.setInt(1, idSolicitud);
                        psDocumento.setString(2, url);
                        psDocumento.setString(3, nombreOriginal);
                        psDocumento.setString(4, documento.tipo);
                        psDocumento.executeUpdate();
                    }
                }

                con.commit();
            } catch (Exception e) {
                try {
                    con.rollback();
                } catch (SQLException ignored) {
                }
                for (Path archivo : archivosGuardados) {
                    try {
                        Files.deleteIfExists(archivo);
                    } catch (IOException ignored) {
                    }
                }
                if (e instanceof SQLException) throw (SQLException) e;
                if (e instanceof ServletException) throw (ServletException) e;
                throw new SQLException("No se pudieron guardar los documentos.", e);
            } finally {
                try {
                    con.setAutoCommit(true);
                } catch (SQLException ignored) {
                }
            }
        }

        registrarAuditoria(idUsuario, "Guardó los documentos de una solicitud de " + tipo.toLowerCase() +
                " para la propiedad: " + idPropiedad);
        response.sendRedirect(request.getContextPath() + "/acciones/documentos-solicitud.jsp?idSolicitud=" + idSolicitud + "&mensaje=guardados");
    }

private void enviarSolicitud(HttpServletRequest request, HttpServletResponse response, int idUsuario)
            throws SQLException, IOException {

        String idTexto = request.getParameter("idSolicitud");
        if (idTexto == null || idTexto.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/acciones/solicitudes.jsp?error=datos");
            return;
        }

        int idSolicitud = Integer.parseInt(idTexto);
        String tipo = null;
        int idPropiedad = 0;

        String obtenerSolicitud =
                "SELECT id_propiedad, tipo FROM solicitud " +
                "WHERE id_solicitud = ? AND id_usuario = ? AND estado = 'BORRADOR'";

        String verificarPropiedad =
                "SELECT 1 FROM propiedad WHERE id_propiedad = ? AND estado = 'DISPONIBLE'";

        String verificarDocumentos =
                "SELECT tipo_documento FROM documento_solicitud WHERE id_solicitud = ?";

        try (Connection con = obtenerConexion()) {
            try (PreparedStatement ps = con.prepareStatement(obtenerSolicitud)) {
                ps.setInt(1, idSolicitud);
                ps.setInt(2, idUsuario);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect(request.getContextPath() + "/acciones/solicitudes.jsp?error=solicitud");
                        return;
                    }
                    idPropiedad = rs.getInt("id_propiedad");
                    tipo = rs.getString("tipo");
                }
            }

            try (PreparedStatement ps = con.prepareStatement(verificarPropiedad)) {
                ps.setInt(1, idPropiedad);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect(request.getContextPath() + "/acciones/documentos-solicitud.jsp?idSolicitud=" + idSolicitud + "&error=no-disponible");
                        return;
                    }
                }
            }

            boolean identidad = false;
            boolean ingresos = false;
            boolean tercero = false;

            try (PreparedStatement ps = con.prepareStatement(verificarDocumentos)) {
                ps.setInt(1, idSolicitud);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String documento = rs.getString("tipo_documento");
                        if ("DOCUMENTO DE IDENTIDAD".equals(documento)) identidad = true;
                        if ("SOPORTE DE INGRESOS".equals(documento)) ingresos = true;
                        if ("COMPRA".equals(tipo) && "CERTIFICACION LABORAL".equals(documento)) tercero = true;
                        if ("ARRIENDO".equals(tipo) && "REFERENCIA".equals(documento)) tercero = true;
                    }
                }
            }

            if (!identidad || !ingresos || !tercero) {
                response.sendRedirect(request.getContextPath() + "/acciones/documentos-solicitud.jsp?idSolicitud=" + idSolicitud + "&error=incompletos");
                return;
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE solicitud SET estado = 'EN_REVISION' WHERE id_solicitud = ? AND id_usuario = ? AND estado = 'BORRADOR'")) {
                ps.setInt(1, idSolicitud);
                ps.setInt(2, idUsuario);
                ps.executeUpdate();
            }
        }

        registrarAuditoria(idUsuario, "Envió la solicitud " + idSolicitud + " para revisión");
        response.sendRedirect(request.getContextPath() + "/acciones/solicitudes.jsp?mensaje=creada");
    }

private List<DocumentoRequerido> obtenerDocumentosRequeridos(HttpServletRequest request, String tipo) {
        List<DocumentoRequerido> documentos = new ArrayList<>();
        documentos.add(new DocumentoRequerido(obtenerPart(request, "documentoIdentidad"), "DOCUMENTO DE IDENTIDAD"));
        documentos.add(new DocumentoRequerido(obtenerPart(request, "soporteIngresos"), "SOPORTE DE INGRESOS"));
        if ("COMPRA".equals(tipo)) {
            documentos.add(new DocumentoRequerido(obtenerPart(request, "certificacionLaboral"), "CERTIFICACION LABORAL"));
        } else {
            documentos.add(new DocumentoRequerido(obtenerPart(request, "referencia"), "REFERENCIA"));
        }
        return documentos;
    }

private static class DocumentoRequerido {
        private final Part part;
        private final String tipo;
        DocumentoRequerido(Part part, String tipo) {
            this.part = part;
            this.tipo = tipo;
        }
    }

private Part obtenerPart(HttpServletRequest request, String nombre) {
        try {
            return request.getPart(nombre);
        } catch (Exception e) {
            return null;
        }
    }

private String obtenerExtension(String nombre) {
        int punto = nombre.lastIndexOf('.');
        if (punto < 0 || punto == nombre.length() - 1) return "";
        return nombre.substring(punto + 1).toLowerCase();
    }

private boolean extensionPermitida(String extension) {
        for (String permitida : EXTENSIONES_PERMITIDAS) {
            if (permitida.equals(extension)) return true;
        }
        return false;
    }

private void registrarAuditoria(int idUsuario, String accion) throws SQLException {
        String sql = "INSERT INTO auditoria (id_usuario, accion) VALUES (?, ?)";
        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setString(2, accion);
            ps.executeUpdate();
        }
    }



%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
if ("GET".equalsIgnoreCase(request.getMethod())) {


if (!esCliente(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");
        List<Map<String, Object>> solicitudes = new ArrayList<>();

        String sql =
                "SELECT s.id_solicitud, s.id_propiedad, s.tipo, s.estado, s.fecha_solicitud, " +
                "p.titulo, p.precio, c.nombre_ciudad, tp.nombre_tipo " +
                "FROM solicitud s " +
                "INNER JOIN propiedad p ON p.id_propiedad = s.id_propiedad " +
                "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                "INNER JOIN tipo_propiedad tp ON tp.id_tipo = p.id_tipo " +
                "WHERE s.id_usuario = ? " +
                "ORDER BY s.fecha_solicitud DESC";

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> solicitud = new HashMap<>();
                    solicitud.put("id", rs.getInt("id_solicitud"));
                    solicitud.put("idPropiedad", rs.getInt("id_propiedad"));
                    solicitud.put("tipo", rs.getString("tipo"));
                    solicitud.put("estado", rs.getString("estado"));
                    solicitud.put("fecha", rs.getTimestamp("fecha_solicitud"));
                    solicitud.put("titulo", rs.getString("titulo"));
                    solicitud.put("precio", rs.getBigDecimal("precio"));
                    solicitud.put("ciudad", rs.getString("nombre_ciudad"));
                    solicitud.put("tipoPropiedad", rs.getString("nombre_tipo"));
                    solicitudes.add(solicitud);
                }
            }
        } catch (SQLException e) {
            request.setAttribute("error", "No se pudieron cargar las solicitudes.");
        }

        request.setAttribute("solicitudes", solicitudes);
        request.getRequestDispatcher("/paneles/cliente/solicitudes.jsp").forward(request, response);
    
}
else if ("POST".equalsIgnoreCase(request.getMethod())) {


if (!esCliente(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");
        String accion = request.getParameter("accion");

        try {
            if ("guardarDocumentos".equals(accion)) {
                guardarDocumentos(request, response, idUsuario);
            } else if ("enviar".equals(accion)) {
                enviarSolicitud(request, response, idUsuario);
            } else {
                response.sendRedirect(request.getContextPath() + "/acciones/solicitudes.jsp?error=accion");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/solicitudes.jsp?error=datos");
        } catch (SQLException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/solicitudes.jsp?error=guardar");
        }
    
}
%>
