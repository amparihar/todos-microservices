var mysqlService = require("../services/mysqlsvc"),
  utils = require("../utils");

var healthCheck = async (req, res, next) => {
  utils.handleSuccessResponse(
    res,
    "Progress Tracker Service health check succeeded."
  );
};

var groups = async (req, res, next) => {
  var { uid } = req.accessToken;
  mysqlService.lazyConnect((err, connection, release) => {
    if (err) {
      res.status(500).send(err);
    } else {
      var query =
        "SELECT t1.groupId, t1.ownerId, round((t2.completedtaskcount/count(*) * 100),1) as progresspercent FROM task AS t1 \
        JOIN (SELECT groupId, ownerId, count(*) AS completedtaskcount FROM task WHERE isCompleted = 1 GROUP BY groupId, ownerId) AS t2 \
        ON t1.groupId = t2.groupId AND t1.ownerId = t2.ownerId \
        WHERE t1.ownerId = ? \
        GROUP BY t1.groupId, t1.ownerId";
      connection.query(query, [uid], function (err, result, fields) {
        release();
        if (err) {
          return next({
            ...err,
            friendlyMessage: utils.apiFriendlyMessages.LIST,
          });
        }
        utils.handleSuccessResponse(res, result);
      });
    }
  });
};

var group = async (req, res, next) => {
  var { uid } = req.accessToken;
  var { groupId } = req.params;
  if (!groupId) {
    res.writeHead(400, { "Content-type": "application/json" });
    res.end(JSON.stringify({ error: "Please provide groupId" }));
  }
  mysqlService.lazyConnect((err, connection, release) => {
    if (err) {
      res.status(500).send(err);
    } else {
      var query =
        "SELECT t1.groupId, round((t2.completedtaskcount/count(*) * 100),1) as progresspercent FROM task AS t1 \
      JOIN (SELECT groupId, count(*) AS completedtaskcount FROM task WHERE isCompleted = 1 GROUP BY groupId) AS t2 \
      ON t1.groupId = t2.groupId \
      WHERE t1.groupId = ? \
      GROUP BY t1.groupId";
      connection.query(query, [groupId], function (err, result, fields) {
        release();
        if (err) {
          return next({
            ...err,
            friendlyMessage: utils.apiFriendlyMessages.LIST,
          });
        }
        utils.handleSuccessResponse(res, result);
      });
    }
  });
};

const progressRepo = {
  healthCheck,
  groups,
  group,
};

module.exports = progressRepo;
