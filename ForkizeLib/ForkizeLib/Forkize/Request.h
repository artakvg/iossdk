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

-(BOOL) postAliasWithAliasedUserId:(NSString*) aliasedUserId andUserId:(NSString*) userId andAccessToken:(NSString *)accessToken;

-(BOOL) updateUserProfile:(NSString *) accessToken;

-(NSInteger) postWithBody:(NSArray *) arrayData andAccessToken:(NSString *) accessToken;

@end
