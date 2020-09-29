(function (mysqlService, mysql, env) {
  var connectionConfig = {
      host: env.RDS_HOST,
      user: env.RDS_USERNAME,
      password: env.RDS_PASSWORD,
      database: env.RDS_DB_NAME,
      port: env.RDS_PORT,
    },
    connection = mysql.createConnection(connectionConfig),
    pool = mysql.createPool({
      ...connectionConfig,
      connectionLimit: env.RDS_CONN_POOL_SIZE,
    });

  mysqlService.connect = function (cb) {
    connection.connect(function (err) {
      //console.log("connectionConfig =>>", connectionConfig);
      if (err) {
        console.log("connecting error =>>", err.stack);
        // console.log("connection =>>", conn);
        Object.assign(err, {
          friendlyMessage: "An error has occurred. Please retry again later.",
        });
      }
      return cb(err, connection, function () {
        connection.end();
      });
    });
  };

  mysqlService.lazyConnect = function (cb) {
    pool.getConnection(function (err, conn) {
      //console.log("connectionConfig =>>", connectionConfig);
      if (err) {
        console.log("connecting error =>>", err.stack);
        // console.log("connection =>>", connection);
        Object.assign(err, {
          friendlyMessage: "An error has occurred. Please retry again later.",
        });
      }
      return cb(err, conn, function () {
        conn.release();
      });
    });
  };
})(module.exports, require("mysql"), require("../../envConfig"));
