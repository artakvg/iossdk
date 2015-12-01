//
//  MemoryLocalStorage.m
//  ForkizeLib
//
//  Created by Artak on 9/11/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "MemoryLocalStorage.h"
#import "ForkizeConfig.h"
#import "FZEvent.h"

@interface MemoryLocalStorage()

@property (nonatomic, assign) NSInteger eventMaxCount;
@property (nonatomic, strong) NSMutableArray *events;

@end
@implementation MemoryLocalStorage

-(instancetype) init{
    self = [super init];
    if (self) {
        self.eventMaxCount =  [[ForkizeConfig getInstance] MAX_EVENTS_PER_FLUSH];
        self.events = [NSMutableArray array];
    }
    return self;
}

-(BOOL) write:(FZEvent *) data{
    if ([self.events count] < self.eventMaxCount) {
        [self.events addObject:data];
        return YES;
    }
    
    return NO;
}

-(NSArray *) read{
    if ([self.events count] < self.eventMaxCount) {
        return self.events;
    } else {
        return [self.events subarrayWithRange:NSMakeRange(0, self.eventMaxCount)];
    }
}

-(void) flush{
    [self.events removeAllObjects];
}

@end
