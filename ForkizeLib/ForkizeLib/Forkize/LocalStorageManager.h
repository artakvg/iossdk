//
//  LocalStorageManager.h
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FZEvent;

@interface LocalStorageManager : NSObject

+(LocalStorageManager*) getInstance;

-(void) flushToDatabase ;
-(void) close;

-(void) addEvent:(FZEvent *) event;

-(NSArray *) getEventsWithCount:(NSInteger) eventCount;

-(BOOL) removeEventsWithCount:(NSInteger ) count;

-(BOOL)  updateEventsAfterAlias:(NSString *) aliasedUser;

@end
