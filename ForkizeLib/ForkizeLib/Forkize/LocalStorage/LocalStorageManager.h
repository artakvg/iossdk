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

+ (LocalStorageManager*) getInstance;

-(void) flushToDatabase ;
-(void) close;

-(void) addEvent:(FZEvent *) event;
-(NSArray *) getEvents:(NSInteger) eventCount;

-(BOOL) removeEvents:(NSArray *) events;

/*
-(void) changeUserId;
-(void) aliasWithOldUserId:(NSString*) oldUserId andNewUserId:(NSString*) newUserId;

-(FZUser*)getAliasedUser:(NSString*) userName;
-(void) exchangeIds:(NSString*) userName;


-(FZUser*) getUser:(NSString*) userId;
-(void) setUser:(FZUser*) user;
*/
@end
