// =================================================================
// STANDALONE LOGIN PAGE LOGIC
// =================================================================

document.addEventListener('DOMContentLoaded', function () {
    // Helper function to read Cookie by name
    function getCookie(name) {
        const nameEQ = name + "=";
        const ca = document.cookie.split(';');
        for (let i = 0; i < ca.length; i++) {
            let c = ca[i];
            while (c.charAt(0) === ' ') c = c.substring(1, c.length);
            if (c.indexOf(nameEQ) === 0) {
                let val = c.substring(nameEQ.length, c.length);
                return decodeURIComponent(val.replace(/\+/g, ' '));
            }
        }
        return null;
    }

    // Auto-fill username, password, and checkbox if cookies exist
    const rememberUser = getCookie('rememberUser');
    const rememberPass = getCookie('rememberPass');
    const rememberMe = getCookie('rememberMe');

    if (rememberMe === 'true' && rememberUser && rememberPass) {
        const usernameField = document.getElementById('username');
        const passwordField = document.getElementById('password');
        const rememberCheckbox = document.querySelector('input[name="remember"]');
        
        if (usernameField) usernameField.value = rememberUser;
        if (passwordField) passwordField.value = rememberPass;
        if (rememberCheckbox) rememberCheckbox.checked = true;
    }
});
