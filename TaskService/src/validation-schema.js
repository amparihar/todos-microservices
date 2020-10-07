const Joi = require("joi");

const saveTaskSchema = Joi.object({
  id: Joi.string().min(1).required(),
  name: Joi.string().min(1).required(),
  groupId: Joi.string().min(1).required(),
  isComplete: Joi.boolean().optional(),
});

module.exports = {
  saveTaskSchema,
};
