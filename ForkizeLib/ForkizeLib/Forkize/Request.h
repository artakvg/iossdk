//
//  Request.h
//  ForkizeLib
//
//  Created by Artak on 9/16/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FZUser;

@interface Request : NSObject

+ (Request*) getInstance;

-(NSInteger) postWithBody:(NSArray *) arrayData andAccessToken:(NSString *) accessToken;

-(BOOL) postAlias:(FZUser *)user andAccessToken:(NSString *)accessToken; //TODO remove FZUSer from here

-(NSString *) getAccessToken;

-(BOOL) updateUserProfile:(NSString *) accessToken;

@end
