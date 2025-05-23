package be.pxl.locationsmicroservice.config;

import be.pxl.locationsmicroservice.domain.LocationEntity;
import be.pxl.locationsmicroservice.repository.LocationRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DataInitializer {

    @Bean
    public CommandLineRunner loadData(LocationRepository locationRepository) {
        return args -> {
            // Check if repository is empty
            if (locationRepository.findAll().isEmpty()) {
                // Add some default locations
                locationRepository.add(new LocationEntity("loc-ny", "New York Office"));
                locationRepository.add(new LocationEntity("loc-be", "Brussels Office"));
                locationRepository.add(new LocationEntity("loc-tokyo", "Tokyo Office"));
                locationRepository.add(new LocationEntity("loc-nl", "Amsterdam Office"));
                System.out.println("Inserted default locations.");
            }
        };
    }
}
