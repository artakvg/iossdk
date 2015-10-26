//
//  RestClient.h
//  ForkizeLib
//
//  Created by Artak on 9/16/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestClient : NSObject

+ (RestClient*) getInstance;

-(void) close;
-(void) flush;

-(void) dropAccessToken;

@property (nonatomic, strong) NSString *accessToken;

@end
