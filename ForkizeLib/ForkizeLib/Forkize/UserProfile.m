//
//  UserProfile.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "UserProfile.h"
#import "UserProfileInternal.h"

@interface UserProfile()

@property (nonatomic, strong) UserProfileInternal *internal;

@end

@implementation UserProfile


-(instancetype) init{
    self = [super init];
    if (self) {
        
        self.internal = [UserProfileInternal getInstance];
    }
    
    return self;
}

+ (UserProfile*) getInstance {
    static UserProfile *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UserProfile alloc] init];
    });
    return sharedInstance;
}

-(NSString*) getUserId{
    return [self.internal getUserId];
}

-(id) objectForKey:(NSString *) key{
    return [self.internal objectForKey:key];
}

-(void) identify:(NSString *) userId{
    [self.internal identify:userId];
}

-(void) logout{
    [self.internal logout];
}

-(void) alias:(NSString*) userId{
    [self.internal alias:userId];
}

-(void) setValue:(id)value forKey:(NSString *)key{
    [self.internal setValue:value forKey:key];
 }

-(void) setOnceValue:(id)value forKey:(NSString *)key{
    [self.internal setOnceValue:value forKey:key];
}

-(void) setBatch:(NSDictionary *) dict{
    [self.internal setBatch:dict];
}

-(void) setOnceBatch:(NSDictionary *) dict{
    [self.internal setOnceBatch:dict];
}

-(void) unsetForKey:(NSString *)key{
    [self.internal unsetForKey:key];
}

-(void) unsetBatch:(NSArray *) array{
    [self.internal unsetBatch:array];
}

-(void) incrementValue:(NSNumber *)value  forKey:(NSString*) key {
    [self.internal incrementValue:value forKey:key];
}

-(void) incrementBatch:(NSDictionary *)dict{
    [self.internal incrementBatch:dict];
}

-(void) appendForKey:(NSString*) key andValue:(id) value{
    [self.internal appendForKey:key andValue:value];
}

-(void) prependForKey:(NSString*) key andValue:(id) value{
    [self.internal prependForKey:key andValue:value];
}


-(void) setAge:(NSInteger ) age{
    [self.internal setAge:age];
}

-(NSInteger) getAge{
    return [self.internal getAge];
}

-(void) setMale:(BOOL) male{
    [self.internal setMale:male];
}

-(void) setFemale:(BOOL) female{
    [self.internal setFemale:female];
}

-(NSString*) getGender{
    return [self.internal getGender];
}

@end
