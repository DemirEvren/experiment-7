const winston = require('winston');
const { createLogger, format, transports } = winston;
const tracer = require('dd-trace').init();

const logger = createLogger({
    level: 'info',
    format: format.combine(
        format.timestamp(),
        format.json(),
        format.printf(({ timestamp, level, message, ...meta }) => ({
            timestamp,
            level,
            message,
            trace_id: tracer.scope().active()?.context().toTraceId(),
            ...meta
        }))
    ),
    transports: [
        new transports.Console(),
        new transports.Http({
            host: 'http-intake.logs.us5.datadoghq.com',
            path: `/api/v2/logs?dd-api-key=${process.env.DATADOG_API_KEY}&ddsource=nodejs&service=nodeapp`,
            ssl: true
        })
    ]
});

module.exports = logger;