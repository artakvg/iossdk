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

-(void) alias:(NSString*) userId;

-(void) applyAlias;

//-(void) exchangeIds;

//-(void) updateProfile:(NSDictionary *) dict;
//-(void) setProfile:(NSDictionary *) dict;

-(void) setValue:(id)value forKey:(NSString *)key;
-(void) setOnceValue:(id)value forKey:(NSString *)key;
-(void) setBatch:(NSDictionary *) dict;

-(void) unsetForKey:(NSString *)key;
-(void) unsetBatch:(NSArray *) array;

-(void) incrementValue:(NSString *)value  forKey:(NSString*) key;
-(void) appendForKey:(NSString*) key andValue:(id) value;
-(void) prependForKey:(NSString*) key andValue:(id) value;

-(void) incrementBatch:(NSDictionary *)dict;

-(void) syncProfile; // profile version

-(void) setAge:(NSInteger ) age;
-(NSInteger) getAge;

-(void) setMale:(BOOL) male;
-(void) setFemale:(BOOL) female;
-(NSString*) getGender;

-(NSString *) getChangeLog;
-(id) getChangeLogJSON;
-(void) dropChangeLog;

- (void) start;
- (void) end;
- (void) pause;
- (void) resume;


@end
