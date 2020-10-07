CREATE TABLE user (
    id VARCHAR(128) PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL
);

CREATE TABLE `group` (
    id VARCHAR(128) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    ownerId VARCHAR(128),
    FOREIGN KEY (ownerId) REFERENCES user(id) ON DELETE CASCADE
);

CREATE TABLE task (
    id VARCHAR(128) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    groupId VARCHAR(128),
    ownerId VARCHAR(128),
    isCompleted boolean DEFAULT false,
    FOREIGN KEY (groupId) REFERENCES `group`(id) ON DELETE CASCADE,
    FOREIGN KEY (ownerId) REFERENCES user(id) ON DELETE CASCADE
);

