//
//  SessionInstance.h
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionInstance : NSObject

-(NSString*) getSessionToken; //FZ::TODO why we need it

- (long) getSessionLength;

- (void) start;
- (void) end;
- (void) pause;
- (void) resume;

+ (SessionInstance*) getInstance;

@end
