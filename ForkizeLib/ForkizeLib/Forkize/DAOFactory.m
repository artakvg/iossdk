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
        
        NSString *fullPath = [path stringByAppendingPathComponent:@"projects.db"];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if (![fm fileExistsAtPath:fullPath isDirectory:nil]) {
            
            NSString *pathForStartingDB = [[NSBundle mainBundle] pathForResource:@"projects" ofType:@"db"];
            NSString *pathForDBStructure = [[NSBundle mainBundle] pathForResource:@"projects-db-structure" ofType:@"sql"];
            
            BOOL success = [fm copyItemAtPath:pathForStartingDB toPath:fullPath error:NULL];
            NSAssert(success == YES, @"Database install failed.");
            
            SQLiteDatabase *database = [[SQLiteDatabase alloc] initWithDBPath:fullPath];
            [database executeFile:pathForDBStructure];
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
