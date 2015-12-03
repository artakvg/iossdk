//
//  ForkizeHelper.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "ForkizeHelper.h"
// FZ::DONE why we need it ?
#import <CommonCrypto/CommonDigest.h>

#import "Reachability.h"
#import "ForkizeDefines.h"

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
        FZLog(@"FZ::IOS::Error - key is not valid, it shouldn't start with $ and length must be less than 255 and more 0");
        return NO;
    }
    return YES;
}

+(NSTimeInterval) getTimeIntervalSince1970
{
    NSDate *now = [NSDate date];
    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMTForDate:now];
    NSDate *gmtDate = [now dateByAddingTimeInterval:-timeZoneOffset];
    
    return [gmtDate timeIntervalSince1970];
}

+(NSDictionary *) parseJsonString:(NSString *) jsonString{
    NSError * err;
    NSData *data =[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * dict;
    if(data!=nil){
        dict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    }
    
    return dict;
}

// ** FZ::DONE this could be moved to Forkize helper
+(NSString *) getJsonString:(NSDictionary *) dict{
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:dict options:0 error:&err];
    NSString * jsonString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    return  jsonString;
}

+(id) getJSON:(id) container{
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:container options:0 error:&error];
    
    NSError *parseError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&parseError];
    
    return jsonObject;
}




@end
