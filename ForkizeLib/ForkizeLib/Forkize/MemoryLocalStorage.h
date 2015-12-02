//
//  MemoryLocalStorage.h
//  ForkizeLib
//
//  Created by Artak on 9/11/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FZEvent;

@interface MemoryLocalStorage : NSObject

-(NSArray *) read;

-(BOOL) write:(FZEvent *) event;

-(void) flush;

@end
