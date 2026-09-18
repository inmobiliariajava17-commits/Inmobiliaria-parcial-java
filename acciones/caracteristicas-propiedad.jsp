<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%!
private boolean esPropiedadDeUsuario(int idPropiedad, int idUsuario) throws SQLException {
        String sql = "SELECT 1 FROM propiedad p INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "WHERE p.id_propiedad = ? AND i.id_usuario = ?";
        try (Connection con = obtenerConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad); ps.setInt(2, idUsuario);
            try (java.sql.ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }



%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
if ("GET".equalsIgnoreCase(request.getMethod())) {
    response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
}
else if ("POST".equalsIgnoreCase(request.getMethod())) {

        request.setCharacterEncoding("UTF-8");
if (!esInmobiliaria(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");
        String idPropiedadTexto = request.getParameter("idPropiedad");
        try {
            int idPropiedad = Integer.parseInt(idPropiedadTexto);
            if (!esPropiedadDeUsuario(idPropiedad, idUsuario)) {
                response.sendRedirect(request.getContextPath() + "/acciones/propiedades.jsp?error=noEncontrada");
                return;
            }

            String[] ids = request.getParameterValues("caracteristica");

            try (Connection con = obtenerConexion()) {
                con.setAutoCommit(false);
                try {
                    try (PreparedStatement ps = con.prepareStatement("DELETE FROM propiedad_caracteristica WHERE id_propiedad = ?")) {
                        ps.setInt(1, idPropiedad);
                        ps.executeUpdate();
                    }

                    if (ids != null) {
                        String sql = "INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica, cantidad) VALUES (?, ?, ?)";
                        try (PreparedStatement ps = con.prepareStatement(sql)) {
                            for (int i = 0; i < ids.length; i++) {
                                int idCaracteristica = Integer.parseInt(ids[i]);
                                int cantidad = 1;
                                String cantidadTexto = request.getParameter("cantidad_" + idCaracteristica);
                                if (cantidadTexto != null) {
                                    try { cantidad = Math.max(1, Integer.parseInt(cantidadTexto)); } catch (NumberFormatException ignored) {}
                                }
                                ps.setInt(1, idPropiedad);
                                ps.setInt(2, idCaracteristica);
                                ps.setInt(3, cantidad);
                                ps.addBatch();
                            }
                            ps.executeBatch();
                        }
                    }
                    con.commit();
                } catch (SQLException e) {
                    con.rollback();
                    throw e;
                } finally {
                    con.setAutoCommit(true);
                }
            }

            response.sendRedirect(request.getContextPath() + "/acciones/imagenes-propiedad.jsp?id=" + idPropiedad + "&mensaje=caracteristicas");
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/propiedades.jsp?error=datos");
        } catch (SQLException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/imagenes-propiedad.jsp?id=" + idPropiedadTexto + "&error=caracteristicas");
        }
    
}
%>
