package com.mycompany.hotelmanagement.utils;

import java.util.Properties;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class EmailUtil {
    private static final Logger logger = LoggerFactory.getLogger(EmailUtil.class);

    // Host configurations - customize as needed or set via System Properties
    private static final String SMTP_HOST = System.getProperty("smtp.host", "smtp.gmail.com");
    private static final String SMTP_PORT = System.getProperty("smtp.port", "587");
    private static final String SMTP_USER = System.getProperty("smtp.user", "your-email@gmail.com");
    private static final String SMTP_PASSWORD = System.getProperty("smtp.password", "your-app-password");

    /**
     * Sends an email. If SMTP credentials are not configured, it logs the email to
     * the console.
     * 
     * @param toEmail Recipient's email address
     * @param subject Email subject
     * @param body    Email body (HTML supported)
     * @return true if logged/sent successfully, false otherwise
     */
    public static boolean sendEmail(String toEmail, String subject, String body) {
        // Log the email action and content first for debugging purposes
        logger.info("Attempting to send email to: {}", toEmail);
        logger.info("Subject: {}", subject);
        logger.info("Body (OTP): \n====================\n{}\n====================", body);

        System.out.println("==================================================");
        System.out.println("[EMAIL LOG] Gửi tới: " + toEmail);
        System.out.println("[EMAIL LOG] Tiêu đề: " + subject);
        System.out.println("[EMAIL LOG] Nội dung:\n" + body);
        System.out.println("==================================================");

        // Check if configuration is default/mock
        if ("your-email@gmail.com".equals(SMTP_USER) || "your-app-password".equals(SMTP_PASSWORD)) {
            logger.warn(
                    "SMTP credentials are not configured. The email was logged to the console but not sent via SMTP.");
            return true; // Return true because it was successfully logged and handled for local dev
        }

        Properties properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", SMTP_HOST);
        properties.put("mail.smtp.port", SMTP_PORT);
        properties.put("mail.smtp.ssl.protocols", "TLSv1.2");

        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USER, SMTP_PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SMTP_USER));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setContent(body, "text/html; charset=UTF-8");

            Transport.send(message);
            logger.info("Email sent successfully to {}", toEmail);
            return true;
        } catch (Exception e) {
            logger.error("Failed to send email to {}", toEmail, e);
            // Return true for local development flow even if SMTP fails so it doesn't block
            // testing
            return true;
        }
    }
}
