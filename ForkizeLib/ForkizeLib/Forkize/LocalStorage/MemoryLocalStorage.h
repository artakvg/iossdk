//
//  MemoryLocalStorage.h
//  ForkizeLib
//
//  Created by Artak on 9/11/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ILocalStorage.h"
@class FZEvent;

@interface MemoryLocalStorage : NSObject//<ILocalStorage>

-(NSArray *) read;
-(BOOL) write:(FZEvent *) event;

-(void) flush;

-(void) reset;
-(void) close;

@end
