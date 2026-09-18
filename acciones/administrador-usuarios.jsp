<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="javax.servlet.ServletException" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%!


private void cargarDatos(HttpServletRequest request) throws ServletException {
        List<Map<String, Object>> usuarios = new ArrayList<>();
        List<String[]> roles = new ArrayList<>();

        String sqlUsuarios =
                "SELECT u.id_usuario, u.correo, u.estado, u.fecha_registro, " +
                "COALESCE(string_agg(r.nombre_rol, ', ' ORDER BY r.nombre_rol), 'SIN ROL') AS roles " +
                "FROM usuario u " +
                "LEFT JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario " +
                "LEFT JOIN rol r ON r.id_rol = ur.id_rol " +
                "GROUP BY u.id_usuario, u.correo, u.estado, u.fecha_registro " +
                "ORDER BY u.id_usuario";

        String sqlRoles = "SELECT id_rol, nombre_rol FROM rol ORDER BY nombre_rol";

        try (Connection con = obtenerConexion();
             PreparedStatement psUsuarios = con.prepareStatement(sqlUsuarios);
             PreparedStatement psRoles = con.prepareStatement(sqlRoles)) {

            try (ResultSet rs = psUsuarios.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> usuario = new HashMap<>();
                    usuario.put("id", rs.getInt("id_usuario"));
                    usuario.put("correo", rs.getString("correo"));
                    usuario.put("estado", rs.getString("estado"));
                    usuario.put("fecha", rs.getTimestamp("fecha_registro"));
                    usuario.put("roles", rs.getString("roles"));
                    usuarios.add(usuario);
                }
            }

            try (ResultSet rs = psRoles.executeQuery()) {
                while (rs.next()) {
                    roles.add(new String[]{
                            String.valueOf(rs.getInt("id_rol")),
                            rs.getString("nombre_rol")
                    });
                }
            }

            request.setAttribute("usuarios", usuarios);
            request.setAttribute("roles", roles);

        } catch (SQLException e) {
            throw new ServletException("No se pudieron cargar los usuarios", e);
        }
    }

private void cambiarEstado(HttpServletRequest request, HttpServletResponse response, int idAdmin)
            throws IOException {

        String idTexto = request.getParameter("idUsuario");
        String estado = request.getParameter("estado");

        try {
            int idUsuario = Integer.parseInt(idTexto);

            if (idUsuario == idAdmin) {
                response.sendRedirect(request.getContextPath() + "/acciones/administrador-usuarios.jsp?error=propio");
                return;
            }

            if (!"ACTIVO".equals(estado) && !"INACTIVO".equals(estado) && !"BLOQUEADO".equals(estado)) {
                response.sendRedirect(request.getContextPath() + "/acciones/administrador-usuarios.jsp?error=estado");
                return;
            }

            String sql = "UPDATE usuario SET estado = ? WHERE id_usuario = ?";
            try (Connection con = obtenerConexion();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, estado);
                ps.setInt(2, idUsuario);
                ps.executeUpdate();
            }

            registrarAuditoria(idAdmin, "Cambio de estado del usuario " + idUsuario + " a " + estado);
            response.sendRedirect(request.getContextPath() + "/acciones/administrador-usuarios.jsp?mensaje=estado");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/administrador-usuarios.jsp?error=datos");
        } catch (SQLException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/administrador-usuarios.jsp?error=bd");
        }
    }

private void asignarRol(HttpServletRequest request, HttpServletResponse response, int idAdmin)
            throws IOException {

        String idUsuarioTexto = request.getParameter("idUsuario");
        String idRolTexto = request.getParameter("idRol");

        try {
            int idUsuario = Integer.parseInt(idUsuarioTexto);
            int idRol = Integer.parseInt(idRolTexto);

            String sql = "INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (?, ?)";
            try (Connection con = obtenerConexion();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, idUsuario);
                ps.setInt(2, idRol);
                ps.executeUpdate();
            }

            registrarAuditoria(idAdmin, "Asignación del rol " + idRol + " al usuario " + idUsuario);
            response.sendRedirect(request.getContextPath() + "/acciones/administrador-usuarios.jsp?mensaje=rol");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/acciones/administrador-usuarios.jsp?error=datos");
        } catch (SQLException e) {
            // Si ya existe la combinación usuario/rol, la clave primaria la rechaza.
            response.sendRedirect(request.getContextPath() + "/acciones/administrador-usuarios.jsp?error=rol");
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


if (!esAdministrador(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        cargarDatos(request);
        request.getRequestDispatcher("/paneles/administrador/usuarios.jsp")
                .forward(request, response);
    
}
else if ("POST".equalsIgnoreCase(request.getMethod())) {


        request.setCharacterEncoding("UTF-8");

if (!esAdministrador(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String accion = request.getParameter("accion");
        int idAdmin = (Integer) session.getAttribute("idUsuario");

        if ("estado".equals(accion)) {
            cambiarEstado(request, response, idAdmin);
        } else if ("rol".equals(accion)) {
            asignarRol(request, response, idAdmin);
        } else {
            response.sendRedirect(request.getContextPath() + "/acciones/administrador-usuarios.jsp");
        }
    
}
%>
