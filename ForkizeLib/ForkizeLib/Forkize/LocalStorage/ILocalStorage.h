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

-(FZUser*) getUser:(NSString*) userId;
-(void) setUser:(FZUser*) user;


-(void) changeUserId;
-(void) aliasWithOldUserId:(NSString*) oldUserId andNewUserId:(NSString*) newUserId; 

-(FZUser*)getAliasedUser:(NSString*) userName;
-(void) exchangeIds:(NSString*) userName; //UserName set to ALiasedName

-(BOOL) write:(FZEvent *) event;
-(BOOL) writeArray:(NSArray *) arrayData;

-(NSArray *) readForUser:(NSString *) userId;
-(NSArray *) readWithQuantity:(NSInteger) quantity forUser:(NSString *) userId;

-(void) flush;

-(BOOL) removeEventWithCount:(NSInteger ) count;

-(void) reset;
-(void) close;


@end
