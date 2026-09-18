<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="javax.servlet.ServletException" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%!
private String obtenerFotoPerfil(int idUsuario) {
        String sql = "SELECT foto_url FROM perfil WHERE id_usuario = ?";
        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("foto_url");
                }
            }
        } catch (SQLException e) {
            return null;
        }
        return null;
    }

%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
if ("GET".equalsIgnoreCase(request.getMethod())) {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    
}
else if ("POST".equalsIgnoreCase(request.getMethod())) {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String correo = request.getParameter("correo");
        String password = request.getParameter("password");

        if (correo == null || password == null) {
            request.setAttribute("error", "Ingresa tu correo y contraseña");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        String sql = "SELECT id_usuario, password_hash, estado FROM usuario WHERE correo = ?";

        try (Connection con = obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, correo);

            int idUsuario = -1;
            String hashGuardado = null;
            String estado = null;

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    idUsuario = rs.getInt("id_usuario");
                    hashGuardado = rs.getString("password_hash");
                    estado = rs.getString("estado");
                }
            }

            boolean passwordCorrecta = false;
            if (idUsuario != -1 && hashGuardado != null) {
                String sqlPassword = "SELECT crypt(?, ?) = ? AS correcta";
                try (PreparedStatement psPassword = con.prepareStatement(sqlPassword)) {
                    psPassword.setString(1, password);
                    psPassword.setString(2, hashGuardado);
                    psPassword.setString(3, hashGuardado);
                    try (ResultSet rsPassword = psPassword.executeQuery()) {
                        if (rsPassword.next()) {
                            passwordCorrecta = rsPassword.getBoolean("correcta");
                        }
                    }
                }
            }

            if (idUsuario == -1 || !passwordCorrecta) {
                request.setAttribute("error", "Correo o contraseña incorrectos");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            if (!"ACTIVO".equals(estado)) {
                request.setAttribute("error", "Tu cuenta no está activa, contacta al administrador");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            // Traer los roles del usuario (puede tener más de uno)
            List<String> roles = new ArrayList<>();
            String sqlRoles = "SELECT r.nombre_rol FROM rol r " +
                               "INNER JOIN usuario_rol ur ON r.id_rol = ur.id_rol " +
                               "WHERE ur.id_usuario = ?";
            try (PreparedStatement psRoles = con.prepareStatement(sqlRoles)) {
                psRoles.setInt(1, idUsuario);
                try (ResultSet rsRoles = psRoles.executeQuery()) {
                    while (rsRoles.next()) {
                        roles.add(rsRoles.getString("nombre_rol"));
                    }
                }
            }

            session.setAttribute("idUsuario", idUsuario);
            session.setAttribute("correo", correo);
            session.setAttribute("roles", roles);
            session.setAttribute("fotoPerfil", obtenerFotoPerfil(idUsuario));

            // Definimos a qué panel lo mandamos según su rol principal
            String destino;
            if (roles.contains("ADMINISTRADOR")) {
                destino = "paneles/administrador.jsp";
            } else if (roles.contains("INMOBILIARIA")) {
                destino = "paneles/inmobiliaria.jsp";
            } else {
                destino = "paneles/cliente.jsp";
            }

            response.sendRedirect(request.getContextPath() + "/" + destino);

        } catch (SQLException e) {
            request.setAttribute("error", "Ocurrió un error al iniciar sesión");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    
}
%>
