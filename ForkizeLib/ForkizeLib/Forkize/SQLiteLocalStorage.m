//
//  SQLiteLocalStorage.m
//  ForkizeLib
//
//  Created by Artak on 9/11/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "SQLiteLocalStorage.h"
#import "DAOFactory.h"
#import "FZEventsDAO.h"
#import "FZEvent.h"

#import "ForkizeHelper.h"
#import "UserProfile.h"
#import "ForkizeDefines.h"

@interface SQLiteLocalStorage()

@property (nonatomic, strong) FZEventsDAO *eventDAO;
@property (nonatomic, strong) DAOFactory *daoFactory;

@end

@implementation SQLiteLocalStorage

-(instancetype) init{
    self = [super init];
    
    if (self) {
        self.daoFactory = [DAOFactory defaultFactory];
        self.eventDAO = [self.daoFactory eventsDAO];
    }
    
    return self;
}

-(BOOL) writeArray:(NSArray *) arrayData{
    BOOL result = NO;
    @try {
        result = [self.eventDAO addEvents:arrayData];
    }
    @catch (NSException *exception) {
        FZLog(@"Forkize SDK Exception thrown writing database %@", exception);
    }
    @finally {
         FZLog(@"Forkize SDK End writing to database");
    }
    
    return result;
}

-(NSArray *) readWithCount:(NSInteger) count forUser:(NSString *) userId{
 
    NSArray *resultArray = [NSArray array];
    
    @try {
        resultArray = [self.eventDAO readEventsWithCount:count forUser:userId];
    }
    @catch (NSException *exception) {
        FZLog(@"Forkize SDK Error occurred getting events from SQLiteDatabase %@", exception);
    }
    return resultArray;
}

-(BOOL) removeEventsWithCount:(NSInteger ) count forUser:(NSString *) userId{
    BOOL result = NO;
    
    @try {
        result = [self.eventDAO removeEventsWithCount:count forUser:userId];
    }
    @catch (NSException *exception) {
        FZLog(@"Forkize SDK Error occurred flushing events from SQLiteDatabase %@", exception);
    }
    return result;
}

-(BOOL) updateEventsForUser:(NSString *) userId withALiasedUser:(NSString *) aliasedUser{
    BOOL result = NO;
    
    @try {
        result = [self.eventDAO updateEventsForUser:userId withAliasedUser:aliasedUser];
    }
    @catch (NSException *exception) {
        FZLog(@"Forkize SDK Error occurred flushing events from SQLiteDatabase %@", exception);
    }
    return result;
}

@end
