package com.inmobiliaria.controlador;

import com.inmobiliaria.util.ConexionBD;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/imagenes-propiedad")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class ImagenPropiedadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!esInmobiliaria(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String idTexto = request.getParameter("id");
        try {
            int idPropiedad = Integer.parseInt(idTexto);
            int idUsuario = (Integer) session.getAttribute("idUsuario");

            if (!esPropiedadDeUsuario(idPropiedad, idUsuario)) {
                response.sendRedirect(request.getContextPath() + "/propiedades?error=noEncontrada");
                return;
            }

            cargarPagina(request, idPropiedad, idUsuario);
            request.getRequestDispatcher("/paneles/inmobiliaria/gestionar-propiedad.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/propiedades?error=datos");
        } catch (SQLException e) {
            request.setAttribute("error", "No se pudo cargar la gestión de la propiedad");
            request.getRequestDispatcher("/paneles/inmobiliaria/gestionar-propiedad.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (!esInmobiliaria(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");
        String accion = request.getParameter("accion");

        try {
            int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
            if (!esPropiedadDeUsuario(idPropiedad, idUsuario)) {
                response.sendRedirect(request.getContextPath() + "/propiedades?error=noEncontrada");
                return;
            }

            if ("subir".equals(accion)) {
                subirImagen(request, idPropiedad);
            } else if ("eliminar".equals(accion)) {
                eliminarImagen(request, idPropiedad);
            } else if ("principal".equals(accion)) {
                establecerPrincipal(request, idPropiedad);
            }
            response.sendRedirect(request.getContextPath() + "/imagenes-propiedad?id=" + idPropiedad + "&mensaje=" + accion);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/propiedades?error=datos");
        } catch (ServletException e) {
            response.sendRedirect(request.getContextPath() + "/imagenes-propiedad?id="
                    + request.getParameter("idPropiedad") + "&error=imagen");
        } catch (SQLException e) {
            response.sendRedirect(request.getContextPath() + "/imagenes-propiedad?id="
                    + request.getParameter("idPropiedad") + "&error=bd");
        }
    }

    private void subirImagen(HttpServletRequest request, int idPropiedad) throws IOException, SQLException, ServletException {
        Part parte = request.getPart("imagen");
        if (parte == null || parte.getSize() == 0) {
            throw new ServletException("No se seleccionó ninguna imagen");
        }
        if (parte.getSize() > 5 * 1024 * 1024) {
            throw new ServletException("La imagen no puede superar 5 MB");
        }

        String tipo = parte.getContentType();
        if (tipo == null || !tipo.toLowerCase().startsWith("image/")) {
            throw new ServletException("El archivo debe ser una imagen");
        }

        String nombreOriginal = parte.getSubmittedFileName();
        String extension = "";
        if (nombreOriginal != null && nombreOriginal.lastIndexOf('.') >= 0) {
            extension = nombreOriginal.substring(nombreOriginal.lastIndexOf('.')).toLowerCase();
        }
        if (!extension.matches("\\.(jpg|jpeg|png|gif|webp)$")) {
            throw new ServletException("Formato de imagen no permitido");
        }

        String nombre = "propiedad_" + idPropiedad + "_" + System.currentTimeMillis() + extension;
        String carpeta = request.getServletContext().getRealPath("/uploads/propiedades");
        File directorio = new File(carpeta);
        if (!directorio.exists() && !directorio.mkdirs()) {
            throw new IOException("No se pudo crear la carpeta de imágenes");
        }

        File archivo = new File(directorio, nombre);
        parte.write(archivo.getAbsolutePath());

        String url = request.getContextPath() + "/uploads/propiedades/" + nombre;
        String sql = "INSERT INTO imagen_propiedad (id_propiedad, url_imagen, es_principal) " +
                "VALUES (?, ?, NOT EXISTS (SELECT 1 FROM imagen_propiedad WHERE id_propiedad = ? AND es_principal = TRUE))";
        try (Connection con = ConexionBD.obtenerConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad);
            ps.setString(2, url);
            ps.setInt(3, idPropiedad);
            ps.executeUpdate();
        }
    }

    private void eliminarImagen(HttpServletRequest request, int idPropiedad) throws SQLException {
        int idImagen = Integer.parseInt(request.getParameter("idImagen"));
        String url = null;
        boolean eraPrincipal = false;
        String sql = "SELECT url_imagen, es_principal FROM imagen_propiedad ip " +
                "INNER JOIN propiedad p ON p.id_propiedad = ip.id_propiedad " +
                "INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "WHERE ip.id_imagen = ? AND ip.id_propiedad = ? AND i.id_usuario = ?";

        int idUsuario = (Integer) request.getSession().getAttribute("idUsuario");
        try (Connection con = ConexionBD.obtenerConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idImagen);
            ps.setInt(2, idPropiedad);
            ps.setInt(3, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    url = rs.getString("url_imagen");
                    eraPrincipal = rs.getBoolean("es_principal");
                }
            }
        }
        if (url == null) return;

        String delete = "DELETE FROM imagen_propiedad WHERE id_imagen = ? AND id_propiedad = ?";
        try (Connection con = ConexionBD.obtenerConexion(); PreparedStatement ps = con.prepareStatement(delete)) {
            ps.setInt(1, idImagen);
            ps.setInt(2, idPropiedad);
            ps.executeUpdate();
        }

        if (eraPrincipal) {
            String elegirOtra = "UPDATE imagen_propiedad SET es_principal = TRUE " +
                    "WHERE id_imagen = (SELECT id_imagen FROM imagen_propiedad " +
                    "WHERE id_propiedad = ? ORDER BY id_imagen LIMIT 1)";
            try (Connection con = ConexionBD.obtenerConexion(); PreparedStatement ps = con.prepareStatement(elegirOtra)) {
                ps.setInt(1, idPropiedad);
                ps.executeUpdate();
            }
        }

        String ruta = url;
        String contexto = request.getContextPath();
        if (ruta.startsWith(contexto)) ruta = ruta.substring(contexto.length());
        String real = request.getServletContext().getRealPath(ruta);
        if (real != null) new File(real).delete();
    }

    private void establecerPrincipal(HttpServletRequest request, int idPropiedad) throws SQLException {
        int idImagen = Integer.parseInt(request.getParameter("idImagen"));
        int idUsuario = (Integer) request.getSession().getAttribute("idUsuario");

        String verificar = "SELECT ip.id_imagen FROM imagen_propiedad ip " +
                "INNER JOIN propiedad p ON p.id_propiedad = ip.id_propiedad " +
                "INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "WHERE ip.id_imagen = ? AND ip.id_propiedad = ? AND i.id_usuario = ?";

        try (Connection con = ConexionBD.obtenerConexion()) {
            try (PreparedStatement ps = con.prepareStatement(verificar)) {
                ps.setInt(1, idImagen);
                ps.setInt(2, idPropiedad);
                ps.setInt(3, idUsuario);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return;
                }
            }

            con.setAutoCommit(false);
            try {
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE imagen_propiedad SET es_principal = FALSE WHERE id_propiedad = ?")) {
                    ps.setInt(1, idPropiedad);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE imagen_propiedad SET es_principal = TRUE WHERE id_imagen = ? AND id_propiedad = ?")) {
                    ps.setInt(1, idImagen);
                    ps.setInt(2, idPropiedad);
                    ps.executeUpdate();
                }
                con.commit();
            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    private void cargarPagina(HttpServletRequest request, int idPropiedad, int idUsuario) throws SQLException {
        Map<String, Object> propiedad = new HashMap<>();
        String sqlProp = "SELECT p.id_propiedad, p.titulo, p.matricula_inmobiliaria " +
                "FROM propiedad p INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "WHERE p.id_propiedad = ? AND i.id_usuario = ?";
        try (Connection con = ConexionBD.obtenerConexion(); PreparedStatement ps = con.prepareStatement(sqlProp)) {
            ps.setInt(1, idPropiedad); ps.setInt(2, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    propiedad.put("id", rs.getInt("id_propiedad"));
                    propiedad.put("titulo", rs.getString("titulo"));
                    propiedad.put("matricula", rs.getString("matricula_inmobiliaria"));
                }
            }
        }

        // La propiedad se deja disponible desde este punto para que la JSP
        // pueda mostrar correctamente el inmueble incluso si una consulta
        // posterior presenta un error.
        request.setAttribute("propiedad", propiedad);

        if (propiedad.isEmpty()) {
            throw new SQLException("La propiedad no existe o no pertenece a la inmobiliaria");
        }

        List<Map<String, Object>> imagenes = new ArrayList<>();
        String sqlImg = "SELECT id_imagen, url_imagen, es_principal FROM imagen_propiedad " +
                "WHERE id_propiedad = ? ORDER BY es_principal DESC, id_imagen";
        try (Connection con = ConexionBD.obtenerConexion(); PreparedStatement ps = con.prepareStatement(sqlImg)) {
            ps.setInt(1, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> img = new HashMap<>();
                    img.put("id", rs.getInt("id_imagen"));
                    img.put("url", rs.getString("url_imagen"));
                    img.put("principal", rs.getBoolean("es_principal"));
                    imagenes.add(img);
                }
            }
        }

        List<Map<String, Object>> caracteristicas = new ArrayList<>();
        List<Map<String, Object>> disponibles = new ArrayList<>();
        String sqlCar = "SELECT c.id_caracteristica, c.nombre, COALESCE(pc.cantidad, 0) AS cantidad " +
                "FROM caracteristica c LEFT JOIN propiedad_caracteristica pc ON pc.id_caracteristica = c.id_caracteristica " +
                "AND pc.id_propiedad = ? ORDER BY c.nombre";
        try (Connection con = ConexionBD.obtenerConexion(); PreparedStatement ps = con.prepareStatement(sqlCar)) {
            ps.setInt(1, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> c = new HashMap<>();
                    c.put("id", rs.getInt("id_caracteristica"));
                    c.put("nombre", rs.getString("nombre"));
                    c.put("cantidad", rs.getInt("cantidad"));
                    disponibles.add(c);
                    if (rs.getInt("cantidad") > 0) caracteristicas.add(c);
                }
            }
        }

        request.setAttribute("propiedad", propiedad);
        request.setAttribute("imagenes", imagenes);
        request.setAttribute("caracteristicas", caracteristicas);
        request.setAttribute("caracteristicasDisponibles", disponibles);
    }

    private boolean esPropiedadDeUsuario(int idPropiedad, int idUsuario) throws SQLException {
        String sql = "SELECT 1 FROM propiedad p INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "WHERE p.id_propiedad = ? AND i.id_usuario = ?";
        try (Connection con = ConexionBD.obtenerConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad); ps.setInt(2, idUsuario);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    private boolean esInmobiliaria(HttpSession session) {
        if (session == null || session.getAttribute("idUsuario") == null) return false;
        @SuppressWarnings("unchecked") List<String> roles = (List<String>) session.getAttribute("roles");
        return roles != null && roles.contains("INMOBILIARIA");
    }
}
