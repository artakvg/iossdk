//
//  ForkizeHelper.h
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForkizeHelper : NSObject

+(BOOL) isNilOrEmpty:(NSString *) str;

+(NSString *) md5:(NSString *) string;

+(BOOL) isKeyValid:(NSString *) key;

+(NSTimeInterval) getTimeIntervalSince1970;

+(NSDictionary *) parseJsonString:(NSString *) jsonString;
+(NSString *) getJsonString:(NSDictionary *) dict;

+(id) getJSON:(id) container;

@end
