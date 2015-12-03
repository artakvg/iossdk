//
//  DAOFactory.m
//  ForkizeLib
//
//  Created by Artak Martirosyan on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "DAOFactory.h"
#import "SQLiteHelper.h"
#import "FZUserDAO.h"
#import "FZEventsDAO.h"


static DAOFactory *defaultFactory_ = nil;

@interface DAOFactory()

@property (nonatomic, strong) SQLiteDatabase *database;

@end

@implementation DAOFactory

#pragma mark -
#pragma mark Memory Management

//The use of this constructor is depricated
- (id)init {
	THROW_CANT_CREATE_INSTANCE;
}

//Private constructor
- (id)initWithDBPath_:(NSString *)dbPath {
	self = [super init];
	if (nil != self) {
		self.database = [[SQLiteDatabase alloc] initWithDBPath:dbPath];
	}
	return self;
}

#pragma mark -
#pragma mark Static Interface

// FZ::TODO how to integrate in sdk
+ (DAOFactory *)defaultFactory {
	if (nil == defaultFactory_) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        
        NSString *fullPath = [path stringByAppendingPathComponent:@"projects.sqlite"];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if (![fm fileExistsAtPath:fullPath isDirectory:nil]) {
            BOOL success = [fm createFileAtPath:fullPath contents:nil attributes:nil];
            
            NSAssert(success == YES, @"Database install failed.");
            
            SQLiteDatabase *database = [[SQLiteDatabase alloc] initWithDBPath:fullPath];
            
            [database execute:@"PRAGMA foreign_keys = ON;"];
            [database execute:@"DROP TABLE IF EXISTS Users;"];
            [database execute:@"CREATE TABLE Users (Rid integer NOT NULL PRIMARY KEY AUTOINCREMENT, UserId text NOT NULL, AliasedId text, ChangeLog text, UserProfile text, UserProfileVersion text);"];
            [database execute:@"DROP TABLE IF EXISTS Events"];
            [database execute:@"CREATE TABLE Events  (Rid integer NOT NULL PRIMARY KEY AUTOINCREMENT, UserId text NOT NULL, EventData text NOT NULL);"];
         }
        
        defaultFactory_ = [[DAOFactory alloc] initWithDBPath_:fullPath];
	}
	return defaultFactory_;
}

#pragma mark -
#pragma mark Public Interface

- (FZUserDAO *) userDAO {
	return [[FZUserDAO alloc] initWithSQLiteDatabase:self.database];
}

- (FZEventsDAO *) eventsDAO{
    return  [[FZEventsDAO alloc] initWithSQLiteDatabase:self.database];
}

@end
