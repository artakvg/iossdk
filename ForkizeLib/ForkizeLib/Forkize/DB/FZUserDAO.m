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
"select Id, UserName, AliasedUserName, ChangeLog from Users order by Id";

static NSString *const kSelectUserSQL = @""
"select Id, UserName, AliasedUserName, ChangeLog from Users where UserName=:userName order by Id";

static NSString *const kUpdateUserSQL = @""
"update Users set UserName=:userName, AliasedUserName=:aliasedUserName, ChangeLog=:changeLog where Id=:id";



static NSString *const kInsertUserSQL = @""
"insert into Users (UserName, AliasedUserName) values (:userName, :aliasedUserName)";

static NSString *const  kDeleteUserSQL = @""
"delete from Users where UserName=:userName";



static NSString *const kIdParamName = @":id";
static NSString *const kUserNameParamName = @":userName";
static NSString *const kAliasedUserNameParamName = @":aliasedUserName";
static NSString *const kChangeLogParamName = @":changeLog";


#define kUserIdColIndex 0
#define kUserNameColIndex 1
#define kAliasedUserNameColIndex 2
#define kChangeLogColIndex 3


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
    
    
    SQLiteStatement *statement = [self.database statementWithSQLString:kInsertUserSQL];
   
    [statement setString:user.userName forParam:kUserNameParamName];
    
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
    
    return [users objectAtIndex:0];
}

- (BOOL) updateUser:(FZUser *) user{
 
    SQLiteStatement *statement = [self.database statementWithSQLString:kUpdateUserSQL];
    
    [statement setInteger:user.Id forParam:kIdParamName];
    [statement setString:user.userName forParam:kUserNameParamName];
    [statement setString:user.aliasedName forParam:kAliasedUserNameParamName];
    [statement setString:user.changeLog forParam:kChangeLogParamName];
    
    return [statement executeUpdate];;
}


@end
