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
private void agregar(int idUsuario, int idPropiedad) throws SQLException {
        String sql =
                "INSERT INTO favorito (id_usuario, id_propiedad) " +
                "SELECT ?, ? WHERE EXISTS (SELECT 1 FROM propiedad WHERE id_propiedad = ? AND estado = 'DISPONIBLE') " +
                "ON CONFLICT (id_usuario, id_propiedad) DO NOTHING";

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, idPropiedad);
            ps.setInt(3, idPropiedad);
            ps.executeUpdate();
        }
    }

private void quitar(int idUsuario, int idPropiedad) throws SQLException {
        String sql = "DELETE FROM favorito WHERE id_usuario = ? AND id_propiedad = ?";

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, idPropiedad);
            ps.executeUpdate();
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


if (!esCliente(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");
        List<Map<String, Object>> favoritos = new ArrayList<>();

        String sql =
                "SELECT p.id_propiedad, p.titulo, p.precio, p.estado, " +
                "c.nombre_ciudad, tp.nombre_tipo, " +
                "COALESCE((SELECT ip.url_imagen FROM imagen_propiedad ip " +
                "WHERE ip.id_propiedad = p.id_propiedad AND ip.es_principal = TRUE " +
                "ORDER BY ip.id_imagen LIMIT 1), " +
                "(SELECT ip.url_imagen FROM imagen_propiedad ip " +
                "WHERE ip.id_propiedad = p.id_propiedad ORDER BY ip.id_imagen LIMIT 1), '') AS imagen " +
                "FROM favorito f " +
                "INNER JOIN propiedad p ON p.id_propiedad = f.id_propiedad " +
                "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                "INNER JOIN tipo_propiedad tp ON tp.id_tipo = p.id_tipo " +
                "WHERE f.id_usuario = ? " +
                "ORDER BY f.fecha_marcado DESC";

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, idUsuario);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> favorito = new HashMap<>();
                    favorito.put("id", rs.getInt("id_propiedad"));
                    favorito.put("titulo", rs.getString("titulo"));
                    favorito.put("precio", rs.getBigDecimal("precio"));
                    favorito.put("estado", rs.getString("estado"));
                    favorito.put("ciudad", rs.getString("nombre_ciudad"));
                    favorito.put("tipo", rs.getString("nombre_tipo"));
                    favorito.put("imagen", rs.getString("imagen"));
                    favoritos.add(favorito);
                }
            }

            request.setAttribute("favoritos", favoritos);
            request.getRequestDispatcher("/paneles/cliente/favoritos.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            request.setAttribute("error", "No se pudieron cargar tus favoritos");
            request.setAttribute("favoritos", favoritos);
            request.getRequestDispatcher("/paneles/cliente/favoritos.jsp")
                    .forward(request, response);
        }
    
}
else if ("POST".equalsIgnoreCase(request.getMethod())) {


if (!esCliente(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String accion = request.getParameter("accion");
        String idTexto = request.getParameter("idPropiedad");

        if (idTexto == null || idTexto.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/acciones/favoritos.jsp?error=datos");
            return;
        }

        try {
            int idUsuario = (Integer) session.getAttribute("idUsuario");
            int idPropiedad = Integer.parseInt(idTexto);

            if ("agregar".equals(accion)) {
                agregar(idUsuario, idPropiedad);
                registrarAuditoria(idUsuario, "Agregó una propiedad a favoritos: " + idPropiedad);
                response.sendRedirect(request.getContextPath() + "/acciones/detalle-propiedad.jsp?id=" + idPropiedad + "&favorito=agregado");
            } else if ("quitar".equals(accion)) {
                quitar(idUsuario, idPropiedad);
                registrarAuditoria(idUsuario, "Quitó una propiedad de favoritos: " + idPropiedad);
                String volver = request.getParameter("volver");
                if ("lista".equals(volver)) {
                    response.sendRedirect(request.getContextPath() + "/acciones/favoritos.jsp?mensaje=quitado");
                } else {
                    response.sendRedirect(request.getContextPath() + "/acciones/detalle-propiedad.jsp?id=" + idPropiedad + "&favorito=quitado");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/acciones/favoritos.jsp?error=accion");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/favoritos.jsp?error=datos");
        } catch (SQLException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/favoritos.jsp?error=guardar");
        }
    
}
%>
