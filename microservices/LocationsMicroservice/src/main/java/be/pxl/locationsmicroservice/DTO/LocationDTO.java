package be.pxl.locationsmicroservice.DTO;

import be.pxl.locationsmicroservice.domain.LocationEntity;

public record LocationDTO(
        String id,
        String name
) {
    public LocationDTO(LocationEntity locationEntity) {
        this(
                locationEntity.getId(),
                locationEntity.getName()
        );
    }

}
