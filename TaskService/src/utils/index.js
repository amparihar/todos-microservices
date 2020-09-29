(function (utils) {
  utils.apiFriendlyMessages = {
    LIST:
      "An error has occurred during task listing. Please retry again later.",
    SAVE:
      "An error has occurred during saving task. Please retry again later.",
    UNAUTHORIZED: "Unauthorized Access",
  };

  utils.handleServerError = function (err, req, res, next) {
    var serverErr = {
      message: err.message,
      error: err,
    };
    console.error("server error =>", serverErr);
    res
      .status(err.status || 500)
      .send({ message: serverErr.error.friendlyMessage });
  };

  utils.handleUnauthorized = function (res, code, body) {
    utils.handleResponse(res, code || 401, body || {
      message: utils.apiFriendlyMessages.UNAUTHORIZED,
    });
  };

  utils.handleSuccessResponse = function (res, body) {
    utils.handleResponse(res, 200, body);
  };

  utils.handleResponse = function (res, statusCode, body) {
    res.status(statusCode).send(body);
  };
})(module.exports);
