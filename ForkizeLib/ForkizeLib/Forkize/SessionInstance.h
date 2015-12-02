//
//  SessionInstance.h
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionInstance : NSObject

-(NSString*) getSessionId;

//- (long) getSessionLength;
//- (long) getSessionStart;


- (void) start;
- (void) end;
- (void) pause;
- (void) resume;

@property (nonatomic, readonly) long sessionLength;
@property (nonatomic, readonly) long sessionStartTime;


+ (SessionInstance*) getInstance;

@end
