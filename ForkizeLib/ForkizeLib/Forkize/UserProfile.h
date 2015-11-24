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

-(void) aliasWithOldUserId:(NSString*) oldUserId andNewUserId:(NSString*) newUserId;

-(void) exchangeIds;

-(void) updateProfile:(NSDictionary *) dict;
-(void) setProfile:(NSDictionary *) dict;

-(void) setValue:(id)value forKey:(NSString *)key;
-(void) unsetForKey:(NSString *)key;
-(void) incrementValueForKey:(NSString*) key byValue:(NSString *) value;

// FZ::TODO // Why it is TODO ????
-(void) incrementByDictonary:(NSDictionary *)dict;
-(void) appendForKey:(NSString*) key andValue:(id) value;
-(void) prependForKey:(NSString*) key andValue:(id) value;


-(void) setAge:(NSInteger ) age;
-(NSInteger) getAge;

-(void) setMale:(BOOL) male;
-(void) setFemale:(BOOL) female;
-(NSString*) getGender;

-(NSString *) getChangeLog;
-(id) getChangeLogJSON;
-(void) dropChangeLog;

-(void) flushToDatabase;
-(void) restoreFromDatabase;

@end
