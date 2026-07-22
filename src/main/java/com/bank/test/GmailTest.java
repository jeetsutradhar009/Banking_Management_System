package com.bank.test;

import com.bank.util.EmailService;

public class GmailTest {

    public static void main(String[] args) {

        EmailService service = new EmailService();

        EmailService.EmailResult result =
                service.sendOtpEmail(
                        "Enter_your_mail",
                        "Dipankar",
                        "123456",
                        10
                );

        System.out.println(result.getMessage());
    }
}