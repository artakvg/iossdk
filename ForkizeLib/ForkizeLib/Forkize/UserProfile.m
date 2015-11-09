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
#import "FZUser.h"


NSString *const USER_PROFILE_USER_ID = @"Forkize.UserProfile.userId";
NSString *const FORKIZE_INSTALL_TIME = @"Forkize.Install.Time";


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


@interface UserProfile()

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *aliasedUserId;

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
        // FZ::TODO why we are logging and not throwing exception ?
        NSLog(@"Forkize SDK New user Id is nill or empty");
        return;
    }
    
    if ([oldUserId isEqual:newUserId]) {
        NSLog(@"Forkize SDK Current and alias user ids are same!");
        return;
    }
    
    // NSAssert([oldUserId isEqualToString:self.userId], @"Old UserId mismatch with oldUserId in alias function");
    
    // FZ::TODO should local storage be aware of such kind of functionality like alias ????
    [self.localStorage aliasWithOldUserId:oldUserId andNewUserId:newUserId];
    self.aliasedLevel = 1;
    self.aliasedUserId = newUserId;
    
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
     // FZ::TODO why we are not removing prev inc and prepend operations ???
    if ([ForkizeHelper isKeyValid:key]) {
        NSMutableDictionary *setDict = [NSMutableDictionary dictionaryWithDictionary:[self.changeLog objectForKey:FORKIZE_SET]];
        
        [setDict setValue:value forKey:key];
        
        [self.changeLog setValue:setDict forKey:FORKIZE_SET];
        
        
        NSMutableArray *unsetArray = [NSMutableArray arrayWithArray:[self.changeLog objectForKey:FORKIZE_UNSET]];
        [unsetArray removeObject:key];
        [self.changeLog setValue:unsetArray forKey:FORKIZE_UNSET];
        
        [self.userInfo setValue:value forKey:key];
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

-(void) identify:(NSString *) userId{
    self.aliasedLevel = 0;
    NSString *oldId = self.userId;
    
    NSString *tmpUserId = (userId != nil ? userId : [self generateUserId]);
    
    [[NSUserDefaults  standardUserDefaults] setObject:tmpUserId forKey:USER_PROFILE_USER_ID];
    
    self.userId = tmpUserId;
    
    [[RestClient getInstance] dropAccessToken];
    
    if (self.localStorage != nil) {
        [self.localStorage flushToDatabase];
        [self.localStorage changeUserId];
        
        if (![ForkizeHelper isNilOrEmpty:oldId]) {
            
            FZUser *user = [[FZUser alloc] init];
            user.userName = oldId;
            user.changeLog = [self getChangeLog];
            // FZ::TODO why user id and not olduser id
            [self.userInfo setObject:self.aliasedUserId forKey:@"aliasedUserId"];
            user.userInfo = [self getJsonString:self.userInfo];
            [self.localStorage setUser:user];
            
            
            @try {
                FZUser *user = [self.localStorage getUser:self.userId];

                if (![ForkizeHelper isNilOrEmpty:user.changeLog]) {
                    self.changeLog = [NSMutableDictionary dictionaryWithDictionary:[self parseJsonString:user.changeLog]];
                } else {
                    self.changeLog = [NSMutableDictionary dictionary];
                }
                
                if (![ForkizeHelper isNilOrEmpty:user.userInfo]) {
                    self.userInfo = [NSMutableDictionary dictionaryWithDictionary:[self parseJsonString:user.userInfo]];
                    self.aliasedUserId = [self.userInfo objectForKey:@"aliasedUserId"];
                } else {
                    self.userInfo = [NSMutableDictionary dictionary];
                }
                
            }
            @catch (NSException *exception) {
                NSLog(@"Forkize SDK User change log is not converted to JSONObject");
            }
        }
    }
}

// ** FZ::TODO this could be moved to Forkize helper
-(NSDictionary *) parseJsonString:(NSString *) jsonString{
    NSError * err;
    NSData *data =[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * dict;
    if(data!=nil){
        dict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    }
    
    return dict;
}

// ** FZ::TODO this could be moved to Forkize helper
-(NSString *) getJsonString:(NSDictionary *) dict{
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:dict options:0 error:&err];
    NSString * jsonString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    return  jsonString;
}

-(NSString *) getChangeLog {
  return  [self getJsonString:self.changeLog];
}

-(void) dropChangeLog {
    self.changeLog = [NSMutableDictionary dictionary];
}

-(void) printChangeLog {
    NSLog(@"Forkize SDK %@", [self getChangeLog]);
}

// FZ::TODO dont think we need to have such high level interface, error prone
-(void) flushToDatabase{
    if (self.localStorage != nil) {
        FZUser *user = [[FZUser alloc] init];
        user.userName = self.userId;
        user.changeLog = [self getChangeLog];
        user.userInfo = [self getJsonString:self.userInfo];
        [self.userInfo setObject:self.aliasedUserId forKey:@"aliasedUserId"];
        [self.localStorage setUser:user];
    }
}

-(void) restoreFromDatabase{
    if (self.localStorage != nil) {
        self.userId = [self getUserId];
        
        FZUser *user = [self.localStorage getUser:self.userId];
        self.userInfo = [NSMutableDictionary dictionaryWithDictionary:[self parseJsonString:user.userInfo]];
        self.changeLog = [NSMutableDictionary dictionaryWithDictionary:[self parseJsonString:user.changeLog]];
        self.aliasedUserId = [self.userInfo objectForKey:@"aliasedUserId"];
        
        [self.localStorage setUser:user];
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


-(id) getChangeLogJSON{
    
    NSMutableDictionary * changeLogJSONDict = [NSMutableDictionary dictionary];
    
    NSDictionary *incrementDict = [self.changeLog objectForKey:FORKIZE_INCREMENT];
    if (incrementDict != nil && [incrementDict count]) {
        id incrementJSON = [self getJSON:incrementDict];
        [changeLogJSONDict setObject:incrementJSON forKey:FORKIZE_INCREMENT];
    }
    
    NSDictionary *setDict = [self.changeLog objectForKey:FORKIZE_SET];
    if (setDict != nil && [setDict count]) {
        id setJSON = [self getJSON:setDict];
        [changeLogJSONDict setObject:setJSON forKey:FORKIZE_SET];
    }
    
    NSArray *unsetArray = [self.changeLog objectForKey:FORKIZE_UNSET];
    if (unsetArray != nil && [unsetArray count]) {
        id unsetJSON = [self getJSON:unsetArray];
        [changeLogJSONDict setObject:unsetJSON forKey:FORKIZE_UNSET];
    }
    
    NSDictionary *appendDict = [self.changeLog objectForKey:FORKIZE_APPEND];
    if (appendDict != nil && [appendDict count]) {
        NSMutableDictionary *appendJSONDict = [NSMutableDictionary dictionary];
        
        for (NSString *key in [appendDict allKeys]) {
            NSArray *keyValuesArray = [appendDict objectForKey:key];
            id keyValuesJSON = [self getJSON:keyValuesArray];
            [appendJSONDict setObject:keyValuesJSON forKey:key];
        }
        
        
        
        id appendJSON = [self getJSON:appendJSONDict];
        [changeLogJSONDict setObject:appendJSON forKey:FORKIZE_APPEND];
    }

    NSDictionary *prependDict = [self.changeLog objectForKey:FORKIZE_PREPEND];
    if (prependDict != nil && [prependDict count]) {
        NSMutableDictionary *prependJSONDict = [NSMutableDictionary dictionary];
        
        for (NSString *key in [prependDict allKeys]) {
            NSArray *keyValuesArray = [prependDict objectForKey:key];
            id keyValuesJSON = [self getJSON:keyValuesArray];
            [prependJSONDict setObject:keyValuesJSON forKey:key];
        }
        
        
        
        id prependJSON = [self getJSON:prependJSONDict];
        [changeLogJSONDict setObject:prependJSON forKey:FORKIZE_PREPEND];
    }

    id changeLogJSON = [self getJSON:changeLogJSONDict];
    
    return changeLogJSON;
}

// FZ::TODO why we need it here  NSJSONWritingPrettyPrinted
-(id) getJSON:(id) container{
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:container options:NSJSONWritingPrettyPrinted error:&error];
    
    NSError *parseError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&parseError];

    return jsonObject;
}

@end
