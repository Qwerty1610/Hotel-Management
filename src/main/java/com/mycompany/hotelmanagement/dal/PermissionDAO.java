package com.mycompany.hotelmanagement.dal;

import com.mycompany.hotelmanagement.config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * Repository to manage path-based authorizations and role permissions dynamically.
 * 
 * @author TungNQ
 * @version 1.0.1
 * Created: 07/07/2026
 * Modified: 16/07/2026
 */
public class PermissionDAO {

    /**
     * Gets list of allowed role names for a given request path.
     * Checks if the path starts with any path_prefix configured in RolePath table.
     * 
     * @param path The request URI path (excluding context path)
     * @return List of role names allowed to access the path
     */
    public List<String> getAllowedRolesForPath(String path) {
        List<String> roles = new ArrayList<>();
        if (path == null) {
            return roles;
        }

        // SQL Server query to find all RolePermission mappings where path starts with the prefix.
        // e.g. path = '/admin/dashboard' will match path_prefix = '/admin'
        String sql = "SELECT r.role_name " +
                     "FROM RolePermission rp " +
                     "JOIN Role r ON rp.role_id = r.role_id " +
                     "JOIN Permission p ON rp.permission_id = p.permission_id " +
                     "WHERE ? LIKE p.path_prefix + '%'";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, path);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    roles.add(rs.getString("role_name"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return roles;
    }
}
