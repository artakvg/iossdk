//
//  LocalStorageManager.h
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILocalStorage.h"

@interface LocalStorageManager : NSObject

+ (LocalStorageManager*) getInstance;

-(void) flushToDatabase ;
-(void) close;

-(void) addEvent:(FZEvent *) event;
-(NSArray *) getEvents:(NSInteger) eventCount;

-(BOOL) removeEvents:(NSArray *) events;

-(void) changeUserId;
-(void) aliasWithOldUserId:(NSString*) oldUserId andNewUserId:(NSString*) newUserId;

-(FZUser*)getAliasedUser:(NSString*) userName;
-(void) exchangeIds:(NSString*) userName;

-(NSString *) getUserInfo:(NSString*) userId;
-(void) setUserInfo:(NSString*) userId andChangeLog:(NSString*) userInfo;

@end
