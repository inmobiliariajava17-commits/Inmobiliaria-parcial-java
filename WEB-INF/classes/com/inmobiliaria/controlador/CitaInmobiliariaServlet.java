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

@WebServlet("/citas-inmobiliaria")
public class CitaInmobiliariaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!esInmobiliaria(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");
        List<Map<String, Object>> citas = new ArrayList<>();

        String estado = request.getParameter("estado");

        StringBuilder sql = new StringBuilder(
                "SELECT ci.id_cita, ci.fecha_hora, ci.estado, " +
                "p.id_propiedad, p.titulo, p.matricula_inmobiliaria, " +
                "u.id_usuario AS id_cliente, u.correo, " +
                "COALESCE(pr.nombres, '') AS nombres, COALESCE(pr.apellidos, '') AS apellidos, " +
                "COALESCE(pr.telefono, '') AS telefono, c.nombre_ciudad " +
                "FROM cita ci " +
                "INNER JOIN propiedad p ON p.id_propiedad = ci.id_propiedad " +
                "INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "INNER JOIN usuario u ON u.id_usuario = ci.id_usuario " +
                "LEFT JOIN perfil pr ON pr.id_usuario = u.id_usuario " +
                "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                "WHERE i.id_usuario = ? ");

        if (estado != null && !estado.isBlank()) {
            sql.append("AND ci.estado = ? ");
        }

        sql.append("ORDER BY ci.fecha_hora ASC, ci.id_cita ASC");

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int indice = 1;
            ps.setInt(indice++, idUsuario);
            if (estado != null && !estado.isBlank()) {
                ps.setString(indice, estado);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> cita = new HashMap<>();
                    cita.put("id", rs.getInt("id_cita"));
                    cita.put("fechaHora", rs.getTimestamp("fecha_hora"));
                    cita.put("estado", rs.getString("estado"));
                    cita.put("idPropiedad", rs.getInt("id_propiedad"));
                    cita.put("titulo", rs.getString("titulo"));
                    cita.put("matricula", rs.getString("matricula_inmobiliaria"));
                    cita.put("idCliente", rs.getInt("id_cliente"));
                    cita.put("correo", rs.getString("correo"));
                    cita.put("nombres", rs.getString("nombres"));
                    cita.put("apellidos", rs.getString("apellidos"));
                    cita.put("telefono", rs.getString("telefono"));
                    cita.put("ciudad", rs.getString("nombre_ciudad"));
                    citas.add(cita);
                }
            }

            request.setAttribute("citas", citas);
            request.getRequestDispatcher("/paneles/inmobiliaria/citas.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            request.setAttribute("error", "No se pudieron cargar las citas.");
            request.setAttribute("citas", citas);
            request.getRequestDispatcher("/paneles/inmobiliaria/citas.jsp")
                    .forward(request, response);
        }
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
        String idCitaTexto = request.getParameter("idCita");

        try {
            if (idCitaTexto == null || idCitaTexto.isBlank()) {
                response.sendRedirect(request.getContextPath() + "/citas-inmobiliaria?error=datos");
                return;
            }

            int idCita = Integer.parseInt(idCitaTexto);

            if ("confirmar".equals(accion)) {
                cambiarEstado(idCita, idUsuario, "CONFIRMADA", "Confirmó la cita");
            } else if ("cancelar".equals(accion)) {
                cambiarEstado(idCita, idUsuario, "CANCELADA", "Canceló la cita");
            } else if ("realizar".equals(accion)) {
                cambiarEstado(idCita, idUsuario, "REALIZADA", "Marcó como realizada la cita");
            } else {
                response.sendRedirect(request.getContextPath() + "/citas-inmobiliaria?error=accion");
                return;
            }

            response.sendRedirect(request.getContextPath() + "/citas-inmobiliaria?mensaje=" + accion);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/citas-inmobiliaria?error=datos");
        } catch (SQLException e) {
            response.sendRedirect(request.getContextPath() + "/citas-inmobiliaria?error=guardar");
        }
    }

    private void cambiarEstado(int idCita, int idUsuario, String nuevoEstado, String accionAuditoria)
            throws SQLException {

        String sql =
                "UPDATE cita SET estado = ? " +
                "WHERE id_cita = ? " +
                "AND id_propiedad IN (" +
                "    SELECT p.id_propiedad FROM propiedad p " +
                "    INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "    WHERE i.id_usuario = ?" +
                ") " +
                "AND estado IN ('PENDIENTE', 'CONFIRMADA')";

        String estadoAnterior;
        if ("CONFIRMADA".equals(nuevoEstado)) {
            estadoAnterior = "PENDIENTE";
        } else {
            estadoAnterior = "CONFIRMADA";
        }

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, nuevoEstado);
            ps.setInt(2, idCita);
            ps.setInt(3, idUsuario);
            ps.setString(4, estadoAnterior);

            int filas = ps.executeUpdate();
            if (filas == 0) {
                throw new SQLException("La cita no existe, no pertenece a esta inmobiliaria o su estado no permite esta acción.");
            }
        }

        // La actualización de la cita ya quedó realizada.
        // La auditoría no debe impedir que el cambio de estado funcione.
        try {
            registrarAuditoria(idUsuario, accionAuditoria + ": " + idCita);
        } catch (SQLException e) {
            // Si falla la auditoría, la cita ya fue actualizada.
            // No devolvemos error al usuario por este motivo.
        }
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

    private boolean esInmobiliaria(HttpSession session) {
        if (session == null || session.getAttribute("idUsuario") == null) {
            return false;
        }

        @SuppressWarnings("unchecked")
        List<String> roles = (List<String>) session.getAttribute("roles");
        return roles != null && roles.contains("INMOBILIARIA");
    }
}
