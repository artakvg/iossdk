//
//  UserProfileInternal.m
//  ForkizeLib
//
//  Created by Artak Martirosyan on 11/29/15.
//  Copyright © 2015 Artak. All rights reserved.
//

#import "UserProfileInternal.h"
#import "ForkizeHelper.h"
#import "LocalStorageManager.h"
#import "ForkizeConfig.h"
#import "RestClient.h"

#import "FZUser.h"
//#import "FZEvent.h"

#import "DAOFactory.h"
#import "FZUserDAO.h"
//#import "EventsDAO.h"

#import "SessionInstance.h"


NSString *const USER_PROFILE_USER_ID = @"Forkize.UserProfile.userId";

NSString *const FORKIZE_USER_ID = @"user_id";

// ** operations
NSString *const FORKIZE_INCREMENT = @"increment";
NSString *const FORKIZE_SET = @"set";
NSString *const FORKIZE_UNSET = @"unset";
NSString *const FORKIZE_APPEND = @"append";
NSString *const FORKIZE_PREPEND = @"prepend";

typedef enum{
    FZ_USER_UNSPECIFIED = 0,
    FZ_USER_MALE = 1,
    FZ_USER_FEMALE = 2
} UserGender;


@interface UserProfileInternal()

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *aliasedUserId;


@property (nonatomic, strong) NSMutableDictionary *userInfo;
@property (nonatomic, strong) NSMutableDictionary *changeLog;


@property (nonatomic, assign) UserGender gender;
@property (nonatomic, assign) NSInteger age;

@property (nonatomic, strong) LocalStorageManager *localStorage;

@property (nonatomic, strong) FZUserDAO *userDAO;




@end

@implementation UserProfileInternal


-(instancetype) init{
    self = [super init];
    if (self) {
        self.gender = FZ_USER_UNSPECIFIED;
        self.userInfo = [NSMutableDictionary dictionary];
        self.changeLog = [NSMutableDictionary dictionary];
        self.localStorage = [LocalStorageManager getInstance];
        self.userDAO = [[DAOFactory defaultFactory] userDAO];
        
        [[NSNotificationCenter defaultCenter] addObserver:@"KUKU" selector:@selector(postListen:) name:@"KUKU" object:nil];
    }
    
    return self;
}

-(void) postListen:(NSNotification *) notifiatication{
    NSLog(@"test listen ");
    
}

+ (UserProfileInternal*) getInstance {
    static UserProfileInternal *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UserProfileInternal alloc] init];
    });
    return sharedInstance;
}

-(NSString*) getUserId{
    if ([ForkizeHelper isNilOrEmpty:self.userId]) {
        NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:USER_PROFILE_USER_ID];
        NSLog(@"From default userId %@", userId);
        if ([ForkizeHelper isNilOrEmpty:userId]) {
            [self identify:nil];
        } else {
            self.userId = userId;
        }
    }
    
    return self.userId;
}

-(NSString *) getAliasedUserId{
    return self.aliasedUserId;
}

-(id) objectForKey:(NSString *) key{
    return [self.userInfo objectForKey:key];
}

-(NSString *) generateUserId{
    NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:USER_PROFILE_USER_ID];
    
    if (userId != nil) {
        return userId;
    }
    
    NSString *UUID = [NSUUID UUID].UUIDString;
    return UUID;
}

-(void) identify:(NSString *) userId{
    NSString *oldId = self.userId;
    NSString *oldAliasedId = self.aliasedUserId;
    
    if (userId == nil) {
        userId = [self generateUserId];
    }
    
    [[NSUserDefaults  standardUserDefaults] setObject:userId forKey:USER_PROFILE_USER_ID];
    
    self.userId = userId;
    self.aliasedUserId = @"";
    
    [[RestClient getInstance] dropAccessToken];
    
    if (self.localStorage != nil) {
        [self.localStorage flushToDatabase];
        
        FZUser *user = [self.userDAO getUser:self.userId];
        
        if (user == nil) {
            user = [self.userDAO addUser:self.userId];
        }
        
        if (![ForkizeHelper isNilOrEmpty:oldId]) {
            // FZ::DONE why user id and not olduser id
            
            FZUser *user = [[FZUser alloc] init];
            user.userName = oldId;
            user.changeLog = [self getChangeLog];
            [self.userInfo setObject:oldAliasedId forKey:@"aliasedUserId"];
            user.userInfo = [ForkizeHelper getJsonString:self.userInfo];
            [self.userDAO updateUser:user];
        }
        
        @try {
            FZUser *user = [self.userDAO getUser:self.userId];
            
            if (![ForkizeHelper isNilOrEmpty:user.changeLog]) {
                self.changeLog = [NSMutableDictionary dictionaryWithDictionary:[ForkizeHelper parseJsonString:user.changeLog]];
            } else {
                self.changeLog = [NSMutableDictionary dictionary];
            }
            
            if (![ForkizeHelper isNilOrEmpty:user.userInfo]) {
                self.userInfo = [NSMutableDictionary dictionaryWithDictionary:[ForkizeHelper parseJsonString:user.userInfo]];
            } else {
                self.userInfo = [NSMutableDictionary dictionary];
            }
            self.aliasedUserId = [self.userInfo objectForKey:@"aliasedUserId"];
            
            
        }
        @catch (NSException *exception) {
            NSLog(@"Forkize SDK User change log is not converted to JSONObject");
        }
    }
}

-(void) alias:(NSString*) userId{
    //-(void) aliasWithOldUserId:(NSString*) oldUserId andNewUserId:(NSString*) newUserId{
    
    NSString *oldUserId = [self getUserId];
    
    if ([ForkizeHelper isNilOrEmpty:userId]) {
        // FZ::TODO why we are logging and not throwing exception ?
        @throw [NSException  exceptionWithName:@"Forkize" reason:@"Forkize SDK New user Id is nill or empty" userInfo:nil];
        return;
    }
    
    if ([oldUserId isEqual:userId]) {
        NSLog(@"Forkize SDK Current and alias user ids are same!");
        return;
    }
    
    // NSAssert([oldUserId isEqualToString:self.userId], @"Old UserId mismatch with oldUserId in alias function");
    
    // FZ::TODO should local storage be aware of such kind of functionality like alias ????
    
    //  gnum gtnum enq oldUserName-ov tox@ u aliased dashtum grum enq newUserName
    self.aliasedUserId = userId;
    
    FZUser *user = [self.userDAO getUser:oldUserId];
    user.aliasedName = userId;
    [self.userDAO updateUser:user];
    
    NSLog(@"Forkize SDK userId will change");
}

-(void) applyAlias{
    if (self.aliasedUserId != nil && [self.aliasedUserId length] > 0) {
        NSString *userName = [[UserProfileInternal getInstance] getUserId];

        self.userId =  self.aliasedUserId;

        FZUser *user = [self.userDAO getUser:userName];
        user.userName = user.aliasedName;
        user.aliasedName = @"";
        [self.userDAO updateUser:user];
    }
}

//-(void) exchangeIds{
//
//    NSString *userName = [[UserProfile getInstance] getUserId];
//
//    FZUser *user = [self.userDAO getUser:userName];
//
//    EventsDAO *eventsDAO = [[DAOFactory defaultFactory] eventsDAO];
//    NSArray *events = [eventsDAO loadEventsForUser:user.userName];
//    for (FZEvent *event in events) {
//        event.userName = user.aliasedName;
//    }
//
//    [eventsDAO updateEvents:events];
//
//    user.userName = user.aliasedName;
//    user.aliasedName = @"";
//    [self.userDAO updateUser:user];
//
//    [[UserProfile getInstance] identify:user.userName];
//}

//-(void) updateProfile:(NSDictionary *) dict{
//    NSArray *keys = [dict allKeys];
//
//    for (NSString *key in keys) {
//        [self setValue:[dict objectForKey:key]  forKey:key];
//    }
//}
//
//-(void) setProfile:(NSDictionary *) dict{
//    self.userInfo = [NSMutableDictionary dictionary];
//
//    [self updateProfile:dict];
//}

-(void) setValue:(id)value forKey:(NSString *)key{
    // FZ::TODO why we are not removing prev inc and prepend operations ???
    if ([ForkizeHelper isKeyValid:key]) {
        NSMutableDictionary *setDict = [NSMutableDictionary dictionaryWithDictionary:[self.changeLog objectForKey:FORKIZE_SET]];
        
        [setDict setValue:value forKey:key];
        
        [self.changeLog setValue:setDict forKey:FORKIZE_SET];
        
        
        NSMutableArray *unsetArray = [NSMutableArray arrayWithArray:[self.changeLog objectForKey:FORKIZE_UNSET]];
        [unsetArray removeObject:key];
        [self.changeLog setValue:unsetArray forKey:FORKIZE_UNSET];
        
        NSMutableDictionary *incrementDict = [NSMutableDictionary dictionaryWithDictionary:[self.changeLog objectForKey:FORKIZE_INCREMENT] ];
        [incrementDict removeObjectForKey:key];
        [self.changeLog setValue:incrementDict forKey:FORKIZE_INCREMENT];
        
        NSMutableDictionary *appendDictonary = [NSMutableDictionary dictionaryWithDictionary:[self.changeLog objectForKey:FORKIZE_APPEND]];
        [appendDictonary removeObjectForKey:key];
        [self.changeLog setValue:appendDictonary forKey:FORKIZE_APPEND];
        
        
        NSMutableDictionary *prependDictonary = [NSMutableDictionary dictionaryWithDictionary:[self.changeLog objectForKey:FORKIZE_PREPEND]];
        [prependDictonary removeObjectForKey:key];
        [self.changeLog setValue:prependDictonary forKey:FORKIZE_PREPEND];
        
        [self.userInfo setValue:value forKey:key];
    }
}

-(void) setOnceValue:(id)value forKey:(NSString *)key{
    if ([ForkizeHelper isKeyValid:key]) {
        if (![self.userInfo objectForKey:key]) {
            [self setValue:value forKey:key];
        }
    }
}

-(void) setBatch:(NSDictionary *) dict{
    for (NSString *key in [dict allKeys]){
        [self setValue:[dict objectForKey:key] forKey:key];
    }
}


-(void) unsetForKey:(NSString *)key{
    // FZ::TODO why we are not removing prev inc and prepend operations ???
    if ([ForkizeHelper isKeyValid:key]) {
        NSArray *unsetArray = [self.changeLog objectForKey:FORKIZE_UNSET];
        NSMutableArray *unsetMutArray = [NSMutableArray array];
        
        if (unsetArray && [unsetArray count]) {
            [unsetMutArray addObjectsFromArray:unsetArray];
        }
        
        [unsetMutArray addObject:key];
        
        [self.changeLog setValue:unsetMutArray forKey:FORKIZE_UNSET];
        
        NSMutableDictionary *setDict = [NSMutableDictionary dictionaryWithDictionary:[self.changeLog objectForKey:FORKIZE_SET]];
        [setDict removeObjectForKey:key];
        [self.changeLog setValue:setDict forKey:FORKIZE_SET];
        
        NSMutableDictionary *incrementDict = [NSMutableDictionary dictionaryWithDictionary:[self.changeLog objectForKey:FORKIZE_INCREMENT] ];
        [incrementDict removeObjectForKey:key];
        [self.changeLog setValue:incrementDict forKey:FORKIZE_INCREMENT];
        
        NSMutableDictionary *appendDictonary = [NSMutableDictionary dictionaryWithDictionary:[self.changeLog objectForKey:FORKIZE_APPEND]];
        [appendDictonary removeObjectForKey:key];
        [self.changeLog setValue:appendDictonary forKey:FORKIZE_APPEND];
        
        
        NSMutableDictionary *prependDictonary = [NSMutableDictionary dictionaryWithDictionary:[self.changeLog objectForKey:FORKIZE_PREPEND]];
        [prependDictonary removeObjectForKey:key];
        [self.changeLog setValue:prependDictonary forKey:FORKIZE_PREPEND];
        
        [self.userInfo removeObjectForKey:key];
    }
}

-(void) unsetBatch:(NSArray *) array{
    for (NSString *key in array) {
        [self unsetForKey:key];
    }
}


-(void) incrementValue:(NSString *)value  forKey:(NSString*) key {
    if ([ForkizeHelper isKeyValid:key]) {
        NSMutableDictionary *incrementDict = [NSMutableDictionary dictionaryWithDictionary:[self.changeLog objectForKey:FORKIZE_INCREMENT] ];
        
        NSString * keyValue = [incrementDict objectForKey:key];
        
        if (keyValue == nil) {
            keyValue = @"0";
        }
        
        [incrementDict setValue:[NSString stringWithFormat:@"%f", [keyValue doubleValue] + [value doubleValue]] forKey:key];
        
        [self.changeLog setValue:incrementDict forKey:FORKIZE_INCREMENT];
        
        
        double d = [[self.userInfo valueForKey:key] doubleValue];
        d += [value doubleValue];
        
        [self.userInfo setObject:[NSString stringWithFormat:@"%f", d] forKey:key];
    }
}

-(void) incrementBatch:(NSDictionary *)dict{
    NSArray *allKeys = [dict allKeys];
    
    for (NSString *key in allKeys){
        if ([ForkizeHelper isKeyValid:key]) {
            [self incrementValue:[dict objectForKey:key] forKey:key];
        }
    }
}

-(void) appendForKey:(NSString*) key andValue:(id) value{
    if ([ForkizeHelper isKeyValid:key]) {
        NSDictionary *appendDictonary = [self.changeLog objectForKey:FORKIZE_APPEND];
        
        NSArray *keyArray = [appendDictonary objectForKey:key];
        
        if (keyArray == nil) {
            keyArray = [NSArray array];
        }
        
        NSMutableArray *keyMutableArray = [NSMutableArray arrayWithArray:keyArray];
        [keyMutableArray addObject:value];
        
        [appendDictonary setValue:keyMutableArray forKey:key];
        
        [self.changeLog setValue:appendDictonary forKey:FORKIZE_APPEND];
        
        NSArray* valueFromDict = [self.userInfo valueForKey:key];
        if (![valueFromDict isKindOfClass:[NSArray class]]) {
            valueFromDict = [NSArray array];
        }
        
        NSMutableArray *mutArray = [NSMutableArray arrayWithArray:valueFromDict];
        [mutArray addObject:value];
        [self.userInfo setValue:mutArray forKey:key];
    }
}

-(void) prependForKey:(NSString*) key andValue:(id) value{
    if ([ForkizeHelper isKeyValid:key]) {
        NSDictionary *prependDictonary = [self.changeLog objectForKey:FORKIZE_PREPEND];
        
        NSArray *keyArray = [prependDictonary objectForKey:key];
        
        if (keyArray == nil) {
            keyArray = [NSArray array];
        }
        
        NSMutableArray *keyMutableArray = [NSMutableArray arrayWithArray:keyArray];
        [keyMutableArray insertObject:value atIndex:0];
        
        [prependDictonary setValue:keyMutableArray forKey:key];
        
        [self.changeLog setValue:prependDictonary forKey:FORKIZE_PREPEND];
        
        NSArray* valueFromDict = [self.userInfo valueForKey:key];
        if (![valueFromDict isKindOfClass:[NSArray class]]) {
            valueFromDict = [NSArray array];
        }
        
        NSMutableArray *mutArray = [NSMutableArray arrayWithObject:value];
        [mutArray addObjectsFromArray:valueFromDict];
        [self.userInfo setValue:mutArray forKey:key];
    }
}


-(void) setAge:(NSInteger ) age{
    if (age > 0 && age < 100) {
        self.age = age;
        [self setValue:[NSString stringWithFormat:@"%ld", (long) age] forKey:@"age"];
    } else {
        NSLog(@"Forkize SDK Entered wrong value for age");
    }
}

-(NSInteger) getAge{
    return self.age;
}

-(void) setMale:(BOOL) male{
    if (male) {
        self.gender = FZ_USER_MALE;
        [self setValue:@"male" forKey:@"$gender"];
    }
}

-(void) setFemale:(BOOL) female{
    if (female) {
        self.gender = FZ_USER_FEMALE;
        [self setValue:@"female" forKey:@"$gender"];
    }
}

-(NSString*) getGender{
    if (self.gender == FZ_USER_MALE)
        return @"male";
    if (self.gender == FZ_USER_FEMALE)
        return @"female";
    return nil;
}


-(BOOL) isChangeLogEmpty{
    return ([self.changeLog count] == 0);
}

-(NSString *) getChangeLog {
    return  [ForkizeHelper getJsonString:self.changeLog];
}

-(void) dropChangeLog {
    self.changeLog = [NSMutableDictionary dictionary];
}


- (void) start{
    [[SessionInstance getInstance] start];
    [self restoreFromDatabase];
}

- (void) end{
    [[SessionInstance getInstance] end];
    [self flushToDatabase];
}

- (void) pause{
    [[SessionInstance getInstance] pause];
    [self flushToDatabase];
    
}

- (void) resume{
    [[SessionInstance getInstance] resume];
    [self restoreFromDatabase];
}


// FZ::TODO dont think we need to have such high level interface, error prone
-(void) flushToDatabase{
    if (self.localStorage != nil) {
        FZUser *user = [[FZUser alloc] init];
        user.userName = self.userId;
        user.changeLog = [self getChangeLog];
        user.userInfo = [ForkizeHelper getJsonString:self.userInfo];
        [self.userInfo setObject:self.aliasedUserId forKey:@"aliasedUserId"];
        [self.userDAO updateUser:user];
    }
}

-(void) restoreFromDatabase{
    if (self.localStorage != nil) {
        self.userId = [self getUserId];
        
        FZUser *user = [self.userDAO getUser:self.userId];
        
        if (![ForkizeHelper isNilOrEmpty:user.changeLog]) {
            self.changeLog = [NSMutableDictionary dictionaryWithDictionary:[ForkizeHelper parseJsonString:user.changeLog]];
        } else {
            self.changeLog = [NSMutableDictionary dictionary];
        }
        
        if (![ForkizeHelper isNilOrEmpty:user.userInfo]) {
            self.userInfo = [NSMutableDictionary dictionaryWithDictionary:[ForkizeHelper parseJsonString:user.userInfo]];
        } else {
            self.userInfo = [NSMutableDictionary dictionary];
        }
        self.aliasedUserId = [self.userInfo objectForKey:@"aliasedUserId"];
        
        [self.userDAO updateUser:user];
    }
    
}

-(id) getChangeLogJSON{
    
    NSMutableDictionary * changeLogJSONDict = [NSMutableDictionary dictionary];
    
    NSDictionary *incrementDict = [self.changeLog objectForKey:FORKIZE_INCREMENT];
    if (incrementDict != nil && [incrementDict count]) {
        id incrementJSON = [ForkizeHelper getJSON:incrementDict];
        [changeLogJSONDict setObject:incrementJSON forKey:FORKIZE_INCREMENT];
    }
    
    NSDictionary *setDict = [self.changeLog objectForKey:FORKIZE_SET];
    if (setDict != nil && [setDict count]) {
        id setJSON = [ForkizeHelper getJSON:setDict];
        [changeLogJSONDict setObject:setJSON forKey:FORKIZE_SET];
    }
    
    NSArray *unsetArray = [self.changeLog objectForKey:FORKIZE_UNSET];
    if (unsetArray != nil && [unsetArray count]) {
        id unsetJSON = [ForkizeHelper getJSON:unsetArray];
        [changeLogJSONDict setObject:unsetJSON forKey:FORKIZE_UNSET];
    }
    
    NSDictionary *appendDict = [self.changeLog objectForKey:FORKIZE_APPEND];
    if (appendDict != nil && [appendDict count]) {
        NSMutableDictionary *appendJSONDict = [NSMutableDictionary dictionary];
        
        for (NSString *key in [appendDict allKeys]) {
            NSArray *keyValuesArray = [appendDict objectForKey:key];
            id keyValuesJSON = [ForkizeHelper getJSON:keyValuesArray];
            [appendJSONDict setObject:keyValuesJSON forKey:key];
        }
        
        id appendJSON = [ForkizeHelper getJSON:appendJSONDict];
        [changeLogJSONDict setObject:appendJSON forKey:FORKIZE_APPEND];
    }
    
    NSDictionary *prependDict = [self.changeLog objectForKey:FORKIZE_PREPEND];
    if (prependDict != nil && [prependDict count]) {
        NSMutableDictionary *prependJSONDict = [NSMutableDictionary dictionary];
        
        for (NSString *key in [prependDict allKeys]) {
            NSArray *keyValuesArray = [prependDict objectForKey:key];
            id keyValuesJSON = [ForkizeHelper getJSON:keyValuesArray];
            [prependJSONDict setObject:keyValuesJSON forKey:key];
        }
        
        id prependJSON = [ForkizeHelper getJSON:prependJSONDict];
        [changeLogJSONDict setObject:prependJSON forKey:FORKIZE_PREPEND];
    }
    
    id changeLogJSON = [ForkizeHelper getJSON:changeLogJSONDict];
    
    return changeLogJSON;
}

@end
