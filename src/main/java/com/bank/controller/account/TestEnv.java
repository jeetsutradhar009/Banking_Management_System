package com.bank.controller.account;

public class TestEnv {

    public static void main(String[] args) {

        System.out.println("CLIENT ID:");
        System.out.println(System.getenv("GMAIL_CLIENT_ID"));

        System.out.println("EMAIL:");
        System.out.println(System.getenv("GMAIL_SENDER_EMAIL"));
    }
}