package be.pxl.locationsmicroservice.exceptions;

public class LocationDoesNotExistException extends RuntimeException {
    public LocationDoesNotExistException(String id) {
        super("Location with id: '" + id + "' does not exist");
    }
}
