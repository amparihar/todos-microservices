const jwt = require("jsonwebtoken");

const groupRepo = require("../repo/groupRepo");
const env = require("../../envConfig");
const utils = require("../utils");

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

var routes = function (app, handlerfn) {
  app.route("/api/group/health-check").get(handlerfn, groupRepo.healthCheck);

  app
    .route("/api/group/list")
    .get([handlerfn, authorizationFn], groupRepo.list);

  app.route("/api/group").post([handlerfn, authorizationFn], groupRepo.save);
};

module.exports = routes;
