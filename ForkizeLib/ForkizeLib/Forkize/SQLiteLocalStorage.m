//
//  SQLiteLocalStorage.m
//  ForkizeLib
//
//  Created by Artak on 9/11/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "SQLiteLocalStorage.h"
#import "DAOFactory.h"
#import "EventsDAO.h"
#import "FZEvent.h"

#import "ForkizeHelper.h"
#import "UserProfile.h"

@interface SQLiteLocalStorage()

@property (nonatomic, strong) EventsDAO *eventDAO;
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
        result = YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Forkize SDK Exception thrown writing database %@", exception);
    }
    @finally {
         NSLog(@"Forkize SDK End writing to database");
    }
    
    return result;
}

-(NSArray *) readWithCount:(NSInteger) count forUser:(NSString *) userId{
 
    NSArray *resultArray = [NSArray array];
    
    @try {
        resultArray = [self.eventDAO loadEventsWithCount:count forUser:userId];
    }
    @catch (NSException *exception) {
        NSLog(@"Forkize SDK Error occurred getting events from SQLiteDatabase %@", exception);
    }
    return resultArray;
}

-(NSArray *) readForUser:(NSString *) userId{
    NSArray *resultArray = [NSArray array];
    
    @try {
        resultArray = [self.eventDAO loadEventsForUser:userId];
    }
    @catch (NSException *exception) {
        NSLog(@"Forkize SDK Error occurred getting events from SQLiteDatabase %@", exception);
    }
    return resultArray;
}

-(void) flush{
     [self.eventDAO removeEvents];
}

-(BOOL) removeEventsWithCount:(NSInteger ) count forUser:(NSString *) userId{
    BOOL result = NO;
    
    @try {
        result = [self.eventDAO removeEventsWithCount:count forUser:userId];
    }
    @catch (NSException *exception) {
        NSLog(@"Forkize SDK Error occurred flushing events from SQLiteDatabase %@", exception);
    }
    return result;
}

-(BOOL) updateEvents:(NSArray *) events{
    BOOL result = NO;
    
    @try {
        result = [self.eventDAO updateEvents:events];
    }
    @catch (NSException *exception) {
        NSLog(@"Forkize SDK Error occurred flushing events from SQLiteDatabase %@", exception);
    }
    return result;
}

@end
