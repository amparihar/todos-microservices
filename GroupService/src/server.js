console.log("Initializing group microservice");

const path = require("path");
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const utils = require("./utils");

const routes = {
  group: require("./routes/group"),
};

var app = express();
app.set("port", 5096);
app.use(cors());

// app.use(function (req, res, next) {
//   res.header("Access-Control-Allow-Origin", "*");
//   res.header(
//     "Access-Control-Allow-Header",
//     "Origin, X-Requested-With, Content-Type, Accept"
//   );
//   next();
// });

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

function handlerFn(req, res, next) {
  next();
}

//app.use(handlerFn)

// Initial Route
app.get("/", handlerFn, function (req, res) {
  res.redirect("/api");
});

app.route("/api").get(handlerFn, function (req, res) {
  var __path = path.resolve("./");
  res.sendFile(__path + "/public/api.html");
});

// app.route("/api/groups").get(handlerFn, function (req, res) {
//   var __path = path.resolve("./");
//   res.sendFile(__dirname + "/public/groups.json");
// });

routes.group(app, handlerFn);

// 404 route
app.use(function (req, res) {
  res.status(404).send("No matching Route");
});

app.use(utils.handleServerError);
// app.use(function (error, req, res, next) {
// });

// start server
app.listen(app.get("port"), function () {
  console.log("group microservice started on port " + app.get("port"));
});
