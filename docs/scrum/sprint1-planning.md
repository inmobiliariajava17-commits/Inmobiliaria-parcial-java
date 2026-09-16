# Sprint 1 - Planning

Sprint del 26-08 al 01-09. Objetivo: dejar la base de datos lista, la
conexión funcionando, la landing page y el login/registro con roles.

## Historias que voy a trabajar

1. Como visitante quiero ver una landing page para conocer la inmobiliaria
   y buscar propiedades rápido. (Alta)
2. Como usuario quiero registrarme con correo único para no tener cuentas
   duplicadas. (Alta)
3. Como usuario quiero iniciar y cerrar sesión y que me lleve al panel de
   mi rol. (Alta)
4. Como admin quiero poder asignar roles a los usuarios. (Alta)

## Qué voy a necesitar

- MER y modelo relacional
- Script DDL/DML en Supabase
- Conexión JDBC centralizada
- Landing page
- Registro y login
- Filter para controlar acceso según el rol

## Definition of Done

- El registro no deja repetir correo, y muestra mensaje claro si ya existe
- Las contraseñas quedan hasheadas con BCrypt, nunca en texto plano
- Al loguearse te manda al panel según tu rol
- Si alguien intenta entrar a una ruta privada sin permiso, lo manda a
  acceso denegado
- La landing se ve bien en celular también
