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


private boolean catalogoValido(String catalogo) {
        return "ciudad".equals(catalogo)
                || "tipo".equals(catalogo)
                || "caracteristica".equals(catalogo);
    }

private boolean accionValida(String accion) {
        return "crear".equals(accion) || "editar".equals(accion) || "eliminar".equals(accion);
    }

private void cargarCatalogos(HttpServletRequest request) throws ServletException {
        List<Map<String, Object>> ciudades = new ArrayList<>();
        List<Map<String, Object>> tipos = new ArrayList<>();
        List<Map<String, Object>> caracteristicas = new ArrayList<>();

        String sqlCiudad = "SELECT id_ciudad AS id, nombre_ciudad AS nombre FROM ciudad ORDER BY nombre_ciudad";
        String sqlTipo = "SELECT id_tipo AS id, nombre_tipo AS nombre FROM tipo_propiedad ORDER BY nombre_tipo";
        String sqlCaracteristica = "SELECT id_caracteristica AS id, nombre AS nombre FROM caracteristica ORDER BY nombre";

        try (Connection con = obtenerConexion()) {
            cargarLista(con, sqlCiudad, ciudades);
            cargarLista(con, sqlTipo, tipos);
            cargarLista(con, sqlCaracteristica, caracteristicas);

            request.setAttribute("ciudades", ciudades);
            request.setAttribute("tipos", tipos);
            request.setAttribute("caracteristicas", caracteristicas);
        } catch (SQLException e) {
            throw new ServletException("No se pudieron cargar los catálogos", e);
        }
    }

private void cargarLista(Connection con, String sql, List<Map<String, Object>> lista) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("id", rs.getInt("id"));
                item.put("nombre", rs.getString("nombre"));
                lista.add(item);
            }
        }
    }

private void crear(String catalogo, String nombre) throws SQLException {
        String nombreLimpio = validarNombre(nombre);
        String sql;

        if ("ciudad".equals(catalogo)) {
            sql = "INSERT INTO ciudad (nombre_ciudad) VALUES (?)";
        } else if ("tipo".equals(catalogo)) {
            sql = "INSERT INTO tipo_propiedad (nombre_tipo) VALUES (?)";
        } else {
            sql = "INSERT INTO caracteristica (nombre) VALUES (?)";
        }

        ejecutarNombre(sql, nombreLimpio);
    }

private void editar(String catalogo, int id, String nombre) throws SQLException {
        String nombreLimpio = validarNombre(nombre);
        String sql;

        if ("ciudad".equals(catalogo)) {
            sql = "UPDATE ciudad SET nombre_ciudad = ? WHERE id_ciudad = ?";
        } else if ("tipo".equals(catalogo)) {
            sql = "UPDATE tipo_propiedad SET nombre_tipo = ? WHERE id_tipo = ?";
        } else {
            sql = "UPDATE caracteristica SET nombre = ? WHERE id_caracteristica = ?";
        }

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nombreLimpio);
            ps.setInt(2, id);
            if (ps.executeUpdate() == 0) {
                throw new SQLException("Registro no encontrado");
            }
        }
    }

private void eliminar(String catalogo, int id) throws SQLException {
        String sql;

        if ("ciudad".equals(catalogo)) {
            sql = "DELETE FROM ciudad WHERE id_ciudad = ?";
        } else if ("tipo".equals(catalogo)) {
            sql = "DELETE FROM tipo_propiedad WHERE id_tipo = ?";
        } else {
            sql = "DELETE FROM caracteristica WHERE id_caracteristica = ?";
        }

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            if (ps.executeUpdate() == 0) {
                throw new SQLException("Registro no encontrado");
            }
        }
    }

private void ejecutarNombre(String sql, String nombre) throws SQLException {
        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nombre);
            ps.executeUpdate();
        }
    }

private String validarNombre(String nombre) throws SQLException {
        if (nombre == null || nombre.trim().isEmpty()) {
            throw new SQLException("El nombre es obligatorio");
        }
        return nombre.trim();
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

        cargarCatalogos(request);
        request.getRequestDispatcher("/paneles/administrador/catalogos.jsp")
                .forward(request, response);
    
}
else if ("POST".equalsIgnoreCase(request.getMethod())) {


        request.setCharacterEncoding("UTF-8");
if (!esAdministrador(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String catalogo = request.getParameter("catalogo");
        String accion = request.getParameter("accion");
        int idAdmin = (Integer) session.getAttribute("idUsuario");

        if (!catalogoValido(catalogo) || !accionValida(accion)) {
            response.sendRedirect(request.getContextPath() + "/acciones/administrador-catalogos.jsp?error=datos");
            return;
        }

        try {
            if ("crear".equals(accion)) {
                crear(catalogo, request.getParameter("nombre"));
                registrarAuditoria(idAdmin, "Creó registro en catálogo " + catalogo);
                response.sendRedirect(request.getContextPath() + "/acciones/administrador-catalogos.jsp?mensaje=creado&catalogo=" + catalogo);
                return;
            }

            int id = Integer.parseInt(request.getParameter("id"));

            if ("editar".equals(accion)) {
                editar(catalogo, id, request.getParameter("nombre"));
                registrarAuditoria(idAdmin, "Editó registro " + id + " del catálogo " + catalogo);
                response.sendRedirect(request.getContextPath() + "/acciones/administrador-catalogos.jsp?mensaje=editado&catalogo=" + catalogo);
            } else {
                eliminar(catalogo, id);
                registrarAuditoria(idAdmin, "Eliminó registro " + id + " del catálogo " + catalogo);
                response.sendRedirect(request.getContextPath() + "/acciones/administrador-catalogos.jsp?mensaje=eliminado&catalogo=" + catalogo);
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/administrador-catalogos.jsp?error=datos");
        } catch (SQLIntegrityConstraintViolationException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/administrador-catalogos.jsp?error=usado&catalogo=" + catalogo);
        } catch (SQLException e) {
            if ("23505".equals(e.getSQLState())) {
                response.sendRedirect(request.getContextPath() + "/acciones/administrador-catalogos.jsp?error=duplicado&catalogo=" + catalogo);
            } else if ("23503".equals(e.getSQLState())) {
                response.sendRedirect(request.getContextPath() + "/acciones/administrador-catalogos.jsp?error=usado&catalogo=" + catalogo);
            } else {
                response.sendRedirect(request.getContextPath() + "/acciones/administrador-catalogos.jsp?error=bd&catalogo=" + catalogo);
            }
        }
    
}
%>
