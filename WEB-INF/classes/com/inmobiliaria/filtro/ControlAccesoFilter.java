package com.inmobiliaria.filtro;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Protege las rutas privadas de /paneles/*.
 * Si no hay sesión activa, o el usuario no tiene el rol requerido
 * para esa carpeta, lo redirige en vez de dejarlo pasar.
 *
 * Esto es obligatorio según el enunciado: ocultar un botón en el JSP
 * no cuenta como control de acceso, la validación real va aquí.
 */
@WebFilter("/paneles/*")
public class ControlAccesoFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        String contexto = request.getContextPath();

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("idUsuario") == null) {
            response.sendRedirect(contexto + "/login.jsp?error=sesion");
            return;
        }

        @SuppressWarnings("unchecked")
        List<String> roles = (List<String>) session.getAttribute("roles");

        String ruta = request.getRequestURI().substring(contexto.length());

        boolean autorizado;
        if (ruta.startsWith("/paneles/administrador")) {
            autorizado = roles != null && roles.contains("ADMINISTRADOR");
        } else if (ruta.startsWith("/paneles/inmobiliaria")) {
            autorizado = roles != null && roles.contains("INMOBILIARIA");
        } else if (ruta.startsWith("/paneles/cliente")) {
            autorizado = roles != null && roles.contains("CLIENTE");
        } else {
            // Cualquier otra ruta bajo /paneles/ solo pide sesión activa
            autorizado = true;
        }

        if (!autorizado) {
            response.sendRedirect(contexto + "/acceso-denegado.jsp");
            return;
        }

        chain.doFilter(req, res);
    }

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void destroy() {
    }
}
