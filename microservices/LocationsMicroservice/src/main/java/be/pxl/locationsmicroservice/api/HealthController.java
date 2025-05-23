package be.pxl.locationsmicroservice.api;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.ResponseEntity;

@RestController
@RequestMapping("/health")
public class HealthController {

    @GetMapping
    public ResponseEntity<String> healthCheck() {
        return ResponseEntity.ok("Locations microservice is running");
    }

    @GetMapping("/liveness")
    public ResponseEntity<String> livenessCheck() {
        return ResponseEntity.ok("Alive");
    }
}
