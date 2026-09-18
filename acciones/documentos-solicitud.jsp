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
<%@ page import="java.sql.Timestamp" %>
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
private void subirDocumento(HttpServletRequest request, HttpServletResponse response,
                                int idSolicitud, int idUsuario) throws IOException, ServletException, SQLException {

        Part archivo = request.getPart("archivo");
        if (archivo == null || archivo.getSize() == 0) {
            response.sendRedirect(request.getContextPath() + "/acciones/documentos-solicitud.jsp?idSolicitud=" + idSolicitud + "&error=archivo");
            return;
        }

        String nombreOriginal = Paths.get(archivo.getSubmittedFileName()).getFileName().toString();
        String extension = obtenerExtension(nombreOriginal);
        if (!extensionPermitida(extension)) {
            response.sendRedirect(request.getContextPath() + "/acciones/documentos-solicitud.jsp?idSolicitud=" + idSolicitud + "&error=formato");
            return;
        }

        String nombreArchivo = UUID.randomUUID() + "." + extension;
        Path carpeta = Paths.get(request.getServletContext().getRealPath("/uploads/solicitudes/" + idSolicitud));
        Files.createDirectories(carpeta);
        Path destino = carpeta.resolve(nombreArchivo);
        archivo.write(destino.toString());

        String url = request.getContextPath() + "/uploads/solicitudes/" + idSolicitud + "/" + nombreArchivo;
        String sql = "INSERT INTO documento_solicitud (id_solicitud, url_documento, nombre_documento, tipo_documento) VALUES (?, ?, ?, ?)";

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idSolicitud);
            ps.setString(2, url);
            ps.setString(3, nombreOriginal);
            ps.setString(4, "DOCUMENTO ADICIONAL");
            ps.executeUpdate();
        } catch (SQLException e) {
            Files.deleteIfExists(destino);
            throw e;
        }

        registrarAuditoria(idUsuario, "Cargó un documento para la solicitud: " + idSolicitud);
        response.sendRedirect(request.getContextPath() + "/acciones/documentos-solicitud.jsp?idSolicitud=" + idSolicitud + "&mensaje=subido");
    }

private void eliminarDocumento(HttpServletRequest request, HttpServletResponse response,
                                   int idSolicitud, int idUsuario) throws IOException, SQLException {

        int idDocumento = Integer.parseInt(request.getParameter("idDocumento"));
        String url = null;

        String consulta =
                "SELECT d.url_documento FROM documento_solicitud d " +
                "INNER JOIN solicitud s ON s.id_solicitud = d.id_solicitud " +
                "WHERE d.id_documento = ? AND d.id_solicitud = ? AND s.id_usuario = ?";

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(consulta)) {
            ps.setInt(1, idDocumento);
            ps.setInt(2, idSolicitud);
            ps.setInt(3, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    url = rs.getString("url_documento");
                }
            }
        }

        if (url == null) {
            response.sendRedirect(request.getContextPath() + "/acciones/documentos-solicitud.jsp?idSolicitud=" + idSolicitud + "&error=documento");
            return;
        }

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement("DELETE FROM documento_solicitud WHERE id_documento = ? AND id_solicitud = ?")) {
            ps.setInt(1, idDocumento);
            ps.setInt(2, idSolicitud);
            ps.executeUpdate();
        }

        String prefijo = request.getContextPath() + "/uploads/";
        if (url.startsWith(prefijo)) {
            String rutaRelativa = url.substring(prefijo.length());
            Path archivo = Paths.get(request.getServletContext().getRealPath("/uploads/" + rutaRelativa));
            Files.deleteIfExists(archivo);
        }

        registrarAuditoria(idUsuario, "Eliminó un documento de la solicitud: " + idSolicitud);
        response.sendRedirect(request.getContextPath() + "/acciones/documentos-solicitud.jsp?idSolicitud=" + idSolicitud + "&mensaje=eliminado");
    }

private Map<String, String> obtenerDatosSolicitud(int idSolicitud, int idUsuario) throws SQLException {
        Map<String, String> datos = new HashMap<>();
        String sql = "SELECT estado, tipo FROM solicitud WHERE id_solicitud = ? AND id_usuario = ?";
        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idSolicitud);
            ps.setInt(2, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    datos.put("estado", rs.getString("estado"));
                    datos.put("tipo", rs.getString("tipo"));
                }
            }
        }
        return datos;
    }

private List<Map<String, Object>> obtenerDocumentos(int idSolicitud) throws SQLException {
        List<Map<String, Object>> documentos = new ArrayList<>();
        String sql = "SELECT id_documento, url_documento, nombre_documento, tipo_documento, fecha_carga FROM documento_solicitud WHERE id_solicitud = ? ORDER BY fecha_carga DESC";

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idSolicitud);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> documento = new HashMap<>();
                    documento.put("id", rs.getInt("id_documento"));
                    documento.put("url", rs.getString("url_documento"));
                    documento.put("nombre", rs.getString("nombre_documento"));
                    documento.put("tipo", rs.getString("tipo_documento"));
                    documento.put("fecha", rs.getTimestamp("fecha_carga"));
                    documentos.add(documento);
                }
            }
        }
        return documentos;
    }

private boolean perteneceAlCliente(int idSolicitud, int idUsuario) throws SQLException {
        String sql = "SELECT 1 FROM solicitud WHERE id_solicitud = ? AND id_usuario = ?";
        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idSolicitud);
            ps.setInt(2, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
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

private String obtenerExtension(String nombre) {
        int punto = nombre.lastIndexOf('.');
        return punto >= 0 ? nombre.substring(punto + 1).toLowerCase() : "";
    }

private boolean extensionPermitida(String extension) {
        for (String permitida : EXTENSIONES_PERMITIDAS) {
            if (permitida.equals(extension)) return true;
        }
        return false;
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

        String idTexto = request.getParameter("idSolicitud");
        if (idTexto == null || idTexto.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/acciones/solicitudes.jsp?error=documento");
            return;
        }

        try {
            int idSolicitud = Integer.parseInt(idTexto);
            int idUsuario = (Integer) session.getAttribute("idUsuario");

            if (!perteneceAlCliente(idSolicitud, idUsuario)) {
                response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                return;
            }

            List<Map<String, Object>> documentos = obtenerDocumentos(idSolicitud);
            Map<String, String> datosSolicitud = obtenerDatosSolicitud(idSolicitud, idUsuario);
            request.setAttribute("documentos", documentos);
            request.setAttribute("idSolicitud", idSolicitud);
            request.setAttribute("estadoSolicitud", datosSolicitud.get("estado"));
            request.setAttribute("tipoSolicitud", datosSolicitud.get("tipo"));
            request.getRequestDispatcher("/paneles/cliente/documentos-solicitud.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/solicitudes.jsp?error=documento");
        } catch (SQLException e) {
            request.setAttribute("error", "No se pudieron cargar los documentos.");
            request.setAttribute("documentos", new ArrayList<Map<String, Object>>());
            request.setAttribute("idSolicitud", idTexto);
            request.getRequestDispatcher("/paneles/cliente/documentos-solicitud.jsp")
                    .forward(request, response);
        }
    
}
else if ("POST".equalsIgnoreCase(request.getMethod())) {


if (!esCliente(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");
        String accion = request.getParameter("accion");

        try {
            int idSolicitud = Integer.parseInt(request.getParameter("idSolicitud"));

            if (!perteneceAlCliente(idSolicitud, idUsuario)) {
                response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                return;
            }

            if ("subir".equals(accion)) {
                subirDocumento(request, response, idSolicitud, idUsuario);
            } else if ("eliminar".equals(accion)) {
                eliminarDocumento(request, response, idSolicitud, idUsuario);
            } else {
                response.sendRedirect(request.getContextPath() + "/acciones/documentos-solicitud.jsp?idSolicitud=" + idSolicitud + "&error=accion");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/solicitudes.jsp?error=documento");
        } catch (SQLException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/solicitudes.jsp?error=guardar-documento");
        }
    
}
%>
