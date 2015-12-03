-- --------------------------------
--  Configuration
-- -------------------------------
PRAGMA foreign_keys = ON;

-- --------------------------------
--  Table structure for "Users"
-- -------------------------------
DROP TABLE IF EXISTS Users;
CREATE TABLE Users (
	 Rid integer NOT NULL PRIMARY KEY AUTOINCREMENT,
	 UserId text NOT NULL,
     AliasedId text,
     ChangeLog text,
     UserProfile text,
     UserProfileVersion text
);

DROP TABLE IF EXISTS Events;
CREATE TABLE Events  (
    Rid integer NOT NULL PRIMARY KEY AUTOINCREMENT,
    UserId text NOT NULL,
    EventData text NOT NULL
);