const Joi = require("joi");

const signInSchema = Joi.object({
  username: Joi.string().min(1).required(),
  password: Joi.string().min(1).required(),
});

const signUpSchema = Joi.object({
  id: Joi.string().min(1).required(),
  username: Joi.string().min(1).required(),
  password: Joi.string().min(1).required(),
});

module.exports = {
  signInSchema,
  signUpSchema,
};
