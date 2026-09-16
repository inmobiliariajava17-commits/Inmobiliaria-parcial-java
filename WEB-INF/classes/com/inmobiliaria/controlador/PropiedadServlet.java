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

@WebServlet("/propiedades")
public class PropiedadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("idUsuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=sesion");
            return;
        }

        Integer idUsuario = (Integer) session.getAttribute("idUsuario");

        String sql = "SELECT p.id_propiedad, p.titulo, p.descripcion, p.precio, " +
                     "p.estado, p.matricula_inmobiliaria, c.nombre_ciudad, " +
                     "tp.nombre_tipo, i.nombre_agencia " +
                     "FROM propiedad p " +
                     "INNER JOIN inmobiliaria i ON p.id_inmobiliaria = i.id_inmobiliaria " +
                     "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
                     "INNER JOIN tipo_propiedad tp ON p.id_tipo = tp.id_tipo " +
                     "WHERE i.id_usuario = ? " +
                     "ORDER BY p.fecha_publicacion DESC";

        List<Map<String, Object>> propiedades = new ArrayList<>();

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, idUsuario);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> propiedad = new HashMap<>();
                    propiedad.put("id", rs.getInt("id_propiedad"));
                    propiedad.put("titulo", rs.getString("titulo"));
                    propiedad.put("descripcion", rs.getString("descripcion"));
                    propiedad.put("precio", rs.getBigDecimal("precio"));
                    propiedad.put("estado", rs.getString("estado"));
                    propiedad.put("matricula", rs.getString("matricula_inmobiliaria"));
                    propiedad.put("ciudad", rs.getString("nombre_ciudad"));
                    propiedad.put("tipo", rs.getString("nombre_tipo"));
                    propiedad.put("agencia", rs.getString("nombre_agencia"));

                    propiedades.add(propiedad);
                }
            }

            request.setAttribute("propiedades", propiedades);
            request.getRequestDispatcher("/paneles/inmobiliaria/propiedades.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            request.setAttribute("error", "No se pudieron cargar las propiedades.");
            request.getRequestDispatcher("/paneles/inmobiliaria.jsp")
                   .forward(request, response);
        }
    }
}
