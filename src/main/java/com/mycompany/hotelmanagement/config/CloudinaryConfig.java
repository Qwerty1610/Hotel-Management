/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.hotelmanagement.config;

import com.cloudinary.Cloudinary;
import java.util.HashMap;
import java.util.Map;

/**
 * Created: 19/07/2026
 * @author MinhTDP
 */
public class CloudinaryConfig {

    private static final Cloudinary CLOUDINARY;

    static {

        Map<String, String> config = new HashMap<>();

        config.put("cloud_name", "s87kient");
        config.put("api_key", "114676896845231");
        config.put("api_secret", "AFfpmX4F7zpdeKs5rgeqPpHE_rg");
        config.put("secure", "true");

        CLOUDINARY = new Cloudinary(config);
    }

    public static Cloudinary getCloudinary() {
        return CLOUDINARY;
    }
}
