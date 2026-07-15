package com.bank.test;

import com.bank.util.EmailService;

public class TestEmail {

    public static void main(String[] args) {

        EmailService emailService = new EmailService();

        EmailService.EmailResult result =
                emailService.sendOtpEmail(
                        "dsutradhar815@gmail.com",
                        "Dipankar",
                        "583921",
                        10
                );

        System.out.println(result.getMessage());
    }
}