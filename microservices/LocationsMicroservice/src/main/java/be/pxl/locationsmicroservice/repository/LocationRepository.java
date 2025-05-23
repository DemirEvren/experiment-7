package be.pxl.locationsmicroservice.repository;

import be.pxl.locationsmicroservice.domain.LocationEntity;
import be.pxl.locationsmicroservice.exceptions.IdIsAlreadyInUse;
import be.pxl.locationsmicroservice.exceptions.LocationDoesNotExistException;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public class LocationRepository {

    private final Map<String, LocationEntity> locationStore = new HashMap<>();

    public Optional<LocationEntity> add(LocationEntity locationEntity) {
        if (locationStore.containsKey(locationEntity.getId())) {
            throw new IdIsAlreadyInUse(locationEntity.getId());
        }
        locationStore.put(locationEntity.getId(), locationEntity);
        return Optional.of(locationEntity);
    }

    public Optional<LocationEntity> findById(String id) {
        return Optional.ofNullable(locationStore.get(id));
    }

    public Optional<LocationEntity> update(LocationEntity locationEntity) {
        if (!locationStore.containsKey(locationEntity.getId())) {
            throw new LocationDoesNotExistException(locationEntity.getId());
        }
        locationStore.put(locationEntity.getId(), locationEntity);
        return Optional.of(locationEntity);
    }

    public Optional<LocationEntity> deleteById(String id) {
        if (!locationStore.containsKey(id)) {
            throw new LocationDoesNotExistException(id);
        }
        return Optional.ofNullable(locationStore.remove(id));
    }

    public List<LocationEntity> findAll() {
        return new ArrayList<>(locationStore.values());
    }
}
