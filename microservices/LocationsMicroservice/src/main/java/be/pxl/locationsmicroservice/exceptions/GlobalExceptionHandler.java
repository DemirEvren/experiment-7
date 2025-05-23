package be.pxl.locationsmicroservice.exceptions;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.LinkedHashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private ResponseEntity<Map<String, Object>> createErrorResponse(String fieldName, String errorMessage, int code) {
        // Create a LinkedHashMap to hold the error details
        Map<String, String> errors = new LinkedHashMap<>();
        errors.put(fieldName, errorMessage);

        // Create the response LinkedHashMap with a structured response format
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("Details", errors);

        // Return the response with code
        return ResponseEntity.status(code).body(response);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidationExceptions(MethodArgumentNotValidException ex) {
        // LinkedHashMap to preserve the order of the error json
        Map<String, String> errors = new LinkedHashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error ->
                errors.put(error.getField(), error.getDefaultMessage())
        );

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("info", "Ongeldige of ontbrekende gegevens.");
        response.put("details", errors);

        return ResponseEntity.status(400).body(response);
    }

    @ExceptionHandler(LocationDoesNotExistException.class)
    public ResponseEntity<Map<String, Object>> handleItemDoesNotExistExceptions(LocationDoesNotExistException ex) {
        return createErrorResponse("Location", ex.getMessage(), 404);
    }

    @ExceptionHandler(IdIsAlreadyInUse.class)
    public ResponseEntity<Map<String, Object>> handleIdsAlreadyInUseExceptions(IdIsAlreadyInUse ex) {
        return createErrorResponse("Location", ex.getMessage(), 404);
    }

}
