//
//  UserProfile.h
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FZUser;

@interface UserProfile : NSObject

+ (UserProfile*) getInstance;

//aliasedLevel
// 0 - unknown
//1 - exist
// 2 - not exist

//@property (nonatomic, assign) NSInteger aliasedLevel;



-(NSString*) getUserId;
-(NSString*) getAliasedUserId;

-(NSDictionary *) getUserInfo;


-(BOOL) isNewInstall;

-(void) identify:(NSString *) userId;

-(void) alias:(NSString*) userId;

-(void) exchangeIds;

//-(void) updateProfile:(NSDictionary *) dict;
//-(void) setProfile:(NSDictionary *) dict;

-(void) setValue:(id)value forKey:(NSString *)key;
-(void) setOnceValue:(id)value forKey:(NSString *)key;
-(void) setBatch:(NSDictionary *) dict;

-(void) unsetForKey:(NSString *)key;
-(void) unsetBatch:(NSArray *) array;

//-(void) incrementValueForKey:(NSString*) key byValue:(NSString *) value;

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
