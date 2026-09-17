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
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/citas")
public class CitaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!esCliente(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");

        if ("horarios".equals(request.getParameter("accion"))) {
            cargarHorariosOcupados(request, response);
            return;
        }

        List<Map<String, Object>> citas = new ArrayList<>();

        String sql =
                "SELECT ci.id_cita, ci.id_propiedad, ci.fecha_hora, ci.estado, " +
                "p.titulo, c.nombre_ciudad, tp.nombre_tipo " +
                "FROM cita ci " +
                "INNER JOIN propiedad p ON p.id_propiedad = ci.id_propiedad " +
                "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                "INNER JOIN tipo_propiedad tp ON tp.id_tipo = p.id_tipo " +
                "WHERE ci.id_usuario = ? " +
                "ORDER BY ci.fecha_hora DESC";

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, idUsuario);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> cita = new HashMap<>();
                    cita.put("id", rs.getInt("id_cita"));
                    cita.put("idPropiedad", rs.getInt("id_propiedad"));
                    cita.put("fechaHora", rs.getTimestamp("fecha_hora"));
                    cita.put("estado", rs.getString("estado"));
                    cita.put("titulo", rs.getString("titulo"));
                    cita.put("ciudad", rs.getString("nombre_ciudad"));
                    cita.put("tipo", rs.getString("nombre_tipo"));
                    citas.add(cita);
                }
            }

            request.setAttribute("citas", citas);
            request.getRequestDispatcher("/paneles/cliente/citas.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            request.setAttribute("error", "No se pudieron cargar tus citas.");
            request.setAttribute("citas", citas);
            request.getRequestDispatcher("/paneles/cliente/citas.jsp")
                    .forward(request, response);
        }
    }

    private void cargarHorariosOcupados(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idPropiedadTexto = request.getParameter("idPropiedad");
        String fechaTexto = request.getParameter("fecha");

        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        if (idPropiedadTexto == null || fechaTexto == null || idPropiedadTexto.isBlank() || fechaTexto.isBlank()) {
            response.getWriter().print("[]");
            return;
        }

        try {
            int idPropiedad = Integer.parseInt(idPropiedadTexto);
            LocalDate fecha = LocalDate.parse(fechaTexto);

            String sql =
                    "SELECT fecha_hora FROM cita " +
                    "WHERE id_propiedad = ? AND DATE(fecha_hora) = ? " +
                    "AND estado <> 'CANCELADA' ORDER BY fecha_hora";

            List<String> ocupados = new ArrayList<>();

            try (Connection con = ConexionBD.obtenerConexion();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setInt(1, idPropiedad);
                ps.setObject(2, fecha);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        LocalTime hora = rs.getTimestamp("fecha_hora").toLocalDateTime().toLocalTime();
                        ocupados.add(String.format("%02d:%02d", hora.getHour(), hora.getMinute()));
                    }
                }
            }

            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < ocupados.size(); i++) {
                if (i > 0) json.append(",");
                json.append("\"").append(ocupados.get(i)).append("\"");
            }
            json.append("]");
            response.getWriter().print(json);

        } catch (Exception e) {
            response.getWriter().print("[]");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!esCliente(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String accion = request.getParameter("accion");
        int idUsuario = (Integer) session.getAttribute("idUsuario");

        try {
            if ("agendar".equals(accion)) {
                agendar(request, response, idUsuario);
            } else if ("cancelar".equals(accion)) {
                cancelar(request, response, idUsuario);
            } else {
                response.sendRedirect(request.getContextPath() + "/citas?error=accion");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/citas?error=datos");
        } catch (SQLException e) {
            response.sendRedirect(request.getContextPath() + "/citas?error=guardar");
        }
    }

    private void agendar(HttpServletRequest request, HttpServletResponse response, int idUsuario)
            throws SQLException, IOException {

        String idPropiedadTexto = request.getParameter("idPropiedad");
        String fechaTexto = request.getParameter("fechaVisita");
        String horaTexto = request.getParameter("horaVisita");

        if (idPropiedadTexto == null || fechaTexto == null || horaTexto == null
                || idPropiedadTexto.isBlank() || fechaTexto.isBlank() || horaTexto.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/citas?error=datos");
            return;
        }

        int idPropiedad = Integer.parseInt(idPropiedadTexto);
        LocalDateTime fechaHora;

        try {
            LocalDate fecha = LocalDate.parse(fechaTexto);
            LocalTime hora = LocalTime.parse(horaTexto);
            fechaHora = LocalDateTime.of(fecha, hora);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/propiedad?id=" + idPropiedad + "&cita=fecha");
            return;
        }

        if (!esHorarioValido(fechaHora.toLocalTime())) {
            response.sendRedirect(request.getContextPath() + "/propiedad?id=" + idPropiedad + "&cita=horario");
            return;
        }

        if (!fechaHora.isAfter(LocalDateTime.now())) {
            response.sendRedirect(request.getContextPath() + "/propiedad?id=" + idPropiedad + "&cita=pasada");
            return;
        }

        String verificarPropiedad =
                "SELECT 1 FROM propiedad WHERE id_propiedad = ? AND estado = 'DISPONIBLE'";

        String insertar =
                "INSERT INTO cita (id_propiedad, id_usuario, fecha_hora, estado) VALUES (?, ?, ?, 'PENDIENTE')";

        try (Connection con = ConexionBD.obtenerConexion()) {
            try (PreparedStatement ps = con.prepareStatement(verificarPropiedad)) {
                ps.setInt(1, idPropiedad);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect(request.getContextPath() + "/propiedad?id=" + idPropiedad + "&cita=no-disponible");
                        return;
                    }
                }
            }

            String reutilizarCancelada =
                    "UPDATE cita SET id_usuario = ?, estado = 'PENDIENTE' " +
                    "WHERE id_propiedad = ? AND fecha_hora = ? AND estado = 'CANCELADA'";

            try (PreparedStatement ps = con.prepareStatement(reutilizarCancelada)) {
                ps.setInt(1, idUsuario);
                ps.setInt(2, idPropiedad);
                ps.setTimestamp(3, Timestamp.valueOf(fechaHora));

                int filas = ps.executeUpdate();

                if (filas == 0) {
                    try (PreparedStatement insertarPs = con.prepareStatement(insertar)) {
                        insertarPs.setInt(1, idPropiedad);
                        insertarPs.setInt(2, idUsuario);
                        insertarPs.setTimestamp(3, Timestamp.valueOf(fechaHora));
                        insertarPs.executeUpdate();
                    }
                }
            }
        }

        registrarAuditoria(idUsuario, "Agendó una cita para la propiedad: " + idPropiedad);
        response.sendRedirect(request.getContextPath() + "/citas?mensaje=agendada");
    }

    private boolean esHorarioValido(LocalTime hora) {
        LocalTime inicio = LocalTime.of(8, 0);
        LocalTime fin = LocalTime.of(17, 45);

        if (hora.isBefore(inicio) || hora.isAfter(fin)) {
            return false;
        }

        int minutosDesdeInicio = (hora.getHour() * 60 + hora.getMinute()) - (8 * 60);
        return hora.getSecond() == 0 && minutosDesdeInicio % 45 == 0;
    }

    private void cancelar(HttpServletRequest request, HttpServletResponse response, int idUsuario)
            throws SQLException, IOException {

        String idCitaTexto = request.getParameter("idCita");
        if (idCitaTexto == null || idCitaTexto.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/citas?error=datos");
            return;
        }

        int idCita = Integer.parseInt(idCitaTexto);

        String sql =
                "UPDATE cita SET estado = 'CANCELADA' " +
                "WHERE id_cita = ? AND id_usuario = ? AND estado IN ('PENDIENTE', 'CONFIRMADA')";

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, idCita);
            ps.setInt(2, idUsuario);

            int filas = ps.executeUpdate();
            if (filas == 0) {
                response.sendRedirect(request.getContextPath() + "/citas?error=cancelar");
                return;
            }
        }

        registrarAuditoria(idUsuario, "Canceló la cita: " + idCita);
        response.sendRedirect(request.getContextPath() + "/citas?mensaje=cancelada");
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

    private boolean esCliente(HttpSession session) {
        if (session == null || session.getAttribute("idUsuario") == null) {
            return false;
        }

        @SuppressWarnings("unchecked")
        List<String> roles = (List<String>) session.getAttribute("roles");
        return roles != null && roles.contains("CLIENTE");
    }
}
