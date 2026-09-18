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
private void cargarReporte(Connection con, String sql, List<Map<String, Object>> lista,
                               String columnaNombre) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> fila = new HashMap<>();
                fila.put("nombre", rs.getString(columnaNombre));
                fila.put("total", rs.getLong("total"));
                lista.add(fila);
            }
        }
    }

private void registrarAuditoria(Connection con, int idUsuario, String accion) throws SQLException {
        String sql = "INSERT INTO auditoria (id_usuario, accion) VALUES (?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
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


if (!esAdministrador(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        List<Map<String, Object>> propiedadesCiudad = new ArrayList<>();
        List<Map<String, Object>> citasEstado = new ArrayList<>();
        List<Map<String, Object>> solicitudesInmobiliaria = new ArrayList<>();

        String sqlPropiedades =
                "SELECT c.nombre_ciudad, COUNT(p.id_propiedad) AS total " +
                "FROM propiedad p " +
                "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
                "WHERE p.estado = 'DISPONIBLE' " +
                "GROUP BY c.nombre_ciudad " +
                "ORDER BY total DESC, c.nombre_ciudad";

        String sqlCitas =
                "SELECT estado, COUNT(*) AS total " +
                "FROM cita " +
                "GROUP BY estado " +
                "ORDER BY total DESC, estado";

        String sqlSolicitudes =
                "SELECT i.nombre_agencia, COUNT(s.id_solicitud) AS total " +
                "FROM solicitud s " +
                "INNER JOIN propiedad p ON s.id_propiedad = p.id_propiedad " +
                "INNER JOIN inmobiliaria i ON p.id_inmobiliaria = i.id_inmobiliaria " +
                "GROUP BY i.nombre_agencia " +
                "ORDER BY total DESC, i.nombre_agencia";

        try (Connection con = obtenerConexion()) {
            cargarReporte(con, sqlPropiedades, propiedadesCiudad, "nombre_ciudad");
            cargarReporte(con, sqlCitas, citasEstado, "estado");
            cargarReporte(con, sqlSolicitudes, solicitudesInmobiliaria, "nombre_agencia");

            request.setAttribute("propiedadesCiudad", propiedadesCiudad);
            request.setAttribute("citasEstado", citasEstado);
            request.setAttribute("solicitudesInmobiliaria", solicitudesInmobiliaria);

            registrarAuditoria(con, (Integer) session.getAttribute("idUsuario"),
                    "Consultó los reportes del administrador");

            request.getRequestDispatcher("/paneles/administrador/reportes.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("No se pudieron cargar los reportes", e);
        }
    
}
else { response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp"); }
%>
