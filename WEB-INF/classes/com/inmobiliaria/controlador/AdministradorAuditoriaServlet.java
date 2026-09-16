package com.inmobiliaria.controlador;

import com.inmobiliaria.util.ConexionBD;

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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/administrador/auditoria")
public class AdministradorAuditoriaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!esAdministrador(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        List<Map<String, Object>> registros = new ArrayList<>();
        String sql =
                "SELECT a.id_auditoria, a.id_usuario, u.correo, a.accion, a.fecha " +
                "FROM auditoria a " +
                "LEFT JOIN usuario u ON u.id_usuario = a.id_usuario " +
                "ORDER BY a.fecha DESC, a.id_auditoria DESC " +
                "LIMIT 100";

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> registro = new HashMap<>();
                registro.put("id", rs.getInt("id_auditoria"));
                registro.put("idUsuario", rs.getObject("id_usuario"));
                registro.put("correo", rs.getString("correo"));
                registro.put("accion", rs.getString("accion"));
                registro.put("fecha", rs.getTimestamp("fecha"));
                registros.add(registro);
            }

            request.setAttribute("registros", registros);
            request.getRequestDispatcher("/paneles/administrador/auditoria.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("No se pudo cargar la auditoría", e);
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
}
