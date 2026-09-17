package com.inmobiliaria.controlador;

import com.inmobiliaria.util.ConexionBD;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/caracteristicas-propiedad")
public class CaracteristicaPropiedadServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (!esInmobiliaria(session)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");
        String idPropiedadTexto = request.getParameter("idPropiedad");
        try {
            int idPropiedad = Integer.parseInt(idPropiedadTexto);
            if (!esPropiedadDeUsuario(idPropiedad, idUsuario)) {
                response.sendRedirect(request.getContextPath() + "/propiedades?error=noEncontrada");
                return;
            }

            String[] ids = request.getParameterValues("caracteristica");

            try (Connection con = ConexionBD.obtenerConexion()) {
                con.setAutoCommit(false);
                try {
                    try (PreparedStatement ps = con.prepareStatement("DELETE FROM propiedad_caracteristica WHERE id_propiedad = ?")) {
                        ps.setInt(1, idPropiedad);
                        ps.executeUpdate();
                    }

                    if (ids != null) {
                        String sql = "INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica, cantidad) VALUES (?, ?, ?)";
                        try (PreparedStatement ps = con.prepareStatement(sql)) {
                            for (int i = 0; i < ids.length; i++) {
                                int idCaracteristica = Integer.parseInt(ids[i]);
                                int cantidad = 1;
                                String cantidadTexto = request.getParameter("cantidad_" + idCaracteristica);
                                if (cantidadTexto != null) {
                                    try { cantidad = Math.max(1, Integer.parseInt(cantidadTexto)); } catch (NumberFormatException ignored) {}
                                }
                                ps.setInt(1, idPropiedad);
                                ps.setInt(2, idCaracteristica);
                                ps.setInt(3, cantidad);
                                ps.addBatch();
                            }
                            ps.executeBatch();
                        }
                    }
                    con.commit();
                } catch (SQLException e) {
                    con.rollback();
                    throw e;
                } finally {
                    con.setAutoCommit(true);
                }
            }

            response.sendRedirect(request.getContextPath() + "/imagenes-propiedad?id=" + idPropiedad + "&mensaje=caracteristicas");
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/propiedades?error=datos");
        } catch (SQLException e) {
            response.sendRedirect(request.getContextPath() + "/imagenes-propiedad?id=" + idPropiedadTexto + "&error=caracteristicas");
        }
    }

    private boolean esPropiedadDeUsuario(int idPropiedad, int idUsuario) throws SQLException {
        String sql = "SELECT 1 FROM propiedad p INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "WHERE p.id_propiedad = ? AND i.id_usuario = ?";
        try (Connection con = ConexionBD.obtenerConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad); ps.setInt(2, idUsuario);
            try (java.sql.ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    private boolean esInmobiliaria(HttpSession session) {
        if (session == null || session.getAttribute("idUsuario") == null) return false;
        @SuppressWarnings("unchecked") List<String> roles = (List<String>) session.getAttribute("roles");
        return roles != null && roles.contains("INMOBILIARIA");
    }
}
