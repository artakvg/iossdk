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

@interface EventsDAO : NSObject

- (id) initWithSQLiteDatabase:(SQLiteDatabase *)database;

- (NSArray *) loadEventsForUser:(NSString *) userId; // array of FZEvents
- (NSArray *) loadEventsWithQuantity:(NSInteger) quantity forUser:(NSString *) userId; // array of FZEvents

- (void) updateEvents:(NSArray *) events;

- (FZEvent*) addEvent:(FZEvent*) event;
- (BOOL) addEvents:(NSArray *)events; // array of FZEvents

- (BOOL) removeEvents; // all array 
- (BOOL) removeEvents:(NSArray *) events; // array of FZEvents

@end
