package com.mycompany.hotelmanagement.service;

import com.mycompany.hotelmanagement.dal.AccountRepository;
import com.mycompany.hotelmanagement.entity.ProfileView;

/**
 * Business logic for viewing and editing the personal profile of the
 * currently logged-in user (any role). Validation lives here; the controller
 * only translates HTTP to method calls and back.
 *
 * @author QuyPQ
 */
public class ProfileService {

    private static final int MAX_NAME_LENGTH = 100;
    // Same phone rule used at registration: starts with 0, then 3/5/7/8/9, then 8 digits.
    private static final String PHONE_REGEX = "^0[35789]\\d{8}$";

    private final AccountRepository accountRepository = new AccountRepository();

    public ProfileView getProfile(int accountId) {
        if (accountId <= 0) {
            return null;
        }
        return accountRepository.getProfileByAccountId(accountId);
    }

    /**
     * Validate and persist a profile edit (full name + phone only).
     *
     * @return a result code consumed by the view to render the proper message:
     *         "success", "name_required", "name_too_long", "invalid_phone",
     *         "phone_exists", "not_found", "server_error".
     */
    public String updateProfile(int accountId, String fullName, String phone) {
        if (accountId <= 0) {
            return "not_found";
        }

        ProfileView current = accountRepository.getProfileByAccountId(accountId);
        if (current == null) {
            return "not_found";
        }

        // --- Validate full name ---
        if (fullName != null) {
            fullName = fullName.trim();
        }
        if (fullName == null || fullName.isEmpty()) {
            return "name_required";
        }
        if (fullName.length() > MAX_NAME_LENGTH) {
            return "name_too_long";
        }

        // --- Validate phone ---
        if (phone != null) {
            phone = phone.trim();
        }
        if (phone == null || phone.isEmpty() || !phone.matches(PHONE_REGEX)) {
            return "invalid_phone";
        }
        if (accountRepository.existsByPhoneExcept(phone, accountId)) {
            return "phone_exists";
        }

        boolean ok = accountRepository.updateOwnProfile(accountId, fullName, phone);
        if (!ok) {
            return "server_error";
        }
        return "success";
    }
}
