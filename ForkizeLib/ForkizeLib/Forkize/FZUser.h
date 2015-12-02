//
//  FZUser.h
//  ForkizeLib
//
//  Created by Artak on 9/14/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FZUser : NSObject

@property (nonatomic, assign) NSInteger rowId;
@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * aliasedId;
@property (nonatomic, strong) NSString * changeLog;
@property (nonatomic, strong) NSString * userProfile;

@end
