package com.inmobiliaria.controlador;

import com.inmobiliaria.util.ConexionBD;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@WebServlet("/administrador/usuarios")
public class AdministradorUsuarioServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!esAdministrador(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        cargarDatos(request);
        request.getRequestDispatcher("/paneles/administrador/usuarios.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
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
            response.sendRedirect(request.getContextPath() + "/administrador/usuarios");
        }
    }

    private boolean esAdministrador(HttpSession session) {
        if (session == null || session.getAttribute("idUsuario") == null) {
            return false;
        }

        @SuppressWarnings("unchecked")
        List<String> roles = (List<String>) session.getAttribute("roles");
        return roles != null && roles.contains("ADMINISTRADOR");
    }

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

        try (Connection con = ConexionBD.obtenerConexion();
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
                response.sendRedirect(request.getContextPath() + "/administrador/usuarios?error=propio");
                return;
            }

            if (!"ACTIVO".equals(estado) && !"INACTIVO".equals(estado) && !"BLOQUEADO".equals(estado)) {
                response.sendRedirect(request.getContextPath() + "/administrador/usuarios?error=estado");
                return;
            }

            String sql = "UPDATE usuario SET estado = ? WHERE id_usuario = ?";
            try (Connection con = ConexionBD.obtenerConexion();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, estado);
                ps.setInt(2, idUsuario);
                ps.executeUpdate();
            }

            registrarAuditoria(idAdmin, "Cambio de estado del usuario " + idUsuario + " a " + estado);
            response.sendRedirect(request.getContextPath() + "/administrador/usuarios?mensaje=estado");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/administrador/usuarios?error=datos");
        } catch (SQLException e) {
            response.sendRedirect(request.getContextPath() + "/administrador/usuarios?error=bd");
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
            try (Connection con = ConexionBD.obtenerConexion();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, idUsuario);
                ps.setInt(2, idRol);
                ps.executeUpdate();
            }

            registrarAuditoria(idAdmin, "Asignación del rol " + idRol + " al usuario " + idUsuario);
            response.sendRedirect(request.getContextPath() + "/administrador/usuarios?mensaje=rol");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/administrador/usuarios?error=datos");
        } catch (SQLException e) {
            // Si ya existe la combinación usuario/rol, la clave primaria la rechaza.
            response.sendRedirect(request.getContextPath() + "/administrador/usuarios?error=rol");
        }
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
}
