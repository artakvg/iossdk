//
//  Request.h
//  ForkizeLib
//
//  Created by Artak on 9/16/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Request : NSObject

+ (Request*) getInstance;

-(NSString *) getAccessToken;

-(NSDictionary *) postAliasWithAliasedUserId:(NSString*) aliasedUserId andUserId:(NSString*) userId andAccessToken:(NSString *)accessToken;

-(NSDictionary *) updateUserProfile:(NSString *) accessToken;

-(NSDictionary *) postWithBody:(NSArray *) arrayData andAccessToken:(NSString *) accessToken;

@end
