const request = require("supertest");

// locaal testen en docker testen zijn apart 
const BASE_URL = "http://172.17.0.1:3000"

describe("Todo API", () => {
    test("GET /todo", async () => {
        const response = await request(BASE_URL).get("/todo");
        expect(response.status).toBe(200);
    });

    
    test("POST /todo", async () => {
        const response = await request(BASE_URL).post("/todo").send({
            title: "Test Todo",
            label: "Test",
            completed: false
        });
        expect(response.status).toBe(200);
    });
});
