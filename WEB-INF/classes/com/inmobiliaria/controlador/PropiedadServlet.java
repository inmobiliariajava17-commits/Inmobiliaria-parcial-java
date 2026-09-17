package com.inmobiliaria.controlador;

import com.inmobiliaria.util.ConexionBD;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/propiedades")
public class PropiedadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (!esInmobiliaria(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String accion = request.getParameter("accion");

        if ("nueva".equals(accion)) {
            cargarCatalogos(request);
            request.getRequestDispatcher("/paneles/inmobiliaria/registrar-propiedad.jsp")
                    .forward(request, response);
            return;
        }

        if ("editar".equals(accion)) {
            cargarCatalogos(request);

            String idTexto = request.getParameter("id");
            if (idTexto == null) {
                response.sendRedirect(request.getContextPath() + "/propiedades");
                return;
            }

            try {
                int idPropiedad = Integer.parseInt(idTexto);
                int idUsuario = (Integer) session.getAttribute("idUsuario");

                Map<String, Object> propiedad = buscarPropiedad(idPropiedad, idUsuario);

                if (propiedad == null) {
                    response.sendRedirect(request.getContextPath() + "/propiedades?error=noEncontrada");
                    return;
                }

                request.setAttribute("propiedad", propiedad);
                request.getRequestDispatcher("/paneles/inmobiliaria/editar-propiedad.jsp")
                        .forward(request, response);

            } catch (NumberFormatException | SQLException e) {
                response.sendRedirect(request.getContextPath() + "/propiedades?error=datos");
            }
            return;
        }

        listarPropiedades(request, response);
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

        String accion = request.getParameter("accion");

        if ("crear".equals(accion)) {
            crearPropiedad(request, response);
        } else if ("editar".equals(accion)) {
            editarPropiedad(request, response);
        } else if ("eliminar".equals(accion)) {
            eliminarPropiedad(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/propiedades");
        }
    }

    private void listarPropiedades(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int idUsuario = (Integer) request.getSession().getAttribute("idUsuario");

        String ciudad = request.getParameter("ciudad");
        String tipo = request.getParameter("tipo");
        String estado = request.getParameter("estado");
        String precioMaxTexto = request.getParameter("precioMax");

        List<Map<String, Object>> propiedades = new ArrayList<>();
        List<String[]> ciudades = new ArrayList<>();
        List<String[]> tipos = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT p.id_propiedad, p.matricula_inmobiliaria, p.titulo, " +
                "p.descripcion, p.precio, p.estado, p.fecha_publicacion, " +
                "c.nombre_ciudad, t.nombre_tipo " +
                "FROM propiedad p " +
                "INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                "INNER JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo " +
                "WHERE i.id_usuario = ? "
        );

        List<Object> parametros = new ArrayList<>();
        parametros.add(idUsuario);

        if (ciudad != null && !ciudad.isBlank()) {
            sql.append("AND p.id_ciudad = ? ");
            parametros.add(Integer.parseInt(ciudad));
        }

        if (tipo != null && !tipo.isBlank()) {
            sql.append("AND p.id_tipo = ? ");
            parametros.add(Integer.parseInt(tipo));
        }

        if (estado != null && !estado.isBlank()) {
            sql.append("AND p.estado = ? ");
            parametros.add(estado);
        }

        if (precioMaxTexto != null && !precioMaxTexto.isBlank()) {
            try {
                sql.append("AND p.precio <= ? ");
                parametros.add(new java.math.BigDecimal(precioMaxTexto.replace(".", "").replace(",", ".")));
            } catch (NumberFormatException ignored) {
                request.setAttribute("error", "El precio mÃ¡ximo no es vÃ¡lido");
            }
        }

        sql.append("ORDER BY p.fecha_publicacion DESC");

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < parametros.size(); i++) {
                ps.setObject(i + 1, parametros.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> p = new HashMap<>();
                    p.put("id", rs.getInt("id_propiedad"));
                    p.put("matricula", rs.getString("matricula_inmobiliaria"));
                    p.put("titulo", rs.getString("titulo"));
                    p.put("descripcion", rs.getString("descripcion"));
                    p.put("precio", rs.getBigDecimal("precio"));
                    p.put("estado", rs.getString("estado"));
                    p.put("fecha", rs.getTimestamp("fecha_publicacion"));
                    p.put("ciudad", rs.getString("nombre_ciudad"));
                    p.put("tipo", rs.getString("nombre_tipo"));
                    propiedades.add(p);
                }
            }

            cargarCiudades(con, ciudades);
            cargarTipos(con, tipos);

            request.setAttribute("propiedades", propiedades);
            request.setAttribute("ciudades", ciudades);
            request.setAttribute("tipos", tipos);

            request.getRequestDispatcher("/paneles/inmobiliaria/propiedades.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            request.setAttribute("error", "No se pudieron cargar las propiedades");
            request.setAttribute("propiedades", propiedades);
            request.setAttribute("ciudades", ciudades);
            request.setAttribute("tipos", tipos);
            request.getRequestDispatcher("/paneles/inmobiliaria/propiedades.jsp")
                    .forward(request, response);
        }
    }

    private void crearPropiedad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int idUsuario = (Integer) request.getSession().getAttribute("idUsuario");

        String matricula = request.getParameter("matricula");
        String titulo = request.getParameter("titulo");
        String descripcion = request.getParameter("descripcion");
        String precioTexto = request.getParameter("precio");
        String idCiudadTexto = request.getParameter("idCiudad");
        String idTipoTexto = request.getParameter("idTipo");
        String estado = request.getParameter("estado");

        if (vacio(matricula) || vacio(titulo) || vacio(precioTexto)
                || vacio(idCiudadTexto) || vacio(idTipoTexto)) {
            request.setAttribute("error", "Completa los campos obligatorios");
            cargarCatalogos(request);
            request.getRequestDispatcher("/paneles/inmobiliaria/registrar-propiedad.jsp")
                    .forward(request, response);
            return;
        }

        try {
            java.math.BigDecimal precio = new java.math.BigDecimal(precioTexto.replace(".", "").replace(",", "."));
            int idCiudad = Integer.parseInt(idCiudadTexto);
            int idTipo = Integer.parseInt(idTipoTexto);

            String sql =
                    "INSERT INTO propiedad " +
                    "(id_inmobiliaria, id_ciudad, id_tipo, matricula_inmobiliaria, " +
                    "titulo, descripcion, precio, estado) " +
                    "SELECT id_inmobiliaria, ?, ?, ?, ?, ?, ?, ? " +
                    "FROM inmobiliaria WHERE id_usuario = ?";

            try (Connection con = ConexionBD.obtenerConexion();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setInt(1, idCiudad);
                ps.setInt(2, idTipo);
                ps.setString(3, matricula.trim().toUpperCase());
                ps.setString(4, titulo.trim());
                ps.setString(5, descripcion == null ? "" : descripcion.trim());
                ps.setBigDecimal(6, precio);
                ps.setString(7, estadoValido(estado));
                ps.setInt(8, idUsuario);

                int filas = ps.executeUpdate();

                if (filas == 0) {
                    request.setAttribute("error", "No se encontrÃ³ una inmobiliaria asociada a tu usuario");
                    cargarCatalogos(request);
                    request.getRequestDispatcher("/paneles/inmobiliaria/registrar-propiedad.jsp")
                            .forward(request, response);
                    return;
                }
            }

            response.sendRedirect(request.getContextPath() + "/propiedades?mensaje=creada");

        } catch (NumberFormatException | SQLException e) {
            request.setAttribute("error", "No se pudo registrar la propiedad. Revisa los datos y la matrÃ­cula.");
            cargarCatalogos(request);
            request.getRequestDispatcher("/paneles/inmobiliaria/registrar-propiedad.jsp")
                    .forward(request, response);
        }
    }

    private void editarPropiedad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int idUsuario = (Integer) request.getSession().getAttribute("idUsuario");

        try {
            int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
            int idCiudad = Integer.parseInt(request.getParameter("idCiudad"));
            int idTipo = Integer.parseInt(request.getParameter("idTipo"));
            java.math.BigDecimal precio = new java.math.BigDecimal(request.getParameter("precio").replace(".", "").replace(",", "."));

            String matricula = request.getParameter("matricula");
            String titulo = request.getParameter("titulo");
            String descripcion = request.getParameter("descripcion");
            String estado = estadoValido(request.getParameter("estado"));

            if (vacio(matricula) || vacio(titulo)) {
                request.setAttribute("error", "Completa los campos obligatorios");
                cargarCatalogos(request);
                Map<String, Object> propiedad = buscarPropiedad(idPropiedad, idUsuario);
                request.setAttribute("propiedad", propiedad);
                request.getRequestDispatcher("/paneles/inmobiliaria/editar-propiedad.jsp")
                        .forward(request, response);
                return;
            }

            String sql =
                    "UPDATE propiedad p SET " +
                    "id_ciudad = ?, id_tipo = ?, matricula_inmobiliaria = ?, " +
                    "titulo = ?, descripcion = ?, precio = ?, estado = ? " +
                    "FROM inmobiliaria i " +
                    "WHERE p.id_inmobiliaria = i.id_inmobiliaria " +
                    "AND p.id_propiedad = ? AND i.id_usuario = ?";

            try (Connection con = ConexionBD.obtenerConexion();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setInt(1, idCiudad);
                ps.setInt(2, idTipo);
                ps.setString(3, matricula.trim().toUpperCase());
                ps.setString(4, titulo.trim());
                ps.setString(5, descripcion == null ? "" : descripcion.trim());
                ps.setBigDecimal(6, precio);
                ps.setString(7, estado);
                ps.setInt(8, idPropiedad);
                ps.setInt(9, idUsuario);

                int filas = ps.executeUpdate();

                if (filas == 0) {
                    response.sendRedirect(request.getContextPath() + "/propiedades?error=noEncontrada");
                    return;
                }
            }

            response.sendRedirect(request.getContextPath() + "/propiedades?mensaje=editada");

        } catch (NumberFormatException | SQLException e) {
            request.setAttribute("error", "No se pudo actualizar la propiedad. Revisa los datos.");
            response.sendRedirect(request.getContextPath() + "/propiedades?error=actualizacion");
        }
    }

    private void eliminarPropiedad(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int idUsuario = (Integer) request.getSession().getAttribute("idUsuario");

        try {
            int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));

            String sql =
                    "UPDATE propiedad p SET estado = 'INACTIVA' " +
                    "FROM inmobiliaria i " +
                    "WHERE p.id_inmobiliaria = i.id_inmobiliaria " +
                    "AND p.id_propiedad = ? AND i.id_usuario = ?";

            try (Connection con = ConexionBD.obtenerConexion();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setInt(1, idPropiedad);
                ps.setInt(2, idUsuario);
                ps.executeUpdate();
            }

            response.sendRedirect(request.getContextPath() + "/propiedades?mensaje=eliminada");

        } catch (NumberFormatException | SQLException e) {
            response.sendRedirect(request.getContextPath() + "/propiedades?error=eliminacion");
        }
    }

    private Map<String, Object> buscarPropiedad(int idPropiedad, int idUsuario)
            throws SQLException {

        String sql =
                "SELECT p.id_propiedad, p.id_ciudad, p.id_tipo, " +
                "p.matricula_inmobiliaria, p.titulo, p.descripcion, p.precio, p.estado " +
                "FROM propiedad p " +
                "INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "WHERE p.id_propiedad = ? AND i.id_usuario = ?";

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, idPropiedad);
            ps.setInt(2, idUsuario);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> p = new HashMap<>();
                    p.put("id", rs.getInt("id_propiedad"));
                    p.put("idCiudad", rs.getInt("id_ciudad"));
                    p.put("idTipo", rs.getInt("id_tipo"));
                    p.put("matricula", rs.getString("matricula_inmobiliaria"));
                    p.put("titulo", rs.getString("titulo"));
                    p.put("descripcion", rs.getString("descripcion"));
                    p.put("precio", rs.getBigDecimal("precio"));
                    p.put("estado", rs.getString("estado"));
                    return p;
                }
            }
        }

        return null;
    }

    private void cargarCatalogos(HttpServletRequest request) throws ServletException {
        try (Connection con = ConexionBD.obtenerConexion()) {
            List<String[]> ciudades = new ArrayList<>();
            List<String[]> tipos = new ArrayList<>();

            cargarCiudades(con, ciudades);
            cargarTipos(con, tipos);

            request.setAttribute("ciudades", ciudades);
            request.setAttribute("tipos", tipos);

        } catch (SQLException e) {
            throw new ServletException("No se pudieron cargar los catÃ¡logos", e);
        }
    }

    private void cargarCiudades(Connection con, List<String[]> ciudades) throws SQLException {
        String sql = "SELECT id_ciudad, nombre_ciudad FROM ciudad ORDER BY nombre_ciudad";

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ciudades.add(new String[]{
                        String.valueOf(rs.getInt("id_ciudad")),
                        rs.getString("nombre_ciudad")
                });
            }
        }
    }

    private void cargarTipos(Connection con, List<String[]> tipos) throws SQLException {
        String sql = "SELECT id_tipo, nombre_tipo FROM tipo_propiedad ORDER BY nombre_tipo";

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                tipos.add(new String[]{
                        String.valueOf(rs.getInt("id_tipo")),
                        rs.getString("nombre_tipo")
                });
            }
        }
    }

    private String estadoValido(String estado) {
        if ("VENDIDA".equals(estado) || "ARRENDADA".equals(estado)
                || "INACTIVA".equals(estado)) {
            return estado;
        }
        return "DISPONIBLE";
    }

    private boolean vacio(String valor) {
        return valor == null || valor.isBlank();
    }
    private boolean esInmobiliaria(HttpSession session) {
        if (session == null || session.getAttribute("idUsuario") == null) return false;
        @SuppressWarnings("unchecked")
        List<String> roles = (List<String>) session.getAttribute("roles");
        return roles != null && roles.contains("INMOBILIARIA");
    }

}
