package com.bank.test;

public class EnvTest {

    public static void main(String[] args) {

        System.out.println("HOST: " + System.getenv("SMTP_HOST"));
        System.out.println("PORT: " + System.getenv("SMTP_PORT"));
        System.out.println("USERNAME: " + System.getenv("SMTP_USERNAME"));
        System.out.println("FROM: " + System.getenv("SMTP_FROM_EMAIL"));

        System.out.println(
            "PASSWORD SET: " +
            (System.getenv("SMTP_PASSWORD") != null)
        );
    }
}