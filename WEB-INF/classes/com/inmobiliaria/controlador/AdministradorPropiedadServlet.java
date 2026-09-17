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

@WebServlet("/administrador/propiedades")
public class AdministradorPropiedadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!esAdministrador(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        cargarPropiedades(request);
        request.getRequestDispatcher("/paneles/administrador/propiedades.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (!esAdministrador(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String accion = request.getParameter("accion");
        if (!"estado".equals(accion)) {
            response.sendRedirect(request.getContextPath() + "/administrador/propiedades");
            return;
        }

        try {
            int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
            String estado = request.getParameter("estado");

            if (!estadoValido(estado)) {
                response.sendRedirect(request.getContextPath() + "/administrador/propiedades?error=estado");
                return;
            }

            String sql = "UPDATE propiedad SET estado = ? WHERE id_propiedad = ?";
            try (Connection con = ConexionBD.obtenerConexion();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, estado);
                ps.setInt(2, idPropiedad);
                int filas = ps.executeUpdate();

                if (filas == 0) {
                    response.sendRedirect(request.getContextPath() + "/administrador/propiedades?error=noEncontrada");
                    return;
                }
            }

            registrarAuditoria((Integer) session.getAttribute("idUsuario"),
                    "Cambió el estado de la propiedad " + idPropiedad + " a " + estado);

            response.sendRedirect(request.getContextPath() + "/administrador/propiedades?mensaje=estado");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/administrador/propiedades?error=datos");
        } catch (SQLException e) {
            response.sendRedirect(request.getContextPath() + "/administrador/propiedades?error=bd");
        }
    }

    private boolean esAdministrador(HttpSession session) {
        if (session == null || session.getAttribute("idUsuario") == null) {
            return false;
        }

        @SuppressWarnings("unchecked")
        List<String> roles = (List<String>) session.getAttribute("roles");
        return roles != null && roles.contains("ADMINISTRADOR");
    }

    private void cargarPropiedades(HttpServletRequest request) throws ServletException {
        List<Map<String, Object>> propiedades = new ArrayList<>();
        List<String[]> ciudades = new ArrayList<>();
        List<String[]> tipos = new ArrayList<>();

        String ciudad = request.getParameter("ciudad");
        String tipo = request.getParameter("tipo");
        String estado = request.getParameter("estado");

        StringBuilder sql = new StringBuilder(
                "SELECT p.id_propiedad, p.matricula_inmobiliaria, p.titulo, " +
                "p.descripcion, p.precio, p.estado, p.fecha_publicacion, " +
                "c.nombre_ciudad, t.nombre_tipo, i.nombre_agencia, " +
                "COALESCE((SELECT ip.url_imagen FROM imagen_propiedad ip " +
                "WHERE ip.id_propiedad = p.id_propiedad ORDER BY ip.es_principal DESC, ip.id_imagen LIMIT 1), '') AS imagen " +
                "FROM propiedad p " +
                "INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                "INNER JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo " +
                "WHERE 1=1 ");

        List<Object> parametros = new ArrayList<>();

        try {
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
                        p.put("agencia", rs.getString("nombre_agencia"));
                        p.put("imagen", rs.getString("imagen"));
                        propiedades.add(p);
                    }
                }
            }

            cargarCatalogos(ciudades, tipos);

            request.setAttribute("propiedades", propiedades);
            request.setAttribute("ciudades", ciudades);
            request.setAttribute("tipos", tipos);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Los filtros seleccionados no son válidos");
            cargarCatalogosSeguro(request, ciudades, tipos);
            request.setAttribute("propiedades", propiedades);
        } catch (SQLException e) {
            throw new ServletException("No se pudieron cargar las propiedades", e);
        }
    }

    private void cargarCatalogos(List<String[]> ciudades, List<String[]> tipos) throws SQLException {
        try (Connection con = ConexionBD.obtenerConexion()) {
            String sqlCiudades = "SELECT id_ciudad, nombre_ciudad FROM ciudad ORDER BY nombre_ciudad";
            try (PreparedStatement ps = con.prepareStatement(sqlCiudades);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ciudades.add(new String[]{String.valueOf(rs.getInt("id_ciudad")), rs.getString("nombre_ciudad")});
                }
            }

            String sqlTipos = "SELECT id_tipo, nombre_tipo FROM tipo_propiedad ORDER BY nombre_tipo";
            try (PreparedStatement ps = con.prepareStatement(sqlTipos);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tipos.add(new String[]{String.valueOf(rs.getInt("id_tipo")), rs.getString("nombre_tipo")});
                }
            }
        }
    }

    private void cargarCatalogosSeguro(HttpServletRequest request, List<String[]> ciudades, List<String[]> tipos) {
        try {
            cargarCatalogos(ciudades, tipos);
        } catch (SQLException ignored) {
        }
        request.setAttribute("ciudades", ciudades);
        request.setAttribute("tipos", tipos);
    }

    private boolean estadoValido(String estado) {
        return "DISPONIBLE".equals(estado)
                || "ARRENDADA".equals(estado)
                || "VENDIDA".equals(estado)
                || "INACTIVA".equals(estado);
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
}
