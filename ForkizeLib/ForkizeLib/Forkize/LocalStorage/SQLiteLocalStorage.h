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

-(NSArray *) readWithQuantity:(NSInteger) quantity forUser:(NSString *) userId;

-(BOOL) removeEvents:(NSArray *) events;

-(void) reset;
-(void) close;

@end
