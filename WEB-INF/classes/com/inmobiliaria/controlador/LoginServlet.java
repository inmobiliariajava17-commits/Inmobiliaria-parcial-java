package com.inmobiliaria.controlador;

import com.inmobiliaria.util.ConexionBD;
import com.inmobiliaria.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/ingresar")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String correo = request.getParameter("correo");
        String password = request.getParameter("password");

        if (correo == null || password == null) {
            request.setAttribute("error", "Ingresa tu correo y contraseña");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        String sql = "SELECT id_usuario, password_hash, estado FROM usuario WHERE correo = ?";

        try (Connection con = ConexionBD.obtenerConexion();
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

            if (idUsuario == -1 || !PasswordUtil.verificar(password, hashGuardado)) {
                request.setAttribute("error", "Correo o contraseña incorrectos");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            if (!"ACTIVO".equals(estado)) {
                request.setAttribute("error", "Tu cuenta no está activa, contacta al administrador");
                request.getRequestDispatcher("login.jsp").forward(request, response);
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

            HttpSession session = request.getSession();
            session.setAttribute("idUsuario", idUsuario);
            session.setAttribute("correo", correo);
            session.setAttribute("roles", roles);

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
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
