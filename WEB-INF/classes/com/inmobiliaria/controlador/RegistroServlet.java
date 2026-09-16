package com.inmobiliaria.controlador;

import com.inmobiliaria.util.ConexionBD;
import com.inmobiliaria.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

@WebServlet("/registrar")
public class RegistroServlet extends HttpServlet {

    private static final String UNIQUE_VIOLATION = "23505";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("registro.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tipoCuenta = request.getParameter("tipoCuenta");
        String correo = request.getParameter("correo");
        String password = request.getParameter("password");
        String confirmar = request.getParameter("confirmar");
        String nombreAgencia = request.getParameter("nombreAgencia");
        String nit = request.getParameter("nit");

        if (tipoCuenta == null || (!tipoCuenta.equals("CLIENTE") && !tipoCuenta.equals("INMOBILIARIA"))) {
            request.setAttribute("error", "Selecciona un tipo de cuenta válido");
            request.getRequestDispatcher("registro.jsp").forward(request, response);
            return;
        }

        if (correo == null || correo.isBlank() || password == null || password.isBlank()) {
            request.setAttribute("error", "Todos los campos son obligatorios");
            request.getRequestDispatcher("registro.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmar)) {
            request.setAttribute("error", "Las contraseñas no coinciden");
            request.getRequestDispatcher("registro.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "La contraseña debe tener al menos 6 caracteres");
            request.getRequestDispatcher("registro.jsp").forward(request, response);
            return;
        }

        if (tipoCuenta.equals("INMOBILIARIA") &&
                (nombreAgencia == null || nombreAgencia.isBlank() || nit == null || nit.isBlank())) {
            request.setAttribute("error", "Para una cuenta inmobiliaria debes indicar el nombre de la agencia y el NIT");
            request.getRequestDispatcher("registro.jsp").forward(request, response);
            return;
        }

        String hash = PasswordUtil.hashear(password);

        Connection con = null;
        try {
            con = ConexionBD.obtenerConexion();
            con.setAutoCommit(false);

            int idUsuario;
            String sqlUsuario = "INSERT INTO usuario (correo, password_hash, estado) VALUES (?, ?, 'ACTIVO')";
            try (PreparedStatement ps = con.prepareStatement(sqlUsuario, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, correo.trim());
                ps.setString(2, hash);
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
            request.getRequestDispatcher("login.jsp").forward(request, response);

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
            request.getRequestDispatcher("registro.jsp").forward(request, response);

        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException ignored) {}
            }
        }
    }
}
