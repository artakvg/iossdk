//
//  UserProfileInternal.h
//  ForkizeLib
//
//  Created by Artak Martirosyan on 11/29/15.
//  Copyright © 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserProfileInternal : NSObject

+ (UserProfileInternal*) getInstance;

-(NSString*) getUserId;
-(NSString*) getAliasedUserId;

-(id) objectForKey:(NSString *) key;

-(void) identify:(NSString *) userId;
-(void) logout;

-(void) alias:(NSString*) userId;

-(void) applyAlias;

-(void) setValue:(id)value forKey:(NSString *)key;
-(void) setOnceValue:(id)value forKey:(NSString *)key;
-(void) setBatch:(NSDictionary *) dict;
-(void) setOnceBatch:(NSDictionary *) dict;

-(void) unsetForKey:(NSString *)key;
-(void) unsetBatch:(NSArray *) array;

-(void) incrementValue:(NSNumber *)value  forKey:(NSString*) key;
-(void) appendForKey:(NSString*) key andValue:(id) value;
-(void) prependForKey:(NSString*) key andValue:(id) value;

-(void) incrementBatch:(NSDictionary *)dict;

-(void) syncProfile:(NSDictionary *) dict; // profile version

-(void) setAge:(NSInteger ) age;
-(NSInteger) getAge;

-(void) setMale:(BOOL) male;
-(void) setFemale:(BOOL) female;
-(NSString*) getGender;

-(NSString *) getChangeLog;
-(BOOL) isChangeLogEmpty;
-(NSString *) getChangeLogJSON;
-(void) dropChangeLog;

- (void) start;
- (void) end;
- (void) pause;
- (void) resume;


@end
