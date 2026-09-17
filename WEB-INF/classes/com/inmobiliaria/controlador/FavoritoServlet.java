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

@WebServlet("/favoritos")
public class FavoritoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!esCliente(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");
        List<Map<String, Object>> favoritos = new ArrayList<>();

        String sql =
                "SELECT p.id_propiedad, p.titulo, p.precio, p.estado, " +
                "c.nombre_ciudad, tp.nombre_tipo, " +
                "COALESCE((SELECT ip.url_imagen FROM imagen_propiedad ip " +
                "WHERE ip.id_propiedad = p.id_propiedad AND ip.es_principal = TRUE " +
                "ORDER BY ip.id_imagen LIMIT 1), " +
                "(SELECT ip.url_imagen FROM imagen_propiedad ip " +
                "WHERE ip.id_propiedad = p.id_propiedad ORDER BY ip.id_imagen LIMIT 1), '') AS imagen " +
                "FROM favorito f " +
                "INNER JOIN propiedad p ON p.id_propiedad = f.id_propiedad " +
                "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                "INNER JOIN tipo_propiedad tp ON tp.id_tipo = p.id_tipo " +
                "WHERE f.id_usuario = ? " +
                "ORDER BY f.fecha_marcado DESC";

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, idUsuario);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> favorito = new HashMap<>();
                    favorito.put("id", rs.getInt("id_propiedad"));
                    favorito.put("titulo", rs.getString("titulo"));
                    favorito.put("precio", rs.getBigDecimal("precio"));
                    favorito.put("estado", rs.getString("estado"));
                    favorito.put("ciudad", rs.getString("nombre_ciudad"));
                    favorito.put("tipo", rs.getString("nombre_tipo"));
                    favorito.put("imagen", rs.getString("imagen"));
                    favoritos.add(favorito);
                }
            }

            request.setAttribute("favoritos", favoritos);
            request.getRequestDispatcher("/paneles/cliente/favoritos.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            request.setAttribute("error", "No se pudieron cargar tus favoritos");
            request.setAttribute("favoritos", favoritos);
            request.getRequestDispatcher("/paneles/cliente/favoritos.jsp")
                    .forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!esCliente(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String accion = request.getParameter("accion");
        String idTexto = request.getParameter("idPropiedad");

        if (idTexto == null || idTexto.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/favoritos?error=datos");
            return;
        }

        try {
            int idUsuario = (Integer) session.getAttribute("idUsuario");
            int idPropiedad = Integer.parseInt(idTexto);

            if ("agregar".equals(accion)) {
                agregar(idUsuario, idPropiedad);
                registrarAuditoria(idUsuario, "Agregó una propiedad a favoritos: " + idPropiedad);
                response.sendRedirect(request.getContextPath() + "/propiedad?id=" + idPropiedad + "&favorito=agregado");
            } else if ("quitar".equals(accion)) {
                quitar(idUsuario, idPropiedad);
                registrarAuditoria(idUsuario, "Quitó una propiedad de favoritos: " + idPropiedad);
                String volver = request.getParameter("volver");
                if ("lista".equals(volver)) {
                    response.sendRedirect(request.getContextPath() + "/favoritos?mensaje=quitado");
                } else {
                    response.sendRedirect(request.getContextPath() + "/propiedad?id=" + idPropiedad + "&favorito=quitado");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/favoritos?error=accion");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/favoritos?error=datos");
        } catch (SQLException e) {
            response.sendRedirect(request.getContextPath() + "/favoritos?error=guardar");
        }
    }

    private void agregar(int idUsuario, int idPropiedad) throws SQLException {
        String sql =
                "INSERT INTO favorito (id_usuario, id_propiedad) " +
                "SELECT ?, ? WHERE EXISTS (SELECT 1 FROM propiedad WHERE id_propiedad = ? AND estado = 'DISPONIBLE') " +
                "ON CONFLICT (id_usuario, id_propiedad) DO NOTHING";

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, idPropiedad);
            ps.setInt(3, idPropiedad);
            ps.executeUpdate();
        }
    }

    private void quitar(int idUsuario, int idPropiedad) throws SQLException {
        String sql = "DELETE FROM favorito WHERE id_usuario = ? AND id_propiedad = ?";

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, idPropiedad);
            ps.executeUpdate();
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

    private boolean esCliente(HttpSession session) {
        if (session == null || session.getAttribute("idUsuario") == null) {
            return false;
        }

        @SuppressWarnings("unchecked")
        List<String> roles = (List<String>) session.getAttribute("roles");
        return roles != null && roles.contains("CLIENTE");
    }
}
