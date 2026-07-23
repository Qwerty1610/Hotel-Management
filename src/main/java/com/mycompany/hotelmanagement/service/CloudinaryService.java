package com.mycompany.hotelmanagement.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.mycompany.hotelmanagement.config.CloudinaryConfig;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Map;
/**
 * Created: 19/07/2026
 * @author MinhTDP
 */

public class CloudinaryService {

    private final Cloudinary cloudinary;

    public CloudinaryService() {
        this.cloudinary = CloudinaryConfig.getCloudinary();
    }

    public String uploadImage(Part part) throws IOException {

        if (part == null || part.getSize() == 0) {
            return null;
        }

        // Tạo file tạm
        File tempFile = File.createTempFile("upload-", "-" + part.getSubmittedFileName());

        try {

            // Ghi dữ liệu upload vào file tạm
            Files.copy(part.getInputStream(), tempFile.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);

            Map<?, ?> result = cloudinary.uploader().upload(
                    tempFile,
                    ObjectUtils.emptyMap()
            );

            return result.get("secure_url").toString();

        } catch (Exception e) {
            throw new IOException("Upload image failed", e);
        } finally {
            tempFile.delete();
        }
    }
}