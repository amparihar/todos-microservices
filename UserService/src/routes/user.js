const userRepo = require("../repo/userRepo");

var routes = function (app, handlerfn) {

  app.route("/api/user/health-check").get(handlerfn, userRepo.healthCheck);

  app.route("/api/user/signin").post(handlerfn, userRepo.signIn);

  app.route("/api/user/signup").post(handlerfn, userRepo.signUp);
};

module.exports = routes;
