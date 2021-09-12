const Joi = require("joi");

const saveGroupSchema = Joi.object({
  id: Joi.string().min(1).required(),
  name: Joi.string().min(1).required(),
  ownerId: Joi.string().optional(),
});

module.exports = {
  saveGroupSchema,
};