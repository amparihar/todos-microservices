var mysqlService = require("../services/mysqlsvc"),
  utils = require("../utils"),
  env = require("../../envConfig");

const axios = require("axios");
const prometheus = require("prom-client");

const register = new prometheus.Registry();
// Add a default label which is added to all metrics
register.setDefaultLabels({
  app: 'group-microsvc'
});
// Enable the collection of default metrics
//prometheus.collectDefaultMetrics({ register });
const list_api_requests = new prometheus.Counter({
  name : "group_list_api_request_count",
  help: "group_list_api_request_count"
});
register.registerMetric(list_api_requests);

var healthCheck = async (req, res, next) => {
  await sleep(env.HEALTH_CHECK_SLEEP_DURATION_MS || 0);
  utils.handleSuccessResponse(res, "Group Service health check succeeded.");
};

var sleep = (ms) => {
  return new Promise((resolve) => {
    setTimeout(resolve, parseInt(ms));
  });
}

var metrics = async (req, res, next) => {
  res.status(200).set('Content-Type', 'text/plain');
  res.end(await register.metrics());
}

var getProgress = async (authToken) => {
  try {
    const url =
      "http://" +
      env.PROGRESS_TRACKER_API_HOST +
      ":" +
      env.PROGRESS_TRACKER_API_PORT +
      "/api/progress/groups";
    const headers = { Authorization: authToken };
    const progressResponse = await axios.get(url, { headers });
    return { status: progressResponse.status, data: progressResponse.data };
  } catch (error) {
    console.log("getProgress error ", error);
    return {
      status: 500,
      data: [],
      error: "Sorry, progress tracker is currently unavailable.",
    };
  }
};

var list = async (req, res, next) => {
  list_api_requests.inc();
  var { uid } = req.accessToken;
  mysqlService.lazyConnect((err, connection, release) => {
    if (err) {
      //res.status(500).send({ message: err.friendlyMessage });
      res.status(500).send(err);
    } else {
      var query = "SELECT id, name, ownerId from `group` where ownerId = ?";
      connection.query(query, [uid], async function (err, groupList, fields) {
        release();
        if (err) {
          return next({
            ...err,
            friendlyMessage: utils.apiFriendlyMessages.LIST,
          });
        }
        // get progress for all user groups
        const authToken = req.headers["authorization"];
        const progressList = await getProgress(authToken);
        const { status, data: progressData } = progressList;
        const apiResponse = groupList.map((group) => {
          const match = progressData.find((item) => item.groupId === group.id);
          return {
            id: group.id,
            name: group.name,
            ownerId: group.ownerId,
            progresspercent: match ? match.progresspercent : 0,
          };
        });
        utils.handleSuccessResponse(res, apiResponse);
      });
    }
  });
};

var save = async (req, res, next) => {
  var { uid } = req.accessToken;
  // TODO: Validate schema
  var { id, name } = req.body;
  mysqlService.lazyConnect((err, connection, release) => {
    if (err) {
      //res.status(500).send({ message: err.friendlyMessage });
      res.status(500).send(err);
    } else {
      try {
        var query = "CALL sp_savegroup(?,?,?)";
        connection.query(
          query,
          [id, name, uid],
          function (err, result, fields) {
            release();
            if (err) {
              return next({
                ...err,
                friendlyMessage: utils.apiFriendlyMessages.SAVE,
              });
            }
            utils.handleResponse(res, 201, {
              id,
              name,
              ownerId: uid,
            });
          }
        );
      } catch (err) {
        next({
          ...err,
          friendlyMessage: utils.apiFriendlyMessages.SAVE,
        });
      }
    }
  });
};

const groupRepo = {
  healthCheck,
  metrics,
  list,
  save,
};

module.exports = groupRepo;
