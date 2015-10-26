//
//  SessionInstance.h
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionInstance : NSObject

-(NSString*) getSessionToken;

- (long) getSessionLength;
- (void) dropSessionLength;

-(void) generateNewSessionInterval;

-(void) pause;
-(void) resume;

+ (SessionInstance*) getInstance;

@end
