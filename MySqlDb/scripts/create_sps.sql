DELIMITER //
CREATE PROCEDURE `sp_savegroup`(IN id varchar(128), IN name VARCHAR(255), IN ownerId VARCHAR(255))
BEGIN
INSERT INTO `group` (`id`, `name`, `ownerId`)
VALUES (id, name, ownerId)
ON DUPLICATE KEY UPDATE 
`id`=id, `name`=name, `ownerId`=ownerId;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_savetask`(IN id varchar(128), IN name VARCHAR(255), IN groupId VARCHAR(128), IN ownerId VARCHAR(128), IN isCompleted BIT)
BEGIN
INSERT INTO `task` (`id`, `name`, `groupId`,`ownerId`, `isCompleted`)
VALUES (id, name, groupId, ownerId, isCompleted)
ON DUPLICATE KEY UPDATE 
`id`=id, `name`=name, `groupId`=groupId, `ownerId`=ownerId, `isCompleted`=isCompleted;
END//
DELIMITER ;