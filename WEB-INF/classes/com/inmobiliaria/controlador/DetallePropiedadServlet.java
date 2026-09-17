package com.inmobiliaria.controlador;

import com.inmobiliaria.util.ConexionBD;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/propiedad")
public class DetallePropiedadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        if ("horarios".equals(request.getParameter("accion"))) {
            cargarHorariosOcupados(request, response);
            return;
        }

        String idTexto = request.getParameter("id");

        if (idTexto == null || idTexto.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        try {
            int idPropiedad = Integer.parseInt(idTexto);
            cargarDetalle(request, idPropiedad);

            if (request.getAttribute("propiedad") == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Propiedad no encontrada");
                return;
            }

            request.getRequestDispatcher("/propiedad.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Identificador de propiedad inválido");
        } catch (SQLException e) {
            request.setAttribute("error", "No se pudo cargar la información de la propiedad");
            request.getRequestDispatcher("/propiedad.jsp").forward(request, response);
        }
    }

    private void cargarDetalle(HttpServletRequest request, int idPropiedad) throws SQLException {
        String sql =
                "SELECT p.id_propiedad, p.matricula_inmobiliaria, p.titulo, p.descripcion, " +
                "p.precio, p.estado, p.fecha_publicacion, c.nombre_ciudad, " +
                "tp.nombre_tipo, i.nombre_agencia " +
                "FROM propiedad p " +
                "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
                "INNER JOIN tipo_propiedad tp ON p.id_tipo = tp.id_tipo " +
                "INNER JOIN inmobiliaria i ON p.id_inmobiliaria = i.id_inmobiliaria " +
                "WHERE p.id_propiedad = ? AND p.estado = 'DISPONIBLE'";

        Map<String, Object> propiedad = null;
        List<String> imagenes = new ArrayList<>();
        List<Map<String, Object>> caracteristicas = new ArrayList<>();

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, idPropiedad);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    propiedad = new HashMap<>();
                    propiedad.put("id", rs.getInt("id_propiedad"));
                    propiedad.put("matricula", rs.getString("matricula_inmobiliaria"));
                    propiedad.put("titulo", rs.getString("titulo"));
                    propiedad.put("descripcion", rs.getString("descripcion"));
                    propiedad.put("precio", rs.getBigDecimal("precio"));
                    propiedad.put("estado", rs.getString("estado"));
                    propiedad.put("fechaPublicacion", rs.getTimestamp("fecha_publicacion"));
                    propiedad.put("ciudad", rs.getString("nombre_ciudad"));
                    propiedad.put("tipo", rs.getString("nombre_tipo"));
                    propiedad.put("agencia", rs.getString("nombre_agencia"));
                }
            }
        }

        if (propiedad == null) {
            request.setAttribute("propiedad", null);
            return;
        }

        String sqlImagenes =
                "SELECT url_imagen FROM imagen_propiedad " +
                "WHERE id_propiedad = ? ORDER BY es_principal DESC, id_imagen";

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sqlImagenes)) {
            ps.setInt(1, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    imagenes.add(rs.getString("url_imagen"));
                }
            }
        }

        String sqlCaracteristicas =
                "SELECT c.nombre, pc.cantidad " +
                "FROM propiedad_caracteristica pc " +
                "INNER JOIN caracteristica c ON pc.id_caracteristica = c.id_caracteristica " +
                "WHERE pc.id_propiedad = ? ORDER BY c.nombre";

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sqlCaracteristicas)) {
            ps.setInt(1, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> fila = new HashMap<>();
                    fila.put("nombre", rs.getString("nombre"));
                    fila.put("cantidad", rs.getInt("cantidad"));
                    caracteristicas.add(fila);
                }
            }
        }

        request.setAttribute("propiedad", propiedad);
        request.setAttribute("imagenes", imagenes);
        request.setAttribute("caracteristicas", caracteristicas);

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("idUsuario") != null) {
            @SuppressWarnings("unchecked")
            List<String> roles = (List<String>) session.getAttribute("roles");
            if (roles != null && roles.contains("CLIENTE")) {
                int idUsuario = (Integer) session.getAttribute("idUsuario");
                String sqlFavorito = "SELECT 1 FROM favorito WHERE id_usuario = ? AND id_propiedad = ?";
                try (Connection con = ConexionBD.obtenerConexion();
                     PreparedStatement ps = con.prepareStatement(sqlFavorito)) {
                    ps.setInt(1, idUsuario);
                    ps.setInt(2, idPropiedad);
                    try (ResultSet rs = ps.executeQuery()) {
                        request.setAttribute("esFavorito", rs.next());
                    }
                }
            }
        }
    }
    private void cargarHorariosOcupados(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idPropiedadTexto = request.getParameter("idPropiedad");
        String fechaTexto = request.getParameter("fecha");

        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        if (idPropiedadTexto == null || fechaTexto == null
                || idPropiedadTexto.isBlank() || fechaTexto.isBlank()) {
            response.getWriter().print("[]");
            return;
        }

        try {
            int idPropiedad = Integer.parseInt(idPropiedadTexto);
            LocalDate fecha = LocalDate.parse(fechaTexto);

            String sql =
                    "SELECT fecha_hora FROM cita " +
                    "WHERE id_propiedad = ? AND fecha_hora::date = ? " +
                    "AND estado <> 'CANCELADA' ORDER BY fecha_hora";

            StringBuilder json = new StringBuilder("[");
            boolean primero = true;

            try (Connection con = ConexionBD.obtenerConexion();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setInt(1, idPropiedad);
                ps.setDate(2, java.sql.Date.valueOf(fecha));

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        LocalTime hora = rs.getTimestamp("fecha_hora")
                                .toLocalDateTime().toLocalTime();

                        if (!primero) {
                            json.append(",");
                        }
                        json.append("\"")
                                .append(String.format("%02d:%02d", hora.getHour(), hora.getMinute()))
                                .append("\"");
                        primero = false;
                    }
                }
            }

            json.append("]");
            response.getWriter().print(json);

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"error\":\"No se pudieron consultar los horarios\"}");
        }
    }

}
