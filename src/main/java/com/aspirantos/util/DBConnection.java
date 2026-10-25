package com.aspirantos.util;

import java.sql.Connection;
import java.sql.DriverManager;

/**
 * Opens a JDBC connection to the MySQL database "aspirantos".
 * Same shape as DBConnection in lab Experiment 4 (StudentCRUD): constants for URL, user and
 * password, Class.forName() to load the MySQL Connector/J driver (a Type 4 "thin" driver,
 * pure Java) and DriverManager.getConnection(). Every DAO calls getConnection() inside
 * try-with-resources, so the connection is always closed.
 *
 * Note: the theory notes use javax.servlet (Tomcat 9); Tomcat 11 requires jakarta.servlet -
 * same API, new package name.
 */
public class DBConnection {

    private static final String URL =
            "jdbc:mysql://localhost:3306/aspirantos?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata";

    private static final String USER = "aspirant_app";

    private static final String PASSWORD = "Aspirant@123";

    public static Connection getConnection() {
        Connection connection = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(
                    URL,
                    USER,
                    PASSWORD
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
        return connection;
    }
}
