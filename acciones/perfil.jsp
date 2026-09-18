<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="javax.servlet.ServletException" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.nio.file.Files" %>
<%@ page import="java.nio.file.Path" %>
<%@ page import="java.nio.file.Paths" %>
<%@ page import="java.nio.file.StandardCopyOption" %>
<%@ page import="java.util.UUID" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="javax.servlet.http.Part" %>
<%!
private Map<String, Object> cargarPerfil(int idUsuario) {
        Map<String, Object> perfil = new HashMap<>();
        String sql = "SELECT nombres, apellidos, documento, telefono, direccion, foto_url FROM perfil WHERE id_usuario = ?";

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    perfil.put("nombres", rs.getString("nombres"));
                    perfil.put("apellidos", rs.getString("apellidos"));
                    perfil.put("documento", rs.getString("documento"));
                    perfil.put("telefono", rs.getString("telefono"));
                    perfil.put("direccion", rs.getString("direccion"));
                    perfil.put("fotoUrl", rs.getString("foto_url"));
                }
            }
        } catch (SQLException ignored) {
            // La vista mostrará el formulario vacío si no se puede cargar.
        }

        return perfil;
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

private Map<String, Object> crearMapa(String nombres, String apellidos, String documento,
                                           String telefono, String direccion, String fotoUrl) {
        Map<String, Object> perfil = new HashMap<>();
        perfil.put("nombres", nombres);
        perfil.put("apellidos", apellidos);
        perfil.put("documento", documento);
        perfil.put("telefono", telefono);
        perfil.put("direccion", direccion);
        perfil.put("fotoUrl", fotoUrl);
        return perfil;
    }

private String obtenerFotoActual(int idUsuario) {
        String sql = "SELECT foto_url FROM perfil WHERE id_usuario = ?";
        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("foto_url") : null;
            }
        } catch (SQLException e) {
            return null;
        }
    }

private void eliminarArchivoFoto(HttpServletRequest request, String fotoUrl) {
        try {
            String ruta = fotoUrl;
            String contexto = request.getServletContext().getContextPath();
            if (contexto != null && !contexto.isEmpty() && ruta.startsWith(contexto)) {
                ruta = ruta.substring(contexto.length());
            }
            if (ruta.startsWith("/uploads/perfiles/")) {
                String nombre = ruta.substring("/uploads/perfiles/".length());
                Path archivo = Paths.get(request.getServletContext().getRealPath("/uploads/perfiles"), nombre);
                Files.deleteIfExists(archivo);
            }
        } catch (Exception ignored) {
            // Si no se puede eliminar el archivo físico, igual se quita la referencia de la BD.
        }
    }

private String obtenerExtension(String nombre, String tipo) {
        String extension = ".jpg";
        if (nombre != null && nombre.lastIndexOf('.') >= 0) {
            extension = nombre.substring(nombre.lastIndexOf('.')).toLowerCase();
            if (!extension.matches("\\.(jpg|jpeg|png|gif|webp)")) {
                extension = ".jpg";
            }
        } else if ("image/png".equalsIgnoreCase(tipo)) {
            extension = ".png";
        } else if ("image/gif".equalsIgnoreCase(tipo)) {
            extension = ".gif";
        } else if ("image/webp".equalsIgnoreCase(tipo)) {
            extension = ".webp";
        }
        return extension;
    }

private String limpiar(String valor) {
        return valor == null ? "" : valor.trim();
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
        Map<String, Object> perfil = cargarPerfil(idUsuario);
        request.setAttribute("perfil", perfil);
        request.getRequestDispatcher("/paneles/cliente/perfil.jsp").forward(request, response);
    
}
else if ("POST".equalsIgnoreCase(request.getMethod())) {


if (!esCliente(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String nombres = limpiar(request.getParameter("nombres"));
        String apellidos = limpiar(request.getParameter("apellidos"));
        String documento = limpiar(request.getParameter("documento"));
        String telefono = limpiar(request.getParameter("telefono"));
        String direccion = limpiar(request.getParameter("direccion"));
        String fotoUrl = "";
        Part foto = request.getPart("foto");

        if (nombres.isEmpty() || apellidos.isEmpty() || documento.isEmpty()) {
            request.setAttribute("error", "Nombres, apellidos y documento son obligatorios");
            request.setAttribute("perfil", crearMapa(nombres, apellidos, documento, telefono, direccion, fotoUrl));
            request.getRequestDispatcher("/paneles/cliente/perfil.jsp").forward(request, response);
            return;
        }

        if (nombres.length() > 100 || apellidos.length() > 100 || documento.length() > 30
                || telefono.length() > 20 || direccion.length() > 200) {
            request.setAttribute("error", "Uno de los datos supera la longitud permitida");
            request.setAttribute("perfil", crearMapa(nombres, apellidos, documento, telefono, direccion, fotoUrl));
            request.getRequestDispatcher("/paneles/cliente/perfil.jsp").forward(request, response);
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");

        String fotoAnterior = obtenerFotoActual(idUsuario);
        fotoUrl = fotoAnterior == null ? "" : fotoAnterior;
        boolean fotoNueva = false;

        String eliminarFoto = request.getParameter("eliminarFoto");
        if ("1".equals(eliminarFoto) && !fotoUrl.isEmpty()) {
            eliminarArchivoFoto(request, fotoUrl);
            fotoUrl = "";
        }

        try {
            if (!"1".equals(eliminarFoto) && foto != null && foto.getSize() > 0) {
                String tipo = foto.getContentType();
                if (tipo == null || !tipo.startsWith("image/")) {
                    request.setAttribute("error", "La foto debe ser una imagen");
                    request.setAttribute("perfil", crearMapa(nombres, apellidos, documento, telefono, direccion, fotoUrl));
                    request.getRequestDispatcher("/paneles/cliente/perfil.jsp").forward(request, response);
                    return;
                }

                String extension = obtenerExtension(foto.getSubmittedFileName(), tipo);
                String nombreArchivo = "perfil_" + idUsuario + "_" + UUID.randomUUID().toString() + extension;
                String rutaFisica = request.getServletContext().getRealPath("/uploads/perfiles");

                if (rutaFisica == null) {
                    throw new IOException("No se pudo obtener la carpeta de imágenes");
                }

                Path carpeta = Paths.get(rutaFisica);
                Files.createDirectories(carpeta);
                Path destino = carpeta.resolve(nombreArchivo);
                try (InputStream entrada = foto.getInputStream()) {
                    Files.copy(entrada, destino, StandardCopyOption.REPLACE_EXISTING);
                }

                fotoUrl = request.getContextPath() + "/uploads/perfiles/" + nombreArchivo;
                fotoNueva = true;
            }
        } catch (IOException e) {
            request.setAttribute("error", "No se pudo guardar la imagen. Verifica que sea una imagen de máximo 2 MB.");
            request.setAttribute("perfil", crearMapa(nombres, apellidos, documento, telefono, direccion, fotoUrl));
            request.getRequestDispatcher("/paneles/cliente/perfil.jsp").forward(request, response);
            return;
        }

        String sqlExiste = "SELECT id_perfil FROM perfil WHERE id_usuario = ?";
        String sqlActualizar = "UPDATE perfil SET nombres = ?, apellidos = ?, documento = ?, telefono = ?, direccion = ?, foto_url = ? WHERE id_usuario = ?";
        String sqlCrear = "INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion, foto_url) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = obtenerConexion()) {
            boolean existe;
            try (PreparedStatement ps = con.prepareStatement(sqlExiste)) {
                ps.setInt(1, idUsuario);
                try (ResultSet rs = ps.executeQuery()) {
                    existe = rs.next();
                }
            }

            if (existe) {
                try (PreparedStatement ps = con.prepareStatement(sqlActualizar)) {
                    ps.setString(1, nombres);
                    ps.setString(2, apellidos);
                    ps.setString(3, documento);
                    ps.setString(4, telefono.isEmpty() ? null : telefono);
                    ps.setString(5, direccion.isEmpty() ? null : direccion);
                    ps.setString(6, fotoUrl.isEmpty() ? null : fotoUrl);
                    ps.setInt(7, idUsuario);
                    ps.executeUpdate();
                }
            } else {
                try (PreparedStatement ps = con.prepareStatement(sqlCrear)) {
                    ps.setInt(1, idUsuario);
                    ps.setString(2, nombres);
                    ps.setString(3, apellidos);
                    ps.setString(4, documento);
                    ps.setString(5, telefono.isEmpty() ? null : telefono);
                    ps.setString(6, direccion.isEmpty() ? null : direccion);
                    ps.setString(7, fotoUrl.isEmpty() ? null : fotoUrl);
                    ps.executeUpdate();
                }
            }

            registrarAuditoria(idUsuario, existe ? "Actualizó su perfil" : "Creó su perfil");

            if (fotoNueva && fotoAnterior != null && !fotoAnterior.isEmpty()) {
                eliminarArchivoFoto(request, fotoAnterior);
            }

            session.setAttribute("fotoPerfil", fotoUrl.isEmpty() ? null : fotoUrl);
            response.sendRedirect(request.getContextPath() + "/acciones/perfil.jsp?guardado=1");

        } catch (SQLException e) {
            request.setAttribute("error", "No se pudo guardar el perfil");
            request.setAttribute("perfil", crearMapa(nombres, apellidos, documento, telefono, direccion, fotoUrl));
            request.getRequestDispatcher("/paneles/cliente/perfil.jsp").forward(request, response);
        }
    
}
%>
