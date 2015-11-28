//
//  UserProfile.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "UserProfile.h"

#import "UserProfileInternal.h"

//#import "ForkizeHelper.h"
//#import "LocalStorageManager.h"
//#import "ForkizeConfig.h"
//#import "RestClient.h"
//
//#import "FZUser.h"
////#import "FZEvent.h"
//
//#import "DAOFactory.h"
//#import "FZUserDAO.h"
////#import "EventsDAO.h"
//
//#import "SessionInstance.h"
//
//
//NSString *const USER_PROFILE_USER_ID = @"Forkize.UserProfile.userId";
//
//NSString *const FORKIZE_USER_ID = @"user_id";
//
//// ** operations
//NSString *const FORKIZE_INCREMENT = @"increment";
//NSString *const FORKIZE_SET = @"set";
//NSString *const FORKIZE_UNSET = @"unset";
//NSString *const FORKIZE_APPEND = @"append";
//NSString *const FORKIZE_PREPEND = @"prepend";
//
//typedef enum{
//    FZ_USER_UNSPECIFIED = 0,
//    FZ_USER_MALE = 1,
//    FZ_USER_FEMALE = 2
//} UserGender;
//
//
@interface UserProfile()

@property (nonatomic, strong) UserProfileInternal *internal;


//@property (nonatomic, strong) NSString *userId;
//@property (nonatomic, strong) NSString *aliasedUserId;
//
//
//@property (nonatomic, strong) NSMutableDictionary *userInfo;
//@property (nonatomic, strong) NSMutableDictionary *changeLog;
//
//
//@property (nonatomic, assign) UserGender gender;
//@property (nonatomic, assign) NSInteger age;
//
//@property (nonatomic, strong) LocalStorageManager *localStorage;
//
//@property (nonatomic, strong) FZUserDAO *userDAO;




@end

@implementation UserProfile


-(instancetype) init{
    self = [super init];
    if (self) {
        
        self.internal = [UserProfileInternal getInstance];
    }
    
    return self;
}

+ (UserProfile*) getInstance {
    static UserProfile *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UserProfile alloc] init];
    });
    return sharedInstance;
}

-(NSString*) getUserId{
    return [self.internal getUserId];
}

-(NSString *) getAliasedUserId{
    return [self.internal getAliasedUserId];
}

-(id) objectForKey:(NSString *) key{
    return [self.internal objectForKey:key];
}

-(void) identify:(NSString *) userId{
    [self.internal identify:userId];
}

-(void) alias:(NSString*) userId{
    [self.internal alias:userId];
}

-(void) setValue:(id)value forKey:(NSString *)key{
    [self.internal setValue:value forKey:key];
 }

-(void) setOnceValue:(id)value forKey:(NSString *)key{
    [self.internal setOnceValue:value forKey:key];
}

-(void) setBatch:(NSDictionary *) dict{
    [self.internal setBatch:dict];
}

-(void) unsetForKey:(NSString *)key{
    [self.internal unsetForKey:key];
}

-(void) unsetBatch:(NSArray *) array{
    [self.internal unsetBatch:array];
}

-(void) incrementValue:(NSString *)value  forKey:(NSString*) key {
    [self.internal incrementValue:value forKey:key];
}

-(void) incrementBatch:(NSDictionary *)dict{
    [self.internal incrementBatch:dict];
}

-(void) appendForKey:(NSString*) key andValue:(id) value{
    [self.internal appendForKey:key andValue:value];
}

-(void) prependForKey:(NSString*) key andValue:(id) value{
    [self.internal prependForKey:key andValue:value];
}


-(void) setAge:(NSInteger ) age{
    [self.internal setAge:age];
}

-(NSInteger) getAge{
    return [self.internal getAge];
}

-(void) setMale:(BOOL) male{
    [self.internal setMale:male];
}

-(void) setFemale:(BOOL) female{
    [self.internal setFemale:female];
}

-(NSString*) getGender{
    return [self.internal getGender];
}

-(NSString *) getChangeLog {
    return [self.internal getChangeLog];
}

- (void) start{
    [self.internal start];
}

- (void) end{
    [self.internal end];
}

- (void) pause{
    [self.internal pause];
}

- (void) resume{
    [self.internal resume];
}

@end
