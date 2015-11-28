//
//  SQLiteLocalStorage.h
//  ForkizeLib
//
//  Created by Artak on 9/11/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQLiteLocalStorage : NSObject

-(BOOL) writeArray:(NSArray *) arrayData;

-(NSArray *) readWithCount:(NSInteger) count forUser:(NSString *) userId;

-(NSArray *) readForUser:(NSString *) userId;

-(BOOL) removeEventsWithCount:(NSInteger ) count forUser:(NSString *) userId;

-(BOOL) updateEvents:(NSArray *) events;

//-(void) reset;
//-(void) close;

@end
