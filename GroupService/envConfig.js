//const dotenv = require("dotenv");
//dotenv.config();

var envConfig = {
  RDS_HOST: process.env.RDS_HOST,
  RDS_USERNAME: process.env.RDS_USERNAME,
  RDS_PASSWORD: process.env.RDS_PASSWORD,
  RDS_DB_NAME: process.env.RDS_DB_NAME,
  RDS_PORT: process.env.RDS_PORT,
  RDS_CONN_POOL_SIZE: process.env.RDS_CONN_POOL_SIZE,
  JWT_ACCESS_TOKEN: process.env.JWT_ACCESS_TOKEN,
  JWT_REFRESH_TOKEN: process.env.JWT_REFRESH_TOKEN,
  PROGRESS_TRACKER_API_HOST: process.env.PROGRESS_TRACKER_API_HOST,
  PROGRESS_TRACKER_API_PORT: process.env.PROGRESS_TRACKER_API_PORT,
  HEALTH_CHECK_SLEEP_DURATION_MS: process.env.HEALTH_CHECK_SLEEP_DURATION_MS
};

module.exports = envConfig;
