const Joi = require("joi");

const saveGroupSchema = Joi.object({
  id: Joi.string().min(1).required(),
  name: Joi.string().min(1).required(),
});

module.exports = {
  saveGroupSchema,
};
