package com.bank.test;

public class EnvTest {

    public static void main(String[] args) {

        System.out.println("CLIENT ID = " + System.getenv("GMAIL_CLIENT_ID"));
        System.out.println("CLIENT SECRET = " + System.getenv("GMAIL_CLIENT_SECRET"));
        System.out.println("REFRESH TOKEN = " + System.getenv("GMAIL_REFRESH_TOKEN"));
        System.out.println("SENDER EMAIL = " + System.getenv("GMAIL_SENDER_EMAIL"));

    }
}