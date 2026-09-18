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


%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
if ("GET".equalsIgnoreCase(request.getMethod())) {


if (!esAdministrador(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        List<Map<String, Object>> registros = new ArrayList<>();
        String sql =
                "SELECT a.id_auditoria, a.id_usuario, u.correo, a.accion, a.fecha " +
                "FROM auditoria a " +
                "LEFT JOIN usuario u ON u.id_usuario = a.id_usuario " +
                "ORDER BY a.fecha DESC, a.id_auditoria DESC " +
                "LIMIT 100";

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> registro = new HashMap<>();
                registro.put("id", rs.getInt("id_auditoria"));
                registro.put("idUsuario", rs.getObject("id_usuario"));
                registro.put("correo", rs.getString("correo"));
                registro.put("accion", rs.getString("accion"));
                registro.put("fecha", rs.getTimestamp("fecha"));
                registros.add(registro);
            }

            request.setAttribute("registros", registros);
            request.getRequestDispatcher("/paneles/administrador/auditoria.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("No se pudo cargar la auditoría", e);
        }
    
}
else { response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp"); }
%>
