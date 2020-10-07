const userRepo = require("../repo/userRepo");
const utils = require("../utils");
const { signInSchema, signUpSchema } = require("../validation-schema");

async function validateSignInSchema(req, res, next) {
  try {
    await signInSchema.validateAsync(req.body, { abortEarly: true });
    next();
  } catch (err) {
    utils.handleBadRequest(err, req, res, next);
  }
}

async function validateSignUpSchema(req, res, next) {
  try {
    await signUpSchema.validateAsync(req.body, { abortEarly: true });
    next();
  } catch (err) {
    utils.handleBadRequest(err, req, res, next);
  }
}

var routes = function (app, handlerfn) {
  app.route("/api/user/health-check").get(handlerfn, userRepo.healthCheck);

  app
    .route("/api/user/signin")
    .post([handlerfn, validateSignInSchema], userRepo.signIn);

  app
    .route("/api/user")
    .post([handlerfn, validateSignUpSchema], userRepo.signUp);
};

module.exports = routes;
