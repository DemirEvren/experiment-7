package be.pxl.locationsmicroservice.service;

import be.pxl.locationsmicroservice.DTO.LocationDTO;
import be.pxl.locationsmicroservice.domain.LocationEntity;
import be.pxl.locationsmicroservice.exceptions.LocationDoesNotExistException;
import be.pxl.locationsmicroservice.repository.LocationRepository;
import be.pxl.locationsmicroservice.request.LocationRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List; 
import java.util.stream.Collectors;

@Service
public class LocationService {

    private final LocationRepository locationRepository;

    @Autowired
    public LocationService(LocationRepository locationRepository) {
        this.locationRepository = locationRepository;
    }

    public LocationDTO AddLocation(LocationRequest location) {
        var x = locationRepository.add(new LocationEntity(location.id(), location.name()));
        return x.map(LocationDTO::new).orElseThrow(() -> new LocationDoesNotExistException(location.id())); // this should never trigger but...
    }

    public LocationDTO getLocation(String id) {
        return locationRepository.findById(id).map(LocationDTO::new).orElseThrow(() -> new LocationDoesNotExistException(id));
    }

    public LocationDTO updateLocation(String id, LocationRequest location) {
        return locationRepository.update(new LocationEntity(id, location.name())).map(LocationDTO::new).orElseThrow(() -> new LocationDoesNotExistException(id));
    }

    public LocationDTO deleteLocation(String id) {
        return locationRepository.deleteById(id).map(LocationDTO::new).orElseThrow(() -> new LocationDoesNotExistException(id));
    }
    public List<LocationDTO> getAllLocations() {
        return locationRepository.findAll()
                .stream()
                .map(LocationDTO::new)
                .collect(Collectors.toList());
    }
}
