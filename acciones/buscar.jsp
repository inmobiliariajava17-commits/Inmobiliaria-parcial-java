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

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String ciudad = request.getParameter("ciudad");
        String tipo = request.getParameter("tipo");

        StringBuilder sql = new StringBuilder(
            "SELECT p.id_propiedad, p.titulo, p.precio, p.estado, " +
            "c.nombre_ciudad, tp.nombre_tipo, " +
            "COALESCE((SELECT ip.url_imagen FROM imagen_propiedad ip " +
            "WHERE ip.id_propiedad = p.id_propiedad ORDER BY ip.es_principal DESC, ip.id_imagen LIMIT 1), '') AS imagen " +
            "FROM propiedad p " +
            "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
            "INNER JOIN tipo_propiedad tp ON p.id_tipo = tp.id_tipo " +
            "WHERE p.estado = 'DISPONIBLE' "
        );

        if (ciudad != null && !ciudad.isBlank()) {
            sql.append("AND c.nombre_ciudad = ? ");
        }
        if (tipo != null && !tipo.isBlank()) {
            sql.append("AND tp.nombre_tipo = ? ");
        }
        sql.append("ORDER BY p.fecha_publicacion DESC");

        List<Map<String, Object>> resultados = new ArrayList<>();

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int indice = 1;
            if (ciudad != null && !ciudad.isBlank()) {
                ps.setString(indice++, ciudad);
            }
            if (tipo != null && !tipo.isBlank()) {
                ps.setString(indice++, tipo);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> fila = new HashMap<>();
                    fila.put("id", rs.getInt("id_propiedad"));
                    fila.put("titulo", rs.getString("titulo"));
                    fila.put("precio", rs.getBigDecimal("precio"));
                    fila.put("ciudad", rs.getString("nombre_ciudad"));
                    fila.put("tipo", rs.getString("nombre_tipo"));
                    fila.put("imagen", rs.getString("imagen"));
                    resultados.add(fila);
                }
            }

        } catch (SQLException e) {
            request.setAttribute("error", "Ocurrió un error al buscar propiedades");
        }

        request.setAttribute("resultados", resultados);
        request.setAttribute("ciudadBuscada", ciudad);
        request.setAttribute("tipoBuscado", tipo);
        request.getRequestDispatcher("/resultados.jsp").forward(request, response);
    
}
else { response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp"); }
%>
