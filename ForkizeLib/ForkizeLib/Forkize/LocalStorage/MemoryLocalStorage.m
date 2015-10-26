//
//  MemoryLocalStorage.m
//  ForkizeLib
//
//  Created by Artak on 9/11/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "MemoryLocalStorage.h"
#import "ForkizeConfig.h"
#import "FZEvent.h"

@interface MemoryLocalStorage()

@property (nonatomic, assign) NSInteger eventMaxCount;
@property (nonatomic, strong) NSMutableArray *events;

@end
@implementation MemoryLocalStorage

-(instancetype) init{
    self = [super init];
    if (self) {
        self.eventMaxCount =  [[ForkizeConfig getInstance] maxEventsPerFlush];
        self.events = [NSMutableArray array];
    }
    
    return self;
}
-(NSString *) getUserInfo:(NSString*) userId{
    return nil;
}

-(void) setUserInfo:(NSString*) userId andChangeLog:(NSString*) userInfo{
}



-(BOOL) write:(FZEvent *) data{
    if ([self.events count] < self.eventMaxCount) {
        [self.events addObject:data];
        return TRUE;
    }
    
    return FALSE;
}

-(BOOL) writeArray:(NSArray *) arrayData{
    for (FZEvent * event in arrayData) {
        if (![self write:event]) {
            return FALSE;
        }
    }
    return TRUE;
}

-(NSArray *) read{
    return [self readWithQuantity:self.eventMaxCount];
}

-(NSArray *) readWithQuantity:(NSInteger) quantity{
    NSInteger len = MIN([self.events count], quantity);
    
    return [self.events subarrayWithRange:NSMakeRange(0, len)];
}

-(void) flush{
    [self reset];
}

-(BOOL) removeEvents:(NSArray *) events{
    [self.events removeObjectsInArray:events];
    return YES;
}

-(void) reset{
    [self.events removeAllObjects];
}

-(void) close{
}

-(void) changeUserId{
}

-(void) aliasWithOldUserId:(NSString*) oldUserId andNewUserId:(NSString*) newUserId{
}

-(FZUser*)getAliasedUser:(NSString*) userName{
    return nil;
}

-(void) exchangeIds:(NSString*) userName{
}

@end
