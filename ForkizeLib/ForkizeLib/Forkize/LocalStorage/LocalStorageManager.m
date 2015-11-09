//
//  LocalStorageManager.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "LocalStorageManager.h"
#import "MemoryLocalStorage.h"
#import "SQLiteLocalStorage.h"

@interface LocalStorageManager()

@property (nonatomic, strong) id<ILocalStorage> secondaryStorage;
@property (nonatomic, strong) id<ILocalStorage> cache;
@property (nonatomic, strong) id eventLock;
@end

@implementation LocalStorageManager

-(instancetype) init{
    self = [super init];
    
    if (self) {
        @try {
            self.eventLock = [[NSObject alloc] init];
            self.cache = [[MemoryLocalStorage alloc] init];
            self.secondaryStorage = [[SQLiteLocalStorage alloc] init];
        }
        @catch (NSException *exception) {
            NSLog(@"Forkize SDK Error opening SQLite database %@", exception);
        }
    }
    
    return self;
}

+ (LocalStorageManager*) getInstance {
    static LocalStorageManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LocalStorageManager alloc] init];
    });
    return sharedInstance;
}

// FZ::TODO think getUserInfo, setUserInfo should be moved to UserProfile

-(NSString *) getUserInfo:(NSString*) userId{
    @synchronized(self.eventLock) {
        @try {
            return [self.secondaryStorage getUserInfo:userId];
        }
        @catch (NSException *exception) {
            NSLog(@"Forkize SDK get user info exception %@", exception);
        }
    }
    
    return nil;
}
// FZ::TODO look at getUserInfo
-(void) setUserInfo:(NSString*) userId andChangeLog:(NSString*) userInfo{
    @synchronized(self.eventLock) {
        @try {
            return [self.secondaryStorage setUserInfo:userId andChangeLog:userInfo];
        }
        @catch (NSException *exception) {
            NSLog(@"Forkize SDK set user info exception %@", exception);
        }
    }
}
// FZ::TODO look at getUserInfo
-(void) changeUserId{
    @synchronized(self.eventLock) {
        @try {
            [self.secondaryStorage changeUserId];
        }
        @catch (NSException *exception) {
            NSLog(@"Forkize SDK change user exception %@", exception);
        }
        
    }
}

// FZ::TODO look at getUserInfo
-(void) aliasWithOldUserId:(NSString*) oldUserId andNewUserId:(NSString*) newUserId{
    @synchronized(self.eventLock) {
        @try {
            [self.secondaryStorage aliasWithOldUserId:oldUserId andNewUserId:newUserId];
        }
        @catch (NSException *exception) {
             NSLog(@"Forkize SDK alias exception %@", exception);
        }
    }
}

// FZ::TODO look at getUserInfo
-(FZUser*)getAliasedUser:(NSString*) userName{
    @synchronized(self.eventLock) {
        @try {
            return [self.secondaryStorage getAliasedUser:userName];
        }
        @catch (NSException *exception) {
            NSLog(@"Forkize SDK getAliasedUser exception %@", exception);
        }
    }
}
// FZ::TODO look at getUserInfo
-(void) exchangeIds:(NSString*) userName{
    @synchronized(self.eventLock) {
        @try {
            [self.secondaryStorage exchangeIds:userName];
        }
        @catch (NSException *exception) {
            NSLog(@"Forkize SDK exchangeIds exception %@", exception);
        }
    }
}


-(void) addEvent:(FZEvent *) event{
    @synchronized(self.eventLock)
    {
        if (![self.cache write:event] ) {
            [self.secondaryStorage writeArray:[self.cache read]];
            [self.cache flush];
            [self.cache write:event];
        }
    }
}

-(NSArray *) getEvents:(NSInteger) eventCount {
    
    @synchronized(self.eventLock)
    {
        @try {
            return [self.secondaryStorage readWithQuantity:eventCount];
        } @catch (NSException *e) {
            NSLog(@"Forkize SDK Exception thrown getting events %@", e);
        }
    }
}

-(BOOL) removeEvents:(NSArray *) events {
    @synchronized (self.eventLock)
    {
        @try {
            return [self.secondaryStorage removeEvents:events];
        } @catch (NSException* e) {
            NSLog(@"Forkize SDK Exception thrown removing events %@", e);
        }
    }
}

-(void) flushToDatabase {
    @try {
        [self.secondaryStorage writeArray:[self.cache read]];
        [self.cache flush];
    } @catch (NSException *e) {
        NSLog(@"Forkize SDK Exception thrown flushing data to database");
    }
}

-(void) reset {
    [self.cache reset];
    if (self.secondaryStorage != nil)
        [self.secondaryStorage reset];
}

-(void) close {
    [self.cache close];
    if (self.secondaryStorage != nil)
        [self.secondaryStorage close];
}


@end
