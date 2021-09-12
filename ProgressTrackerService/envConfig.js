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
};

module.exports = envConfig;
