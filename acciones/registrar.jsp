<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="javax.servlet.ServletException" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%!
private static final String UNIQUE_VIOLATION = "23505";
%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
if ("GET".equalsIgnoreCase(request.getMethod())) {

        request.getRequestDispatcher("/registro.jsp").forward(request, response);
    
}
else if ("POST".equalsIgnoreCase(request.getMethod())) {


        String tipoCuenta = request.getParameter("tipoCuenta");
        String correo = request.getParameter("correo");
        String password = request.getParameter("password");
        String confirmar = request.getParameter("confirmar");
        String nombreAgencia = request.getParameter("nombreAgencia");
        String nit = request.getParameter("nit");

        if (tipoCuenta == null || (!tipoCuenta.equals("CLIENTE") && !tipoCuenta.equals("INMOBILIARIA"))) {
            request.setAttribute("error", "Selecciona un tipo de cuenta válido");
            request.getRequestDispatcher("/registro.jsp").forward(request, response);
            return;
        }

        if (correo == null || correo.isBlank() || password == null || password.isBlank()) {
            request.setAttribute("error", "Todos los campos son obligatorios");
            request.getRequestDispatcher("/registro.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmar)) {
            request.setAttribute("error", "Las contraseñas no coinciden");
            request.getRequestDispatcher("/registro.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "La contraseña debe tener al menos 6 caracteres");
            request.getRequestDispatcher("/registro.jsp").forward(request, response);
            return;
        }

        if (tipoCuenta.equals("INMOBILIARIA") &&
                (nombreAgencia == null || nombreAgencia.isBlank() || nit == null || nit.isBlank())) {
            request.setAttribute("error", "Para una cuenta inmobiliaria debes indicar el nombre de la agencia y el NIT");
            request.getRequestDispatcher("/registro.jsp").forward(request, response);
            return;
        }

        Connection con = null;
        try {
            con = obtenerConexion();
            con.setAutoCommit(false);

            int idUsuario;
            String sqlUsuario = "INSERT INTO usuario (correo, password_hash, estado) VALUES (?, crypt(?, gen_salt('bf')), 'ACTIVO')";
            try (PreparedStatement ps = con.prepareStatement(sqlUsuario, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, correo.trim());
                ps.setString(2, password);
                ps.executeUpdate();

                try (ResultSet keys = ps.getGeneratedKeys()) {
                    keys.next();
                    idUsuario = keys.getInt(1);
                }
            }

            String sqlRol = "INSERT INTO usuario_rol (id_usuario, id_rol) " +
                    "SELECT ?, id_rol FROM rol WHERE nombre_rol = ?";
            try (PreparedStatement ps = con.prepareStatement(sqlRol)) {
                ps.setInt(1, idUsuario);
                ps.setString(2, tipoCuenta);
                ps.executeUpdate();
            }

            if (tipoCuenta.equals("INMOBILIARIA")) {
                String sqlInmobiliaria = "INSERT INTO inmobiliaria (id_usuario, nombre_agencia, nit) VALUES (?, ?, ?)";
                try (PreparedStatement ps = con.prepareStatement(sqlInmobiliaria)) {
                    ps.setInt(1, idUsuario);
                    ps.setString(2, nombreAgencia.trim());
                    ps.setString(3, nit.trim());
                    ps.executeUpdate();
                }
            }

            con.commit();

            request.setAttribute("mensaje", "Cuenta creada correctamente, ya puedes iniciar sesión");
            request.getRequestDispatcher("/login.jsp").forward(request, response);

        } catch (SQLException e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ignored) {}
            }

            if (UNIQUE_VIOLATION.equals(e.getSQLState())) {
                if (tipoCuenta.equals("INMOBILIARIA")) {
                    request.setAttribute("error", "El correo o NIT ya se encuentra registrado");
                } else {
                    request.setAttribute("error", "El correo ya se encuentra registrado");
                }
            } else {
                request.setAttribute("error", "Ocurrió un error al registrar la cuenta");
            }
            request.getRequestDispatcher("/registro.jsp").forward(request, response);

        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException ignored) {}
            }
        }
    
}
%>
