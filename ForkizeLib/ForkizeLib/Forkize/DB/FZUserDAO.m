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


static NSString *const kSelectAllUsersSQL = @""
"select Id, UserName, AliasedUserName, ChangeLog, UserInfo from Users order by Id";

static NSString *const kSelectUserSQL = @""
"select Id, UserName, AliasedUserName, ChangeLog, UserInfo from Users where UserName=:userName order by Id";

static NSString *const kUpdateUserSQL = @""
"update Users set UserName=:userName, AliasedUserName=:aliasedUserName, ChangeLog=:changeLog, UserInfo=:userInfo where Id=:id";

static NSString *const kInsertUserSQL = @""
"insert into Users (UserName, AliasedUserName, ChangeLog, UserInfo) values (:userName, :aliasedUserName, :changeLog, :userInfo)";

static NSString *const  kDeleteUserSQL = @""
"delete from Users where UserName=:userName";



static NSString *const kIdParamName = @":id";
static NSString *const kUserNameParamName = @":userName";
static NSString *const kAliasedUserNameParamName = @":aliasedUserName";
static NSString *const kChangeLogParamName = @":changeLog";
static NSString *const kUserInfoParamName = @":userInfo";


#define kUserIdColIndex 0
#define kUserNameColIndex 1
#define kAliasedUserNameColIndex 2
#define kChangeLogColIndex 3
#define kUserInfoColIndex 4


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
    user.Id = [row integerAtIndex:kUserIdColIndex] ;
    user.userName = [row stringAtIndex:kUserNameColIndex];
    user.aliasedName = [row stringAtIndex:kAliasedUserNameColIndex];
    user.changeLog = [row stringAtIndex:kChangeLogColIndex];
    user.userInfo = [row stringAtIndex:kUserInfoColIndex];
   
    return user;
}

- (NSArray *) loadUsers{
    __block NSMutableArray *users = [NSMutableArray array];
    SQLiteStatement *statement = [self.database statementWithSQLString:kSelectAllUsersSQL];

    SQLITE_ROW_CALLBACK(rowCallBack) {
        FZUser *user  = [self getUserFromSQLiteRow:row];
        [users addObject:user];

        return YES;
    };

    [statement executeQueryWithCallBack:rowCallBack];
    return users;
}

- (FZUser *)addUser:(NSString *) userName{
    
    FZUser *user = [[FZUser alloc] init];
    user.userName = userName;
    user.aliasedName = @"";
    user.changeLog = @"";
    user.userInfo = @"";
    
    
    SQLiteStatement *statement = [self.database statementWithSQLString:kInsertUserSQL];
   
    [statement setString:user.userName forParam:kUserNameParamName];
    [statement setString:user.aliasedName forParam:kAliasedUserNameParamName];
    [statement setString:user.changeLog forParam:kChangeLogParamName];
    [statement setString:user.userInfo forParam:kUserInfoParamName];
    
    NSInteger updateCount = [statement executeUpdate];
    NSAssert(updateCount != 0,@"Unexpected error while creating user");
    
    user.Id = [statement lastId];
    return user;
}

- (BOOL)removeUser:(NSString *) userName{

    SQLiteStatement *deleteStat = [self.database statementWithSQLString:kDeleteUserSQL];
    [deleteStat setString:userName
                  forParam:kUserNameParamName];

    return [deleteStat executeUpdate];
}

- (FZUser *) getUser:(NSString *) userName{
    
    __block NSMutableArray *users = [NSMutableArray array];
    
    SQLiteStatement *statement = [self.database statementWithSQLString:kSelectUserSQL];
    
    [statement setString:userName forParam:kUserNameParamName];
    
    SQLITE_ROW_CALLBACK(rowCallBack) {
        FZUser *user  = [self getUserFromSQLiteRow:row];
        [users addObject:user];
        
        return YES;
    };
    
    [statement executeQueryWithCallBack:rowCallBack];
    
    return [users count] ? [users objectAtIndex:0] : nil;
}

- (BOOL) updateUser:(FZUser *) user{
 
    SQLiteStatement *statement = [self.database statementWithSQLString:kUpdateUserSQL];
    
    [statement setInteger:user.Id forParam:kIdParamName];
    [statement setString:user.userName forParam:kUserNameParamName];
    [statement setString:user.aliasedName forParam:kAliasedUserNameParamName];
    [statement setString:user.changeLog forParam:kChangeLogParamName];
    [statement setString:user.userInfo forParam:kUserInfoParamName];
    
    return [statement executeUpdate];;
}


@end
