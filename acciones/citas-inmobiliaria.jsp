<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="javax.servlet.ServletException" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%!
private void cambiarEstado(int idCita, int idUsuario, String nuevoEstado, String accionAuditoria)
            throws SQLException {

        String condicionEstado;
        if ("CONFIRMADA".equals(nuevoEstado)) {
            condicionEstado = "AND estado = 'PENDIENTE'";
        } else if ("REALIZADA".equals(nuevoEstado)) {
            condicionEstado = "AND estado = 'CONFIRMADA'";
        } else {
            condicionEstado = "AND estado IN ('PENDIENTE', 'CONFIRMADA')";
        }

        String sql =
                "UPDATE cita SET estado = ? " +
                "WHERE id_cita = ? " +
                "AND id_propiedad IN (" +
                "    SELECT p.id_propiedad FROM propiedad p " +
                "    INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "    WHERE i.id_usuario = ?" +
                ") " +
                condicionEstado;

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, nuevoEstado);
            ps.setInt(2, idCita);
            ps.setInt(3, idUsuario);

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
        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setString(2, accion);
            ps.executeUpdate();
        }
    }



%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
if ("GET".equalsIgnoreCase(request.getMethod())) {


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

        try (Connection con = obtenerConexion();
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
else if ("POST".equalsIgnoreCase(request.getMethod())) {


if (!esInmobiliaria(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");
        String accion = request.getParameter("accion");
        String idCitaTexto = request.getParameter("idCita");

        try {
            if (idCitaTexto == null || idCitaTexto.isBlank()) {
                response.sendRedirect(request.getContextPath() + "/acciones/citas-inmobiliaria.jsp?error=datos");
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
                response.sendRedirect(request.getContextPath() + "/acciones/citas-inmobiliaria.jsp?error=accion");
                return;
            }

            response.sendRedirect(request.getContextPath() + "/acciones/citas-inmobiliaria.jsp?mensaje=" + accion);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/citas-inmobiliaria.jsp?error=datos");
        } catch (SQLException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/citas-inmobiliaria.jsp?error=guardar");
        }
    
}
%>
