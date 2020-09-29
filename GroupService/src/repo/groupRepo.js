var mysqlService = require("../services/mysqlsvc"),
  utils = require("../utils");

var healthCheck = async (req, res, next) => {
  utils.handleSuccessResponse(res, "Group Service health check succeeded.");
};

var list = async (req, res, next) => {
  var { uid } = req.accessToken;
  mysqlService.lazyConnect((err, connection, release) => {
    if (err) {
      //res.status(500).send({ message: err.friendlyMessage });
      res.status(500).send(err);
    } else {
      var query = "SELECT id, name, ownerId from `group` where ownerId = ?";
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
        connection.query(query, [id, name, uid], function (
          err,
          result,
          fields
        ) {
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
        });
      } catch (err) {
        next({
          ...err,
          friendlyMessage: utils.apiFriendlyMessages.SAVE,
        });
      }
    }
  });
};

const userRepo = {
  healthCheck,
  list,
  save,
};

module.exports = userRepo;
