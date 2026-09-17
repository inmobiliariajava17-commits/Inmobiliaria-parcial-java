package com.inmobiliaria.controlador;

import com.inmobiliaria.util.ConexionBD;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/solicitudes-inmobiliaria")
public class SolicitudInmobiliariaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!esInmobiliaria(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");
        String estado = request.getParameter("estado");
        String idSolicitudTexto = request.getParameter("idSolicitud");

        try {
            if (idSolicitudTexto != null && !idSolicitudTexto.isBlank()) {
                int idSolicitud = Integer.parseInt(idSolicitudTexto);
                cargarDetalle(request, idSolicitud, idUsuario);
            }
            cargarSolicitudes(request, idUsuario, estado);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/solicitudes-inmobiliaria?error=datos");
            return;
        } catch (SQLException e) {
            request.setAttribute("error", "No se pudieron cargar las solicitudes.");
        }

        request.getRequestDispatcher("/paneles/inmobiliaria/solicitudes.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!esInmobiliaria(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");
        String accion = request.getParameter("accion");
        String idSolicitudTexto = request.getParameter("idSolicitud");

        try {
            if (idSolicitudTexto == null || idSolicitudTexto.isBlank()) {
                response.sendRedirect(request.getContextPath() + "/solicitudes-inmobiliaria?error=datos");
                return;
            }

            int idSolicitud = Integer.parseInt(idSolicitudTexto);
            String nuevoEstado;
            String textoAuditoria;

            if ("aprobar".equals(accion)) {
                nuevoEstado = "APROBADA";
                textoAuditoria = "Aprobó la solicitud";
            } else if ("rechazar".equals(accion)) {
                nuevoEstado = "RECHAZADA";
                textoAuditoria = "Rechazó la solicitud";
            } else {
                response.sendRedirect(request.getContextPath() + "/solicitudes-inmobiliaria?error=accion");
                return;
            }

            cambiarEstado(idSolicitud, idUsuario, nuevoEstado, textoAuditoria);
            response.sendRedirect(request.getContextPath() + "/solicitudes-inmobiliaria?idSolicitud=" + idSolicitud + "&mensaje=" + accion);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/solicitudes-inmobiliaria?error=datos");
        } catch (SQLException e) {
            response.sendRedirect(request.getContextPath() + "/solicitudes-inmobiliaria?error=guardar");
        }
    }

    private void cargarSolicitudes(HttpServletRequest request, int idUsuario, String estado) throws SQLException {
        List<Map<String, Object>> solicitudes = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT s.id_solicitud, s.id_propiedad, s.id_usuario, s.tipo, s.estado, s.fecha_solicitud, " +
                "p.titulo, p.matricula_inmobiliaria, c.nombre_ciudad, " +
                "u.correo, COALESCE(pr.nombres, '') AS nombres, COALESCE(pr.apellidos, '') AS apellidos, " +
                "(SELECT COUNT(*) FROM documento_solicitud d WHERE d.id_solicitud = s.id_solicitud) AS cantidad_documentos " +
                "FROM solicitud s " +
                "INNER JOIN propiedad p ON p.id_propiedad = s.id_propiedad " +
                "INNER JOIN usuario u ON u.id_usuario = s.id_usuario " +
                "LEFT JOIN perfil pr ON pr.id_usuario = u.id_usuario " +
                "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                "WHERE p.id_inmobiliaria = (SELECT i.id_inmobiliaria FROM inmobiliaria i WHERE i.id_usuario = ?) ");

        if (estado != null && !estado.isBlank()) {
            sql.append("AND s.estado = ? ");
        }
        sql.append("ORDER BY s.fecha_solicitud DESC");

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int indice = 1;
            ps.setInt(indice++, idUsuario);
            if (estado != null && !estado.isBlank()) {
                ps.setString(indice, estado);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> s = new HashMap<>();
                    s.put("id", rs.getInt("id_solicitud"));
                    s.put("idPropiedad", rs.getInt("id_propiedad"));
                    s.put("idUsuario", rs.getInt("id_usuario"));
                    s.put("tipo", rs.getString("tipo"));
                    s.put("estado", rs.getString("estado"));
                    s.put("fecha", rs.getTimestamp("fecha_solicitud"));
                    s.put("titulo", rs.getString("titulo"));
                    s.put("matricula", rs.getString("matricula_inmobiliaria"));
                    s.put("ciudad", rs.getString("nombre_ciudad"));
                    s.put("correo", rs.getString("correo"));
                    s.put("nombres", rs.getString("nombres"));
                    s.put("apellidos", rs.getString("apellidos"));
                    s.put("documentos", rs.getInt("cantidad_documentos"));
                    solicitudes.add(s);
                }
            }
        }

        request.setAttribute("solicitudes", solicitudes);
    }

    private void cargarDetalle(HttpServletRequest request, int idSolicitud, int idUsuario) throws SQLException {
        String sql =
                "SELECT s.id_solicitud, s.id_propiedad, s.id_usuario, s.tipo, s.estado, s.fecha_solicitud, " +
                "p.titulo, p.matricula_inmobiliaria, c.nombre_ciudad, u.correo, " +
                "COALESCE(pr.nombres, '') AS nombres, COALESCE(pr.apellidos, '') AS apellidos, COALESCE(pr.telefono, '') AS telefono " +
                "FROM solicitud s " +
                "INNER JOIN propiedad p ON p.id_propiedad = s.id_propiedad " +
                "INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "INNER JOIN usuario u ON u.id_usuario = s.id_usuario " +
                "LEFT JOIN perfil pr ON pr.id_usuario = u.id_usuario " +
                "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                "WHERE s.id_solicitud = ? AND i.id_usuario = ?";

        Map<String, Object> solicitud = new HashMap<>();
        try (Connection con = ConexionBD.obtenerConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idSolicitud);
            ps.setInt(2, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return;
                solicitud.put("id", rs.getInt("id_solicitud"));
                solicitud.put("idPropiedad", rs.getInt("id_propiedad"));
                solicitud.put("idUsuario", rs.getInt("id_usuario"));
                solicitud.put("tipo", rs.getString("tipo"));
                solicitud.put("estado", rs.getString("estado"));
                solicitud.put("fecha", rs.getTimestamp("fecha_solicitud"));
                solicitud.put("titulo", rs.getString("titulo"));
                solicitud.put("matricula", rs.getString("matricula_inmobiliaria"));
                solicitud.put("ciudad", rs.getString("nombre_ciudad"));
                solicitud.put("correo", rs.getString("correo"));
                solicitud.put("nombres", rs.getString("nombres"));
                solicitud.put("apellidos", rs.getString("apellidos"));
                solicitud.put("telefono", rs.getString("telefono"));
            }
        }

        if (solicitud.isEmpty()) return;
        request.setAttribute("solicitudDetalle", solicitud);

        List<Map<String, Object>> documentos = new ArrayList<>();
        String docSql = "SELECT id_documento, url_documento, nombre_documento, tipo_documento, fecha_carga FROM documento_solicitud WHERE id_solicitud = ? ORDER BY fecha_carga ASC";
        try (Connection con = ConexionBD.obtenerConexion(); PreparedStatement ps = con.prepareStatement(docSql)) {
            ps.setInt(1, idSolicitud);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> d = new HashMap<>();
                    d.put("id", rs.getInt("id_documento"));
                    d.put("url", rs.getString("url_documento"));
                    d.put("nombre", rs.getString("nombre_documento"));
                    d.put("tipo", rs.getString("tipo_documento"));
                    d.put("fecha", rs.getTimestamp("fecha_carga"));
                    documentos.add(d);
                }
            }
        }
        request.setAttribute("documentosDetalle", documentos);
    }

    private void cambiarEstado(int idSolicitud, int idUsuario, String nuevoEstado, String accionAuditoria) throws SQLException {
        String sql =
                "UPDATE solicitud SET estado = ? " +
                "WHERE id_solicitud = ? AND estado = 'EN_REVISION' " +
                "AND id_propiedad IN (SELECT p.id_propiedad FROM propiedad p INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria WHERE i.id_usuario = ?)";

        try (Connection con = ConexionBD.obtenerConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idSolicitud);
            ps.setInt(3, idUsuario);
            if (ps.executeUpdate() == 0) {
                throw new SQLException("La solicitud no existe, no pertenece a esta inmobiliaria o no está en revisión.");
            }
        }

        try {
            registrarAuditoria(idUsuario, accionAuditoria + ": " + idSolicitud);
        } catch (SQLException ignored) {
            // La solicitud ya fue actualizada.
        }
    }

    private void registrarAuditoria(int idUsuario, String accion) throws SQLException {
        String sql = "INSERT INTO auditoria (id_usuario, accion) VALUES (?, ?)";
        try (Connection con = ConexionBD.obtenerConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setString(2, accion);
            ps.executeUpdate();
        }
    }

    private boolean esInmobiliaria(HttpSession session) {
        if (session == null || session.getAttribute("idUsuario") == null) return false;
        @SuppressWarnings("unchecked")
        List<String> roles = (List<String>) session.getAttribute("roles");
        return roles != null && roles.contains("INMOBILIARIA");
    }
}
