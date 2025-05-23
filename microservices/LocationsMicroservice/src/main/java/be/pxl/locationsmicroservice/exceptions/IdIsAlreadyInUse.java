package be.pxl.locationsmicroservice.exceptions;

public class IdIsAlreadyInUse extends RuntimeException {
    public IdIsAlreadyInUse(String id) {
        super("Location with id: '" + id + "' already exist");
    }
}
