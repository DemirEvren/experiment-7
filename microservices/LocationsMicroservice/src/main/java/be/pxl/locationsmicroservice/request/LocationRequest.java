package be.pxl.locationsmicroservice.request;

import jakarta.validation.constraints.NotEmpty;

public record LocationRequest(
        @NotEmpty(message = "id cannot be empty")
        String id,
        @NotEmpty(message = "name cannot be empty")
        String name
) {
}
