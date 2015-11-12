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
#import "UserProfile.h"

@interface LocalStorageManager()

@property (nonatomic, strong) SQLiteLocalStorage *secondaryStorage;
@property (nonatomic, strong) MemoryLocalStorage *imMemoryStorage;
@property (nonatomic, strong) id eventLock;
@end

@implementation LocalStorageManager

-(instancetype) init{
    self = [super init];
    
    if (self) {
        @try {
            self.eventLock = [[NSObject alloc] init];
            self.imMemoryStorage = [[MemoryLocalStorage alloc] init];
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

/*
// FZ::TODO think getUserInfo, setUserInfo should be moved to UserProfile

-(FZUser*) getUser:(NSString*) userId{
    @synchronized(self.eventLock) {
        @try {
            return [self.secondaryStorage getUser:userId];
        }
        @catch (NSException *exception) {
            NSLog(@"Forkize SDK get user info exception %@", exception);
        }
    }
    
    return nil;
}
// FZ::TODO look at getUserInfo
-(void) setUser:(FZUser*) user{
    @synchronized(self.eventLock) {
        @try {
            return [self.secondaryStorage setUser:user];
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
 
*/

-(void) addEvent:(FZEvent *) event{
    @synchronized(self.eventLock)
    {
        if (![self.imMemoryStorage write:event] ) {
            [self.secondaryStorage writeArray:[self.imMemoryStorage read]];
            [self.imMemoryStorage flush];
            [self.imMemoryStorage write:event];
        }
    }
}

-(NSArray *) getEvents:(NSInteger) eventCount {
    
    @synchronized(self.eventLock)
    {
        @try {
            return [self.secondaryStorage readWithQuantity:eventCount forUser:[[UserProfile getInstance] getUserId]];
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
        [self.secondaryStorage writeArray:[self.imMemoryStorage read]];
        [self.imMemoryStorage flush];
    } @catch (NSException *e) {
        NSLog(@"Forkize SDK Exception thrown flushing data to database");
    }
}

-(void) reset {
    [self.imMemoryStorage reset];
    if (self.secondaryStorage != nil)
        [self.secondaryStorage reset];
}

-(void) close {
    [self.imMemoryStorage close];
    if (self.secondaryStorage != nil)
        [self.secondaryStorage close];
}


@end
