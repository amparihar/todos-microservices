const jwt = require("jsonwebtoken");

const taskRepo = require("../repo/taskRepo");
const env = require("../../envConfig");
const utils = require("../utils");
const { saveTaskSchema } = require("../validation-schema");

function authorizationFn(req, res, next) {
  var authToken = req.headers["authorization"],
    authTokenArr = authToken.split(" ") || [],
    bearer = authTokenArr[0] || "",
    token = authTokenArr[1] || "";

  if (
    authTokenArr.length !== 2 ||
    bearer.toLowerCase() !== "bearer" ||
    token.length === 0
  ) {
    utils.handleUnauthorized(res);
  }
  try {
    var decodedToken = jwt.verify(token, env.JWT_ACCESS_TOKEN);

    if (decodedToken && decodedToken.uid && decodedToken.uid.length > 0) {
      req.accessToken = decodedToken;
      return next();
    }
    utils.handleUnauthorized(res);
  } catch (err) {
    utils.handleUnauthorized(res, err.statusCode, {
      message: err.message || "Unauthorized Access",
    });
  }
}

async function validateSaveTaskSchema(req, res, next) {
  try {
    await saveTaskSchema.validateAsync(req.body, { abortEarly: true });
    return next();
  } catch (err) {
    utils.handleBadRequest(err, req, res, next);
  }
}

var routes = function (app, handlerfn) {
  app.route("/api/task/health-check").get(handlerfn, taskRepo.healthCheck);

  app.route("/api/task/list").get([handlerfn, authorizationFn], taskRepo.list);

  app
    .route("/api/task")
    .post([handlerfn, authorizationFn, validateSaveTaskSchema], taskRepo.save);
};

module.exports = routes;
