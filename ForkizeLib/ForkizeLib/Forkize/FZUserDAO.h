//
//  FZUserDAO.h
//  ForkizeLib
//
//  Created by Artak on 9/14/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SQLiteDatabase;
@class FZUser;

@interface FZUserDAO : NSObject

- (id) initWithSQLiteDatabase:(SQLiteDatabase *)database;

- (NSArray *) loadUsers;

- (FZUser *) addUser:(NSString *) userName;

- (BOOL) removeUser:(NSString *) userName;

- (FZUser *) getUser:(NSString *) userName;

- (BOOL) updateUser:(FZUser *) user;


@end
