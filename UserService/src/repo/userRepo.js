var bcrypt = require("bcryptjs"),
  jwt = require("jsonwebtoken"),
  mysqlService = require("../services/mysqlsvc"),
  utils = require("../utils"),
  env = require("../../envConfig");

var healthCheck = async (req, res, next) => {
  res.status(200).send("User Service health check succeeded.");
};

var signUp = async (req, res, next) => {
  var { id, username, password } = req.body;
  const hashedPassword = await bcrypt.hash(password, 10);

  mysqlService.lazyConnect((err, connection, release) => {
    if (err) {
      //res.status(500).send({ message: err.friendlyMessage });
      res.status(500).send(err);
    } else {
      var query = "INSERT INTO user (id, username, password) VALUES (?, ?, ?)";
      connection.query(query, [id, username, hashedPassword], function (
        err,
        result,
        fields
      ) {
        release();
        if (err) {
          return next(
            Object.assign(err, {
              friendlyMessage:
                "An error has occurred while SignIn. Please retry again later.",
            })
          );
        }
        const accessToken = jwt.sign({ uid: id }, env.JWT_ACCESS_TOKEN);
        utils.handleResponse(res, 201, { accessToken, username: username });
      });
    }
  });
};

var signIn = async (req, res, next) => {
  var { username, password } = req.body;
  mysqlService.lazyConnect((err, connection, release) => {
    if (err) {
      //res.status(500).send({ message: err.friendlyMessage });
      res.status(500).send(err);
    } else {
      var query = "SELECT id, username, password FROM user where username = ?";
      connection.query(query, [username], async function (err, result, fields) {
        release();
        if (err) {
          return next(
            Object.assign(err, {
              friendlyMessage:
                "An error has occurred during SignIn. Please retry again later.",
            })
          );
        }

        if (result && result.length === 1) {
          try {
            const passwordsEqual = await bcrypt.compare(
              password,
              result[0].password
            );
            if (passwordsEqual) {
              const accessToken = jwt.sign(
                { uid: result[0].id },
                env.JWT_ACCESS_TOKEN
              );
              utils.handleSuccessResponse(res, {
                accessToken,
                username: username,
              });
            }
          } catch (bcryptCompareError) {
            next(bcryptCompareError);
          }
        } else {
          next({
            friendlyMessage:
              "Please recheck the username & password and try again.",
          });
        }
      });
    }
  });
};

const userRepo = {
  healthCheck,
  signUp,
  signIn,
};

module.exports = userRepo;
