//
//  UserProfile.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "UserProfile.h"
#import "ForkizeEventManager.h"
#import "ForkizeHelper.h"
#import <Foundation/Foundation.h>
#import "LocalStorageManager.h"
#import "ForkizeConfig.h"
#import "RestClient.h"


NSString *const USER_PROFILE_USER_ID = @"Forkize.UserProfile.userId";
NSString *const FORKIZE_INSTALL_TIME = @"Forkize.Install.Time";


NSString *const FORKIZE_USER_ID = @"user_id";
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


@interface UserProfile()

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) UserGender gender;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) NSMutableDictionary *userInfo;
@property (nonatomic, strong) NSMutableDictionary *changeLog;


@property (nonatomic, strong) LocalStorageManager *localStorage;



@end

@implementation UserProfile


-(instancetype) init{
    self = [super init];
    if (self) {
        self.gender = FZ_USER_UNSPECIFIED;
        self.userInfo = [NSMutableDictionary dictionary];
        self.changeLog = [NSMutableDictionary dictionary];
        self.localStorage = [LocalStorageManager getInstance];
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

-(void) aliasWithOldUserId:(NSString*) oldUserId andNewUserId:(NSString*) newUserId{
    
    if ([ForkizeHelper isNilOrEmpty:newUserId]) {
        NSLog(@"Forkize SDK New user Id is nill or empty");
        return;
    }
    
    if ([oldUserId isEqual:newUserId]) {
        NSLog(@"Forkize SDK Current and alias user ids are same!");
        return;
    }
    
    [self.localStorage aliasWithOldUserId:oldUserId andNewUserId:newUserId];
    self.aliasedLevel = 1;
    NSLog(@"Forkize SDK userId will change");
}

-(void) updateProfile:(NSDictionary *) dict{
    NSArray *keys = [dict allKeys];
    
    for (NSString *key in keys) {
        [self setValue:[dict objectForKey:key]  forKey:key];
    }
}

-(void) setProfile:(NSDictionary *) dict{
    self.userInfo = [NSMutableDictionary dictionary];
    
    [self updateProfile:dict];
}

-(void) setValue:(id)value forKey:(NSString *)key{
    if ([ForkizeHelper isKeyValid:key]) {
        NSMutableDictionary *setDict = [NSMutableDictionary dictionaryWithDictionary:[self.changeLog objectForKey:FORKIZE_SET]];
        
        [setDict setValue:value forKey:key];
        
        [self.changeLog setValue:setDict forKey:FORKIZE_SET];
        
        [self.userInfo setValue:value forKey:key];
    }
 }

-(void) unsetForKey:(NSString *)key{
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

        [self.userInfo removeObjectForKey:key];
    }
}


-(void) incrementValueForKey:(NSString*) key byValue:(NSString *) value {
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

-(void) incrementByDictonary:(NSDictionary *)dict{
    NSArray *allKeys = [dict allKeys];
    
    for (NSString *key in allKeys){
        if ([ForkizeHelper isKeyValid:key]) {
            [self incrementValueForKey:key byValue:[dict objectForKey:key]];
        }
    }
}

-(void) appendForKey:(NSString*) key andValue:(id) value{
    if ([ForkizeHelper isKeyValid:key]) {
        
        NSArray *appendArray = [self.changeLog objectForKey:FORKIZE_APPEND];
        NSMutableArray *appendMutArray = [NSMutableArray array];
        
        if (appendArray && [appendArray count]) {
            [appendMutArray addObjectsFromArray:appendArray];
        }
        
        [appendMutArray addObject:key];
        [appendMutArray addObject:value];
        
        [self.changeLog setValue:appendMutArray forKey:FORKIZE_APPEND];
        
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
        
        NSArray *prependArray = [self.changeLog objectForKey:FORKIZE_PREPEND];
        NSMutableArray *prependMutArray = [NSMutableArray array];
        
        if (prependArray && [prependArray count]) {
            [prependMutArray addObjectsFromArray:prependArray];
        }
        
        [prependMutArray addObject:key];
        [prependMutArray addObject:value];
        
        [self.changeLog setValue:prependMutArray forKey:FORKIZE_PREPEND];
        
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
    if (age> 0 && age < 150) {
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

-(void) identify:(NSString *) userId{
    self.aliasedLevel = 0;
    NSString *oldId = self.userId;
    
    NSString *tmpUserId = (userId == nil ? [self generateUserId] : userId);
    
    [[NSUserDefaults  standardUserDefaults] setObject:tmpUserId forKey:USER_PROFILE_USER_ID];
    
    self.userId = tmpUserId;
    
    [[RestClient getInstance] dropAccessToken];
    
    if (self.localStorage != nil) {
        [self.localStorage flushToDatabase];
        [self.localStorage changeUserId];
        
        if (![ForkizeHelper isNilOrEmpty:oldId]) {
            NSString *changeLogString = [self getChangeLog];
            [self.localStorage setUserInfo:self.userId andChangeLog:changeLogString];
            @try {
                NSString *jsonString = [self.localStorage getUserInfo:self.userId];
                if (![ForkizeHelper isNilOrEmpty:jsonString]) {
                    self.changeLog = [NSMutableDictionary dictionaryWithDictionary:[self parseJsonString:jsonString]];
                } else {
                    self.changeLog = [NSMutableDictionary dictionary];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"Forkize SDK User change log is not converted to JSONObject");
            }
        }
    }
}

-(NSDictionary *) parseJsonString:(NSString *) jsonString{
    NSError * err;
    NSData *data =[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * dict;
    if(data!=nil){
        dict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    }
    
    return dict;
}


-(NSString *) getChangeLog {
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:self.changeLog options:0 error:&err];
    NSString * jsonString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];

    return  jsonString;
}

-(void) dropChangeLog {
    self.changeLog = [NSMutableDictionary dictionary];
}

-(void) printChangeLog {
    NSLog(@"Forkize SDK %@", [self getChangeLog]);
}

-(void) flushToDatabase{
    if (self.localStorage != nil) {
        [self.localStorage setUserInfo:self.userId andChangeLog:[self getChangeLog]];
    }
}


-(NSString *) generateUserId{
    NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:USER_PROFILE_USER_ID];
    
    if (userId != nil) {
        return userId;
    }
    
    NSString *UUID = [NSUUID UUID].UUIDString;
    return UUID;
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

-(NSDictionary *) getUserInfo {
    if (self.userInfo == nil) {
        self.userInfo = [NSMutableDictionary dictionary];
        
        if (self.age > 0 && self.age < 150)
            [self.userInfo setObject:[NSString stringWithFormat:@"%ld", (long)self.age] forKey:@"age"];
        
        NSString *gender = [self getGender];
        if (gender != nil) {
            [self.userInfo setObject:gender forKey:@"gender"];
        }
        
        [self.userInfo setObject:[self getUserId] forKey:USER_PROFILE_USER_ID];
    }
    return self.userInfo;
}


-(BOOL) isNewInstall{

    NSString *installTime = [[NSUserDefaults standardUserDefaults] valueForKey:FORKIZE_INSTALL_TIME];
  
    if ([ForkizeHelper isNilOrEmpty:installTime]) {
        installTime = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
        [[NSUserDefaults  standardUserDefaults] setObject:installTime forKey:FORKIZE_INSTALL_TIME];
        return YES;
    }
        
    return NO;
}

@end
