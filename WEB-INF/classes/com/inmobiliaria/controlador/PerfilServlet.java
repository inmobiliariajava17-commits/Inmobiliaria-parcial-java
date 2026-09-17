package com.inmobiliaria.controlador;

import com.inmobiliaria.util.ConexionBD;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.Part;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/perfil")
@MultipartConfig(maxFileSize = 2 * 1024 * 1024, maxRequestSize = 3 * 1024 * 1024)
public class PerfilServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!esCliente(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");
        Map<String, Object> perfil = cargarPerfil(idUsuario);
        request.setAttribute("perfil", perfil);
        request.getRequestDispatcher("/paneles/cliente/perfil.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
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
            eliminarArchivoFoto(fotoUrl);
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
                String rutaFisica = getServletContext().getRealPath("/uploads/perfiles");

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

        try (Connection con = ConexionBD.obtenerConexion()) {
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
                eliminarArchivoFoto(fotoAnterior);
            }

            session.setAttribute("fotoPerfil", fotoUrl.isEmpty() ? null : fotoUrl);
            response.sendRedirect(request.getContextPath() + "/perfil?guardado=1");

        } catch (SQLException e) {
            request.setAttribute("error", "No se pudo guardar el perfil");
            request.setAttribute("perfil", crearMapa(nombres, apellidos, documento, telefono, direccion, fotoUrl));
            request.getRequestDispatcher("/paneles/cliente/perfil.jsp").forward(request, response);
        }
    }

    private Map<String, Object> cargarPerfil(int idUsuario) {
        Map<String, Object> perfil = new HashMap<>();
        String sql = "SELECT nombres, apellidos, documento, telefono, direccion, foto_url FROM perfil WHERE id_usuario = ?";

        try (Connection con = ConexionBD.obtenerConexion();
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
        try (Connection con = ConexionBD.obtenerConexion();
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
        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("foto_url") : null;
            }
        } catch (SQLException e) {
            return null;
        }
    }


    private void eliminarArchivoFoto(String fotoUrl) {
        try {
            String ruta = fotoUrl;
            String contexto = requestContextPath();
            if (contexto != null && !contexto.isEmpty() && ruta.startsWith(contexto)) {
                ruta = ruta.substring(contexto.length());
            }
            if (ruta.startsWith("/uploads/perfiles/")) {
                String nombre = ruta.substring("/uploads/perfiles/".length());
                Path archivo = Paths.get(getServletContext().getRealPath("/uploads/perfiles"), nombre);
                Files.deleteIfExists(archivo);
            }
        } catch (Exception ignored) {
            // Si no se puede eliminar el archivo físico, igual se quita la referencia de la BD.
        }
    }

    private String requestContextPath() {
        return getServletContext().getContextPath();
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

    private boolean esCliente(HttpSession session) {
        if (session == null || session.getAttribute("idUsuario") == null) {
            return false;
        }

        @SuppressWarnings("unchecked")
        java.util.List<String> roles = (java.util.List<String>) session.getAttribute("roles");
        return roles != null && roles.contains("CLIENTE");
    }
}
