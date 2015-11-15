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

-(NSInteger) postWithBody:(NSArray *) arrayData andAccessToken:(NSString *) accessToken;

-(BOOL) postAliasWithAliasedUserId:(NSString*) aliasedUserId andUserId:(NSString*) userId andAccessToken:(NSString *)accessToken;

-(NSString *) getAccessToken;

-(BOOL) updateUserProfile:(NSString *) accessToken;

@end
