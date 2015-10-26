//
//  EventsDAO.h
//  iTennis
//
//  Created by Artak Martirosyan on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SQLiteDatabase;
@class FZEvent;
@class FZUser;

@interface EventsDAO : NSObject


@property (nonatomic, strong) FZUser *user;

- (id) initWithSQLiteDatabase:(SQLiteDatabase *)database;

- (NSArray *) loadEvents; // array of FZEvents
- (NSArray *) loadEventsWithQuantity:(NSInteger) quantity; // array of FZEvents

- (NSArray *) loadEventForUser:(FZUser *)user;

- (void) updateEvents:(NSArray *) events;

- (FZEvent*) addEvent:(FZEvent*) event;
- (BOOL) addEvents:(NSArray *)events; // array of FZEvents

- (BOOL) removeEvents; // array of FZEvents
- (BOOL) removeEvents:(NSArray *) events; // array of FZEvents

@end
