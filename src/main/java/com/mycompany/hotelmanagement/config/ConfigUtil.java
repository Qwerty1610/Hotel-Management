package com.mycompany.hotelmanagement.config;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class ConfigUtil {

    private static final Properties properties = new Properties();

    static {
        try (InputStream input = ConfigUtil.class.getClassLoader().getResourceAsStream("config.properties")) {
            if (input != null) {
                properties.load(input);
            }
        } catch (IOException e) {
            // Ignore missing config file; fallback values will be used.
        }
    }

    public static String get(String key, String defaultValue) {
        // 1. Try to find the exact key in config.properties
        String value = properties.getProperty(key);
        
        // 2. Try the uppercase/underscore variant in config.properties
        if (value == null || value.trim().isEmpty()) {
            String alternativeKey = key.toUpperCase().replace('.', '_');
            value = properties.getProperty(alternativeKey);
        }
        
        // 3. Try System.getenv for env vars
        if (value == null || value.trim().isEmpty()) {
            value = System.getenv(key);
        }
        if (value == null || value.trim().isEmpty()) {
            String alternativeKey = key.toUpperCase().replace('.', '_');
            value = System.getenv(alternativeKey);
        }
        
        // 4. Try System properties
        if (value == null || value.trim().isEmpty()) {
            value = System.getProperty(key);
        }
        if (value == null || value.trim().isEmpty()) {
            String alternativeKey = key.toUpperCase().replace('.', '_');
            value = System.getProperty(alternativeKey);
        }
        
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        return value.trim();
    }

    public static String get(String key) {
        return get(key, null);
    }
}
