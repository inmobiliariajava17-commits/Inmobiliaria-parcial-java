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

@WebServlet("/administrador/reportes")
public class AdministradorReporteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!esAdministrador(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        List<Map<String, Object>> propiedadesCiudad = new ArrayList<>();
        List<Map<String, Object>> citasEstado = new ArrayList<>();
        List<Map<String, Object>> solicitudesInmobiliaria = new ArrayList<>();

        String sqlPropiedades =
                "SELECT c.nombre_ciudad, COUNT(p.id_propiedad) AS total " +
                "FROM propiedad p " +
                "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
                "WHERE p.estado = 'DISPONIBLE' " +
                "GROUP BY c.nombre_ciudad " +
                "ORDER BY total DESC, c.nombre_ciudad";

        String sqlCitas =
                "SELECT estado, COUNT(*) AS total " +
                "FROM cita " +
                "GROUP BY estado " +
                "ORDER BY total DESC, estado";

        String sqlSolicitudes =
                "SELECT i.nombre_agencia, COUNT(s.id_solicitud) AS total " +
                "FROM solicitud s " +
                "INNER JOIN propiedad p ON s.id_propiedad = p.id_propiedad " +
                "INNER JOIN inmobiliaria i ON p.id_inmobiliaria = i.id_inmobiliaria " +
                "GROUP BY i.nombre_agencia " +
                "ORDER BY total DESC, i.nombre_agencia";

        try (Connection con = ConexionBD.obtenerConexion()) {
            cargarReporte(con, sqlPropiedades, propiedadesCiudad, "nombre_ciudad");
            cargarReporte(con, sqlCitas, citasEstado, "estado");
            cargarReporte(con, sqlSolicitudes, solicitudesInmobiliaria, "nombre_agencia");

            request.setAttribute("propiedadesCiudad", propiedadesCiudad);
            request.setAttribute("citasEstado", citasEstado);
            request.setAttribute("solicitudesInmobiliaria", solicitudesInmobiliaria);

            registrarAuditoria(con, (Integer) session.getAttribute("idUsuario"),
                    "Consultó los reportes del administrador");

            request.getRequestDispatcher("/paneles/administrador/reportes.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("No se pudieron cargar los reportes", e);
        }
    }

    private void cargarReporte(Connection con, String sql, List<Map<String, Object>> lista,
                               String columnaNombre) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> fila = new HashMap<>();
                fila.put("nombre", rs.getString(columnaNombre));
                fila.put("total", rs.getLong("total"));
                lista.add(fila);
            }
        }
    }

    private void registrarAuditoria(Connection con, int idUsuario, String accion) throws SQLException {
        String sql = "INSERT INTO auditoria (id_usuario, accion) VALUES (?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setString(2, accion);
            ps.executeUpdate();
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
