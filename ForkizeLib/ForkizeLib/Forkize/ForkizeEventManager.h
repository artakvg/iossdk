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


-(void) queueSessionStart;
-(void) queueSessionEnd;
-(void) eventDuration:(NSString*) eventName;

-(void) queueEventWithName:(NSString*) eventName andParams:(NSDictionary *)params;
-(void) queueAliasWithOldUserId:(NSString*) oldUserId andNewUserId:(NSString*) newUserId;

-(void) queueNewInstall;

-(void) queueDeviceInfo;
-(void) queueUserInfo;

-(void) close;

-(void) advanceState:(NSString *) state;

-(void) resetState:(NSString *) state;

-(void) pauseState:(NSString *) state;

-(void) resumeState:(NSString *) state;


@end
