package com.inmobiliaria.controlador;

import com.inmobiliaria.util.ConexionBD;

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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/buscar")
public class BuscarServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String ciudad = request.getParameter("ciudad");
        String tipo = request.getParameter("tipo");

        StringBuilder sql = new StringBuilder(
            "SELECT p.id_propiedad, p.titulo, p.precio, p.estado, " +
            "c.nombre_ciudad, tp.nombre_tipo " +
            "FROM propiedad p " +
            "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
            "INNER JOIN tipo_propiedad tp ON p.id_tipo = tp.id_tipo " +
            "WHERE p.estado = 'DISPONIBLE' "
        );

        if (ciudad != null && !ciudad.isBlank()) {
            sql.append("AND c.nombre_ciudad = ? ");
        }
        if (tipo != null && !tipo.isBlank()) {
            sql.append("AND tp.nombre_tipo = ? ");
        }
        sql.append("ORDER BY p.fecha_publicacion DESC");

        List<Map<String, Object>> resultados = new ArrayList<>();

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int indice = 1;
            if (ciudad != null && !ciudad.isBlank()) {
                ps.setString(indice++, ciudad);
            }
            if (tipo != null && !tipo.isBlank()) {
                ps.setString(indice++, tipo);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> fila = new HashMap<>();
                    fila.put("id", rs.getInt("id_propiedad"));
                    fila.put("titulo", rs.getString("titulo"));
                    fila.put("precio", rs.getBigDecimal("precio"));
                    fila.put("ciudad", rs.getString("nombre_ciudad"));
                    fila.put("tipo", rs.getString("nombre_tipo"));
                    resultados.add(fila);
                }
            }

        } catch (SQLException e) {
            request.setAttribute("error", "Ocurrió un error al buscar propiedades");
        }

        request.setAttribute("resultados", resultados);
        request.setAttribute("ciudadBuscada", ciudad);
        request.setAttribute("tipoBuscado", tipo);
        request.getRequestDispatcher("resultados.jsp").forward(request, response);
    }
}
