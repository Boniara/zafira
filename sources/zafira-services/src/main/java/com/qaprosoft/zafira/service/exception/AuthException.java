package com.qaprosoft.zafira.service.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * Exception that should be thrown to indicate that problem related to authorization or authentication occurs.
 * Reserved range 1140 - 1159
 */
public class AuthException extends ApplicationException {

    @Getter
    @RequiredArgsConstructor
    @AllArgsConstructor
    public enum AuthErrorDetail implements ErrorDetail {

        INVALID_USER_CREDENTIALS(2250),
        USER_INACTIVE(2251),
        USER_BELONGS_TO_OTHER_TENANT(2252),
        ADMIN_CREDENTIALS_INVALID(2253);

        private final Integer code;
        private String messageKey;

    }

    public AuthException() {
    }

    public AuthException(ErrorDetail errorDetail, String message) {
        super(errorDetail, message);
    }

    public AuthException(ErrorDetail errorDetail, String message, Throwable cause) {
        super(errorDetail, message, cause);
    }

    public AuthException(AuthErrorDetail errorDetail, String format, Object... args) {
        super(errorDetail, format, args);
    }

    public AuthException(AuthErrorDetail errorDetail, Throwable cause, String format, Object... args) {
        super(errorDetail, cause, format, args);
    }

}
