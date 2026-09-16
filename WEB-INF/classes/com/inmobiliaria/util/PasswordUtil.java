package com.inmobiliaria.util;

import org.mindrot.BCrypt;

/**
 * Utilidad para hashear y verificar contraseñas usando BCrypt.
 * Internamente usa la clase org.mindrot.BCrypt (incluida en
 * WEB-INF/classes/org/mindrot/BCrypt.java).
 *
 * Los hashes generados con esta clase empiezan con "$2a$10$..." y
 * son 100% compatibles con los que ya insertamos en el DML de prueba.
 */
public class PasswordUtil {

    private static final int LOG_ROUNDS = 10; // costo por defecto de BCrypt

    /**
     * Genera el hash para una contraseña en texto plano.
     * Este es el valor que se guarda en usuario.password_hash.
     */
    public static String hashear(String passwordPlano) {
        return BCrypt.hashpw(passwordPlano, BCrypt.gensalt(LOG_ROUNDS));
    }

    /**
     * Verifica si una contraseña en texto plano coincide con un hash almacenado.
     * Úsalo en el login: PasswordUtil.verificar(passwordIngresado, hashDeLaBD)
     */
    public static boolean verificar(String passwordPlano, String hashAlmacenado) {
        try {
            return BCrypt.checkpw(passwordPlano, hashAlmacenado);
        } catch (Exception e) {
            return false;
        }
    }

    // Prueba rápida manual (puedes borrar este main luego)
    public static void main(String[] args) {
        String hash = hashear("123456");
        System.out.println("Hash generado: " + hash);
        System.out.println("¿Verifica '123456'?: " + verificar("123456", hash));
        System.out.println("¿Verifica 'otraClave'?: " + verificar("otraClave", hash));
    }
}
