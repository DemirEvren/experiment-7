package be.pxl.locationsmicroservice.api;

import be.pxl.locationsmicroservice.DTO.LocationDTO;
import be.pxl.locationsmicroservice.request.LocationRequest;
import be.pxl.locationsmicroservice.service.LocationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List; 

@RestController
@RequestMapping("/locations")
public class LocationController {
    private final LocationService locationService;

    @Autowired
    public LocationController(LocationService locationService) {
        this.locationService = locationService;
    }

    @GetMapping
    public ResponseEntity<List<LocationDTO>> getAllLocations() {
        var output = locationService.getAllLocations();
        return ResponseEntity.ok(output);
    }
    
    @PostMapping
    public ResponseEntity<LocationDTO> addLocation(@RequestBody LocationRequest location) {
        var output = locationService.AddLocation(location);
        return ResponseEntity.ok(output);
    }

    @GetMapping("{id}")
    public ResponseEntity<LocationDTO> getLocation(@PathVariable("id") String id) {
        var output = locationService.getLocation(id);
        return ResponseEntity.ok(output);
    }

    @PutMapping("{id}")
    public ResponseEntity<LocationDTO> updateLocation(@PathVariable("id") String id, @RequestBody LocationRequest location) {
        var output = locationService.updateLocation(id, location);
        return ResponseEntity.ok(output);
    }

    @DeleteMapping("{id}")
    public ResponseEntity<LocationDTO> deleteLocation(@PathVariable("id") String id) {
        var output = locationService.deleteLocation(id);
        return ResponseEntity.ok(output);
    }
}
