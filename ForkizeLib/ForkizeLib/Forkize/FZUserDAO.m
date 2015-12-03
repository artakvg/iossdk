//
//  FZUserDAO.m
//  ForkizeLib
//
//  Created by Artak on 9/14/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "FZUserDAO.h"
#import "SQLiteHelper.h"
#import "FZUser.h"

static NSString *const kSelectUserSQL = @""
"SELECT Rid, UserId, AliasedId, ChangeLog, UserProfile FROM Users where UserId=:userId order by Rid";

// FZ::POINT
static NSString *const kUpdateUserSQL = @""
"UPDATE Users SET UserId=:userId, AliasedId=:aliasedId, ChangeLog=:changeLog, UserProfile=:userProfile WHERE Rid=:rid";

static NSString *const kInsertUserSQL = @""
"INSERT INTO Users (UserId, AliasedId, ChangeLog, UserProfile) VALUES (:userId, :aliasedId, :changeLog, :userProfile)";

static NSString *const kRidParamName = @":rid";
static NSString *const kUserIdParamName = @":userId";
static NSString *const kAliasedIdParamName = @":aliasedId";
static NSString *const kChangeLogParamName = @":changeLog";
static NSString *const kUserProfileParamName = @":userProfile";

@interface FZUserDAO()

@property (nonatomic, strong) SQLiteDatabase *database;

@end

@implementation FZUserDAO

- (id) initWithSQLiteDatabase:(SQLiteDatabase *)database{
    self = [super init];
    if (nil != self) {
        self.database = database;
    }
    return self;
}


-(FZUser *) getUserFromSQLiteRow:(SQLiteRow* )row{
    FZUser *user  = [[FZUser alloc] init];
    user.rowId = [row integerAtIndex:0] ;
    user.userId = [row stringAtIndex:1];
    user.aliasedId = [row stringAtIndex:2];
    user.changeLog = [row stringAtIndex:3];
    user.userProfile = [row stringAtIndex:4];
   
    return user;
}

- (FZUser *)addUser:(NSString *) userId{
    
    FZUser *user = [[FZUser alloc] init];
    user.userId = userId;
    user.aliasedId = @"";
    user.changeLog = @"";
    user.userProfile = @"";
    
    SQLiteStatement *statement = [self.database statementWithSQLString:kInsertUserSQL];
   
    [statement setString:user.userId forParam:kUserIdParamName];
    [statement setString:user.aliasedId forParam:kAliasedIdParamName];
    [statement setString:user.changeLog forParam:kChangeLogParamName];
    [statement setString:user.userProfile forParam:kUserProfileParamName];
    
    NSInteger updateCount = [statement executeUpdate];
    NSAssert(updateCount != 0,@"Unexpected error while creating user");
    
    user.rowId = [statement lastId];
    return user;
}

- (FZUser *) getUser:(NSString *) userId{
    
    SQLiteStatement *statement = [self.database statementWithSQLString:kSelectUserSQL];
    
    [statement setString:userId forParam:kUserIdParamName];
    
    __block NSMutableArray *users = [NSMutableArray array];
  
    SQLITE_ROW_CALLBACK(rowCallBack) {
        FZUser *user  = [self getUserFromSQLiteRow:row];
        [users addObject:user];
        
        return YES;
    };
    
    [statement executeQueryWithCallBack:rowCallBack];
    // FZ::POINT
    return [users count] ? [users objectAtIndex:0] : nil;
}

- (BOOL) updateUser:(FZUser *) user{
 
    SQLiteStatement *statement = [self.database statementWithSQLString:kUpdateUserSQL];
    
    [statement setInteger:user.rowId forParam:kRidParamName];
    [statement setString:user.userId forParam:kUserIdParamName];
    [statement setString:user.aliasedId forParam:kAliasedIdParamName];
    [statement setString:user.changeLog forParam:kChangeLogParamName];
    [statement setString:user.userProfile forParam:kUserProfileParamName];
    
    return [statement executeUpdate];;
}


@end
