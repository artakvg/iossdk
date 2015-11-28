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
            NSLog(@"getEvetns");
            return [self.secondaryStorage readWithCount:eventCount forUser:[[UserProfile getInstance] getUserId]];
        } @catch (NSException *e) {
            NSLog(@"Forkize SDK Exception thrown getting events %@", e);
        }
    }
}

-(NSArray *) getEvents{
    @synchronized(self.eventLock)
    {
        @try {
            return [self.secondaryStorage readForUser:[[UserProfile getInstance] getUserId]];
        } @catch (NSException *e) {
            NSLog(@"Forkize SDK Exception thrown getting events %@", e);
        }
    }
}

-(BOOL) removeEventsWithCount:(NSInteger ) count{
    @synchronized (self.eventLock)
    {
        @try {
            return [self.secondaryStorage removeEventsWithCount:count forUser:[[UserProfile getInstance] getUserId]];
        } @catch (NSException* e) {
            NSLog(@"Forkize SDK Exception thrown removing events %@", e);
        }
    }
}

-(BOOL) updateEvents:(NSArray *) events{
    @synchronized (self.eventLock)
    {
        @try {
            return [self.secondaryStorage updateEvents:events];
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


-(void) close {
//    [self.imMemoryStorage close];
//    if (self.secondaryStorage != nil)
//        [self.secondaryStorage close];
}


@end
