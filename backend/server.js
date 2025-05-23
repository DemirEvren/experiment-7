require('dotenv').config();

const tracer = require('dd-trace').init({
    hostname: 'datadog-agent',
    port: 8126
});


const logger = require('./logger');
const express = require('express');
const cors = require('cors');
const healthRoutes = require('./routes/health.routes');
const todoRoutes = require('./routes/todo.routes');
const carrouselRoutes = require('./routes/carrousel.routes');

const app = express();
const db = require('./db');

const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Middleware for HTTP 4xx/5xx errors
app.use((req, res, next) => {
    res.on('finish', () => {
        if (res.statusCode >= 400) {
            logger.error(`HTTP ${req.method} ${req.originalUrl} failed with status ${res.statusCode}`, {
                method: req.method,
                url: req.originalUrl,
                status: res.statusCode,
                headers: req.headers,
                body: req.body
            });
        }
    });
    next();
});

// CSP Middleware to prevent xss,url changes, script injection,.. but doeesn't quite work yet, 
app.use((req, res, next) => {
    const additionalDetails = encodeURIComponent(JSON.stringify({
        ip: req.ip,
        userAgent: req.headers['user-agent'],
        path: req.originalUrl,
        method: req.method,
        headers: req.headers
    }));

res.setHeader("Content-Security-Policy",
    "default-src 'self'; " +
    "script-src 'self' 'nonce-randomValue'; " +
    "style-src 'self' 'nonce-randomValue' https://fonts.googleapis.com; " +
    "style-src-elem 'self' https://fonts.googleapis.com; " +
    "style-src-attr 'self'; " +
    "img-src 'self' https://cdn.pixabay.com https://www.gettyimages.be; " +
    "font-src 'self' https://fonts.gstatic.com; " +
    "connect-src 'self' https://f94cmxffe6.execute-api.us-east-1.amazonaws.com; " +
    "object-src 'none'; " +
    "base-uri 'none'; " +
    "form-action 'self'; " +
    "report-uri https://http-intake.logs.us5.datadoghq.com/api/v2/logs?" +
    `dd-api-key=${process.env.DATADOG_API_KEY}&ddsource=browser&service=frontend-app&env=production`
);

next();
});

app.use('/health', healthRoutes);
app.use('/todo', todoRoutes);
app.use('/carrousel', carrouselRoutes);

// Error-Handling Middleware for runtime errors
app.use((err, req, res, next) => {
    logger.error(`Error during HTTP ${req.method} ${req.originalUrl}: ${err.message}`, {
        method: req.method,
        url: req.originalUrl,
        status: res.statusCode || 500,
        stack: err.stack
    });
    res.status(500).json({ error: 'Internal Server Error' });
});

// Catch unhandled exceptions
process.on('uncaughtException', (err) => {
    logger.error(`Uncaught Exception: ${err.message}`, { stack: err.stack });
    process.exit(1);
});

// Catch unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
    logger.error(`Unhandled Rejection: ${reason}`);
});

const server = app.listen(PORT, () => {
    logger.info('TESTER');
    console.log(`Server is listening on port ${PORT}`);
});

// Catch server-level errors like `EADDRINUSE` or `EACCES`
server.on('error', (err) => {
    logger.error(`Server Error: ${err.message}`, { stack: err.stack });
});