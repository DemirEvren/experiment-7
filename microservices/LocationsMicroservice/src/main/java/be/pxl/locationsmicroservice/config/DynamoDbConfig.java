// package be.pxl.locationsmicroservice.config;

// import org.springframework.context.annotation.Bean;
// import org.springframework.context.annotation.Configuration;
// import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
// import software.amazon.awssdk.services.dynamodb.DynamoDbClient;

// @Configuration
// public class DynamoDbConfig {

//     @Bean
//     public DynamoDbClient dynamoDbClient() {
//         return DynamoDbClient.create(); // You can configure region/credentials here
//     }

//     @Bean
//     public DynamoDbEnhancedClient dynamoDbEnhancedClient(DynamoDbClient dynamoDbClient) {
//         return DynamoDbEnhancedClient.builder()
//                 .dynamoDbClient(dynamoDbClient)
//                 .build();
//     }
// }

