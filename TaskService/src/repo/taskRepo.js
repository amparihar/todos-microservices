var mysqlService = require("../services/mysqlsvc"),
  utils = require("../utils"),
  env = require("../../envConfig");

const axios = require("axios");

var healthCheck = async (req, res, next) => {
  utils.handleSuccessResponse(res, "Task Service health check succeeded.");
};

var getProgress = async (authToken, groupId) => {
  try {
    var url;
    if (env.PROGRESS_TRACKER_API_PORT === "") {
      url =
        "http://" +
        env.PROGRESS_TRACKER_API_HOST +
        "/api/progress/group" +
        groupId;
    }
    else {
      url =
        "http://" +
        env.PROGRESS_TRACKER_API_HOST +
        ":" +
        env.PROGRESS_TRACKER_API_PORT +
        "/api/progress/groups" +
        groupId;
    }

    const headers = { Authorization: authToken };
    const progressResponse = await axios.get(url, { headers });
    return { status: progressResponse.status, data: progressResponse.data };
  }
  catch (error) {
    console.log("getProgress error ", error);
    return {
      status: 500,
      data: [],
      error: "Sorry, progress tracker is currently unavailable.",
    };
  }
};

var list = async (req, res, next) => {
  var { uid } = req.accessToken;
  mysqlService.lazyConnect((err, connection, release) => {
    if (err) {
      //res.status(500).send({ message: err.friendlyMessage });
      res.status(500).send(err);
    }
    else {
      var query =
        "SELECT id, name, groupId, ownerId, isCompleted from task where ownerId = ? ORDER BY isCompleted ASC";
      connection.query(query, [uid], function(err, result, fields) {
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

var save = async (req, res, next) => {
  var { uid } = req.accessToken;
  var { id, name, groupId, isCompleted } = req.body;
  mysqlService.lazyConnect((err, connection, release) => {
    if (err) {
      res.status(500).send(err);
    }
    else {
      try {
        var query = "CALL sp_savetask(?,?,?,?,?)";
        connection.query(
          query,
          [id, name, groupId, uid, isCompleted],
          async function(err, result, fields) {
            release();
            if (err) {
              return next({
                ...err,
                friendlyMessage: utils.apiFriendlyMessages.SAVE,
              });
            }
            // get group progress
            const authToken = req.headers["authorization"];
            const progressList = await getProgress(authToken, groupId);
            const { status, data: progressData } = progressList;
            // get first item from progressData while ignoring the rest
            const [groupProgress = {}, ...rest] = progressData;
            const apiResponse = {
              id,
              name,
              groupId,
              ownerId: uid,
              isCompleted,
              progresspercent: groupProgress.progresspercent || 0,
            };
            utils.handleResponse(res, 201, apiResponse);
          }
        );
      }
      catch (err) {
        next({
          ...err,
          friendlyMessage: utils.apiFriendlyMessages.SAVE,
        });
      }
    }
  });
};

const taskRepo = {
  healthCheck,
  list,
  save,
};

module.exports = taskRepo;
