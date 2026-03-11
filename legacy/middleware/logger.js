const { createLogger, format, transports } = require('winston');

const logger = createLogger({
  level: 'info',
  format: format.combine(
    format.timestamp(),
    format.errors({ stack: true }),
    format.splat(),
    format.json()
  ),
  defaultMeta: { service: 'agrivision-api-gateway' },
  transports: [
    new transports.Console()
  ],
});

const logRequest = (req, res, next) => {
  logger.info({
    message: 'Incoming request',
    method: req.method,
    url: req.originalUrl,
    requestId: req.id,
    ip: req.ip,
    userAgent: req.headers['user-agent']
  });
  next();
};

module.exports = {
  logger,
  logRequest
};
