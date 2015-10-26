//
//  ILocalStorage.h
//  ForkizeLib
//
//  Created by Artak on 9/11/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

@class FZUser;
@class FZEvent;

@protocol ILocalStorage <NSObject>



-(NSString *) getUserInfo:(NSString*) userId;

-(void) setUserInfo:(NSString*) userId andChangeLog:(NSString*) userInfo;


-(void) changeUserId;
-(void) aliasWithOldUserId:(NSString*) oldUserId andNewUserId:(NSString*) newUserId; 

-(FZUser*)getAliasedUser:(NSString*) userName;
-(void) exchangeIds:(NSString*) userName; //UserName set to ALiasedName

-(BOOL) write:(FZEvent *) event;
-(BOOL) writeArray:(NSArray *) arrayData;

-(NSArray *) read;
-(NSArray *) readWithQuantity:(NSInteger) quantity;

-(void) flush;
-(BOOL) removeEvents:(NSArray *) events;

-(void) reset;
-(void) close;


@end
