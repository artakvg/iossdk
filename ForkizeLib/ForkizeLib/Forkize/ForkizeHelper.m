//
//  ForkizeHelper.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "ForkizeHelper.h"
// FZ::TODO why we need it ?
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

@implementation ForkizeHelper


+(BOOL) isNilOrEmpty:(NSString *) str{
    return (str == nil) || ([str length] == 0);
}

+(NSString *) md5:(NSString *) input{
    if (input == nil) {
        return nil;
    }
    
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+(BOOL) isKeyValid:(NSString *) key{
    
    if ([key length ] > 255 ||  [key length] == 0 || [[key substringToIndex:1] isEqualToString:@"$"]) {
        NSLog(@"Forkize SDK The key is not valid, it shouldn't start with $ and length must be less than 255 and more 0");
        return FALSE;
    }
    return TRUE;
}

@end
