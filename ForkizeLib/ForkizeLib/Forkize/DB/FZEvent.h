//
//  FZEvent.h
//  ForkizeLib
//
//  Created by Artak on 9/14/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FZEvent : NSObject

@property (nonatomic, assign) NSInteger Id;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *eventValue;

@end
