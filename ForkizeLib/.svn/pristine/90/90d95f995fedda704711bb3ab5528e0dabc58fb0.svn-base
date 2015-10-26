//
//  ForkizeEventManager.h
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForkizeEventManager : NSObject

+ (ForkizeEventManager*) getInstance;

-(void) setSuperProperties:(NSDictionary *) dict;
-(void) setSuperPropertiesOnce:(NSDictionary *) dict;


-(void) queueSessionStart ;
-(void) queueSessionEnd:(long) time;
-(void) eventDuration:(NSString*) eventName;

-(void) queueEventWithName:(NSString*) eventName andValue:(NSInteger) value andParams:(NSDictionary *)params;
-(void) queueAliasWithOldUserId:(NSString*) oldUserId andNewUserId:(NSString*) newUserId;

-(void) queueNewInstall;

-(void) queueDeviceInfo:(NSDictionary *) deviceInfo ;
-(void) queueUserInfo:(NSDictionary *)  userInfo;

-(void) close;

@end
