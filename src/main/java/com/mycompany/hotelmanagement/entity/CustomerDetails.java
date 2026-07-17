package com.mycompany.hotelmanagement.entity;

/**
 * Project: Hotel Management System
 * Class: CustomerDetails
 *
 * Description:
 * Data Transfer Object gọn nhẹ mang thông tin họ tên, email và số điện thoại
 * của khách hàng
 * để tra cứu trong quá trình tạo đặt phòng trực tiếp (walk-in) hoặc trực
 * tuyến. Được sử dụng để điền sẵn các trường trên biểu mẫu khi tìm thấy tài
 * khoản.
 *
 * Related Use Cases:
 * - UC-11 Create Booking
 * - UC-13 Create Walk-in Booking
 * 
 * Date: 09-07-2026
 * 
 * @author BinhHD
 * @version 1.0
 */

public class CustomerDetails {
    private String fullName;
    private String email;
    private String phone;

    public CustomerDetails() {
    }

    public CustomerDetails(String fullName, String email, String phone) {
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }
}
