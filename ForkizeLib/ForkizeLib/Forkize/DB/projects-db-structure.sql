-- --------------------------------
--  Configuration
-- -------------------------------
PRAGMA foreign_keys = ON;

-- --------------------------------
--  Table structure for "Users"
-- -------------------------------
DROP TABLE IF EXISTS Users;
CREATE TABLE Users (
	 Id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
	 UserName text NOT NULL,
     AliasedUserName text,
     ChangeLog text,
     UserInfo text
);

DROP TABLE IF EXISTS Events;
CREATE TABLE Events  (
    Id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
    UserName text NOT NULL,
    EventValue text NOT NULL
);