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

-(NSString*) getUserId;

-(id) objectForKey:(NSString *) key;

-(void) identify:(NSString *) userId;
-(void) logout;

-(void) alias:(NSString*) userId;

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

-(void) setAge:(NSInteger ) age;
-(NSInteger) getAge;

-(void) setMale:(BOOL) male;
-(void) setFemale:(BOOL) female;
-(NSString*) getGender;

// FZ::TODO set birthday, 

@end
