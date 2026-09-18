<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="javax.servlet.ServletException" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%!


private void cargarPropiedades(HttpServletRequest request) throws ServletException {
        List<Map<String, Object>> propiedades = new ArrayList<>();
        List<String[]> ciudades = new ArrayList<>();
        List<String[]> tipos = new ArrayList<>();

        String ciudad = request.getParameter("ciudad");
        String tipo = request.getParameter("tipo");
        String estado = request.getParameter("estado");

        StringBuilder sql = new StringBuilder(
                "SELECT p.id_propiedad, p.matricula_inmobiliaria, p.titulo, " +
                "p.descripcion, p.precio, p.estado, p.fecha_publicacion, " +
                "c.nombre_ciudad, t.nombre_tipo, i.nombre_agencia, " +
                "COALESCE((SELECT ip.url_imagen FROM imagen_propiedad ip " +
                "WHERE ip.id_propiedad = p.id_propiedad ORDER BY ip.es_principal DESC, ip.id_imagen LIMIT 1), '') AS imagen " +
                "FROM propiedad p " +
                "INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                "INNER JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo " +
                "WHERE 1=1 ");

        List<Object> parametros = new ArrayList<>();

        try {
            if (ciudad != null && !ciudad.isBlank()) {
                sql.append("AND p.id_ciudad = ? ");
                parametros.add(Integer.parseInt(ciudad));
            }

            if (tipo != null && !tipo.isBlank()) {
                sql.append("AND p.id_tipo = ? ");
                parametros.add(Integer.parseInt(tipo));
            }

            if (estado != null && !estado.isBlank()) {
                sql.append("AND p.estado = ? ");
                parametros.add(estado);
            }

            sql.append("ORDER BY p.fecha_publicacion DESC");

            try (Connection con = obtenerConexion();
                 PreparedStatement ps = con.prepareStatement(sql.toString())) {

                for (int i = 0; i < parametros.size(); i++) {
                    ps.setObject(i + 1, parametros.get(i));
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> p = new HashMap<>();
                        p.put("id", rs.getInt("id_propiedad"));
                        p.put("matricula", rs.getString("matricula_inmobiliaria"));
                        p.put("titulo", rs.getString("titulo"));
                        p.put("descripcion", rs.getString("descripcion"));
                        p.put("precio", rs.getBigDecimal("precio"));
                        p.put("estado", rs.getString("estado"));
                        p.put("fecha", rs.getTimestamp("fecha_publicacion"));
                        p.put("ciudad", rs.getString("nombre_ciudad"));
                        p.put("tipo", rs.getString("nombre_tipo"));
                        p.put("agencia", rs.getString("nombre_agencia"));
                        p.put("imagen", rs.getString("imagen"));
                        propiedades.add(p);
                    }
                }
            }

            cargarCatalogos(ciudades, tipos);

            request.setAttribute("propiedades", propiedades);
            request.setAttribute("ciudades", ciudades);
            request.setAttribute("tipos", tipos);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Los filtros seleccionados no son válidos");
            cargarCatalogosSeguro(request, ciudades, tipos);
            request.setAttribute("propiedades", propiedades);
        } catch (SQLException e) {
            throw new ServletException("No se pudieron cargar las propiedades", e);
        }
    }

private void cargarCatalogos(List<String[]> ciudades, List<String[]> tipos) throws SQLException {
        try (Connection con = obtenerConexion()) {
            String sqlCiudades = "SELECT id_ciudad, nombre_ciudad FROM ciudad ORDER BY nombre_ciudad";
            try (PreparedStatement ps = con.prepareStatement(sqlCiudades);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ciudades.add(new String[]{String.valueOf(rs.getInt("id_ciudad")), rs.getString("nombre_ciudad")});
                }
            }

            String sqlTipos = "SELECT id_tipo, nombre_tipo FROM tipo_propiedad ORDER BY nombre_tipo";
            try (PreparedStatement ps = con.prepareStatement(sqlTipos);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tipos.add(new String[]{String.valueOf(rs.getInt("id_tipo")), rs.getString("nombre_tipo")});
                }
            }
        }
    }

private void cargarCatalogosSeguro(HttpServletRequest request, List<String[]> ciudades, List<String[]> tipos) {
        try {
            cargarCatalogos(ciudades, tipos);
        } catch (SQLException ignored) {
        }
        request.setAttribute("ciudades", ciudades);
        request.setAttribute("tipos", tipos);
    }

private boolean estadoValido(String estado) {
        return "DISPONIBLE".equals(estado)
                || "ARRENDADA".equals(estado)
                || "VENDIDA".equals(estado)
                || "INACTIVA".equals(estado);
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


if (!esAdministrador(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        cargarPropiedades(request);
        request.getRequestDispatcher("/paneles/administrador/propiedades.jsp")
                .forward(request, response);
    
}
else if ("POST".equalsIgnoreCase(request.getMethod())) {


        request.setCharacterEncoding("UTF-8");

if (!esAdministrador(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String accion = request.getParameter("accion");
        if (!"estado".equals(accion)) {
            response.sendRedirect(request.getContextPath() + "/acciones/administrador-propiedades.jsp");
            return;
        }

        try {
            int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
            String estado = request.getParameter("estado");

            if (!estadoValido(estado)) {
                response.sendRedirect(request.getContextPath() + "/acciones/administrador-propiedades.jsp?error=estado");
                return;
            }

            String sql = "UPDATE propiedad SET estado = ? WHERE id_propiedad = ?";
            try (Connection con = obtenerConexion();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, estado);
                ps.setInt(2, idPropiedad);
                int filas = ps.executeUpdate();

                if (filas == 0) {
                    response.sendRedirect(request.getContextPath() + "/acciones/administrador-propiedades.jsp?error=noEncontrada");
                    return;
                }
            }

            registrarAuditoria((Integer) session.getAttribute("idUsuario"),
                    "Cambió el estado de la propiedad " + idPropiedad + " a " + estado);

            response.sendRedirect(request.getContextPath() + "/acciones/administrador-propiedades.jsp?mensaje=estado");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/administrador-propiedades.jsp?error=datos");
        } catch (SQLException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/administrador-propiedades.jsp?error=bd");
        }
    
}
%>
