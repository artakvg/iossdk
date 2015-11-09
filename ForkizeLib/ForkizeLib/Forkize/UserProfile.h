//
//  UserProfile.h
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserProfile : NSObject

+ (UserProfile*) getInstance;

@property (nonatomic, assign) NSInteger aliasedLevel; 

-(void) aliasWithOldUserId:(NSString*) oldUserId andNewUserId:(NSString*) newUserId;
-(void) updateProfile:(NSDictionary *) dict;
-(void) setProfile:(NSDictionary *) dict;
-(void) incrementValueForKey:(NSString*) key byValue:(NSString *) value;

// FZ::TODO // Why it is TODO ????
-(void) incrementByDictonary:(NSDictionary *)dict;


-(void) setAge:(NSInteger ) age;
-(NSInteger) getAge;

-(NSString*) getUserId;
-(NSDictionary *) getUserInfo;

-(void) appendForKey:(NSString*) key andValue:(id) value;
-(void) prependForKey:(NSString*) key andValue:(id) value;

-(void) setMale:(BOOL) male;
-(void) setFemale:(BOOL) female;

-(void) setValue:(id)value forKey:(NSString *)key;
-(void) unsetForKey:(NSString *)key;

-(NSString*) getGender;

-(BOOL) isNewInstall;

-(void) identify:(NSString *) userId;

-(NSString *) getChangeLog;

-(id) getChangeLogJSON;

-(void) dropChangeLog;

-(void) printChangeLog;

-(void) flushToDatabase;

-(void) restoreFromDatabase;

@end
