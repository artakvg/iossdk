//
//  Request.m
//  ForkizeLib
//
//  Created by Artak on 9/16/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

// FZ::TODO refactoring needed, test after refactoring

#import "Request.h"
#import "ForkizeHelper.h"
#import "ForkizeConfig.h"
#import "UserProfile.h"
#import "UserProfileInternal.h"
#import "ForkizeMessage.h"

NSString *const URL_BASE_PATH = @"http://fzgate.cloudapp.net:8080";

#define URL_LIVE_PATH [NSString stringWithFormat:@"%@/%@/event/batch", URL_BASE_PATH, [ForkizeConfig getInstance].SDK_VERSION]
#define  URL_AUTH_PATH [NSString stringWithFormat:@"%@/%@/people/identify", URL_BASE_PATH, [ForkizeConfig getInstance].SDK_VERSION] 
#define URL_ALIAS_PATH  [NSString stringWithFormat:@"%@/%@/people/alias", URL_BASE_PATH, [ForkizeConfig getInstance].SDK_VERSION]

#define URL_UPDATE_PATH  [NSString stringWithFormat:@"%@/%@/profile/change", URL_BASE_PATH, [ForkizeConfig getInstance].SDK_VERSION]

@implementation Request


+ (Request*) getInstance {
    static Request *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Request alloc] init];
    });
    return sharedInstance;
}

-(NSMutableDictionary *) getCommonDict:(NSData *)jsonData{
    NSMutableString *apiDataString = nil;
    
       NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (jsonData == nil) {
        apiDataString = nil;
    } else {
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&parseError];
        
        apiDataString = [[NSMutableString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [apiDataString replaceOccurrencesOfString:@"\n" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0,[apiDataString length] - 1)];
        [apiDataString replaceOccurrencesOfString:@" " withString:@"" options:NSBackwardsSearch range:NSMakeRange(0,[apiDataString length] - 1)];
        [dict setObject:jsonObject forKeyedSubscript:@"api_data"];
    }
    
    NSString *hash = [self constructHash:apiDataString];
    
    [dict setObject:@"ios" forKey:@"sdk"];
    [dict setObject:[ForkizeConfig getInstance].SDK_VERSION forKey:@"version"];
    [dict setObject:[ForkizeConfig getInstance].appId forKey:@"app_id"];
    [dict setObject:[[UserProfile getInstance] getUserId] forKey:@"user_id"];
    [dict setObject:hash forKey:@"hash"];
    
    return dict;
}

-(NSString *) constructHash:(NSString *) apiDataString{
    NSString * hashableString = @"";
    
    if (apiDataString == nil) {
        hashableString = [NSString stringWithFormat:@"%@=%@=%@=%@=%@",
                                   [ForkizeConfig getInstance].appId,
                                   [[UserProfile getInstance] getUserId],
                                   @"ios",
                                   [ForkizeConfig getInstance].SDK_VERSION,
                                   [ForkizeConfig getInstance].appKey];
    } else {
        hashableString = [NSString stringWithFormat:@"%@=%@=%@=%@=%@=%@",
                                   [ForkizeConfig getInstance].appId,
                                   [[UserProfile getInstance] getUserId],
                                   @"ios",
                                   [ForkizeConfig getInstance].SDK_VERSION,
                                   [ForkizeConfig getInstance].appKey,
                                   apiDataString];
    }
    
    NSString *hash = [ForkizeHelper md5:hashableString];
    NSLog(@"Hashable string: %@ \n hash: %@", hashableString, hash);
    return hash;
}

-(NSDictionary*) getReponseForRequestByURL:(NSString *) urlStr andBodyDict:(NSDictionary *) dict{
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:5.0];
    
    [request setHTTPMethod:@"POST"];
    
    // [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:@"application/json" forHTTPHeaderField: @"Accept"];
    [request setValue:@"close" forHTTPHeaderField: @"Connection"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSMutableString *reqData = [NSMutableString stringWithString:jsonString];
    [reqData replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [reqData length])];
    [reqData replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [reqData length])];

    NSData *strDictData = [reqData dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:strDictData];
    
    //Send the Request
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil];
    
    //Get the Result of Request
    NSString *response = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];
    NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    return jsonDict;
}

-(NSString *) getAccessToken{
    NSString *accessToken = nil;
    @try {
        
        NSMutableDictionary *mutDict = [self getCommonDict:nil];
     
        NSDictionary* jsonDict = [self getReponseForRequestByURL:URL_AUTH_PATH andBodyDict:mutDict];
        NSLog(@"getAccessToken resonse %@", jsonDict);
        accessToken = [jsonDict objectForKey:@"access_token"];
        
        if (accessToken == nil) {
            NSLog(@"Forkize SDK ERROR !!!!!!!! accessToken is nil");
        }
        
        NSDictionary * message = [jsonDict objectForKey:@"message"];
        if (message != nil) {
            [[ForkizeMessage getInstance] showMessage:message];
        }
        
    }
    @catch (NSException *exception) {
        
    }
    return accessToken;
}

-(NSDictionary *) postAliasWithAliasedUserId:(NSString*) aliasedUserId andUserId:(NSString*) userId andAccessToken:(NSString *)accessToken{
    
    if ([ForkizeHelper isNilOrEmpty:aliasedUserId]) {
        return nil;
    }
    
    @try {
        NSDictionary *api_dataDict = [NSDictionary dictionaryWithObject:aliasedUserId forKey:@"alias_id"];
        
        //FZ::TODO TEST NSJSONWritingPrettyPrinted OR 0
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:api_dataDict options:NSJSONWritingPrettyPrinted error:&error];
        
        NSMutableDictionary *mutDict = [self getCommonDict:jsonData];
        [mutDict setObject:userId forKey:@"user_id"];
        [mutDict setObject:accessToken forKey:@"access_token"];
        
        NSDictionary* jsonDict = [self getReponseForRequestByURL:URL_ALIAS_PATH andBodyDict:mutDict];
        NSLog(@"alias jsonDict : %@", jsonDict);
        return jsonDict;
    }
    
    @catch (NSException *exception) {
        
    }

    return nil;
}

-(NSDictionary *) updateUserProfile:(NSString *) accessToken{
    @try {
        
        NSString *jsonString = [[UserProfileInternal getInstance] getChangeLog];
        NSData *jsonData =[jsonString dataUsingEncoding:NSUTF8StringEncoding];

        NSMutableDictionary *mutDict = [self getCommonDict:jsonData];
        [mutDict setObject:accessToken forKey:@"access_token"];

        NSDictionary* jsonDict = [self getReponseForRequestByURL:URL_UPDATE_PATH andBodyDict:mutDict];
        NSLog(@"update user profile jsonDict : %@", jsonDict);
        
        return jsonDict;
      }
    @catch (NSException *exception) {
        
    }
}

-(NSDictionary *) postWithBody:(NSArray *) arrayData andAccessToken:(NSString *) accessToken{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrayData options:NSJSONWritingPrettyPrinted error:&error];
    
    NSMutableDictionary *mutDict = [self getCommonDict:jsonData];
  
    [mutDict setObject:accessToken forKey:@"access_token"];
 
    NSDictionary* jsonDict = [self getReponseForRequestByURL:URL_LIVE_PATH andBodyDict:mutDict];
    
    return jsonDict;
}


@end
