//
//  Request.m
//  ForkizeLib
//
//  Created by Artak on 9/16/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "Request.h"
#import "ForkizeHelper.h"
#import "ForkizeConfig.h"
#import "UserProfile.h"
#import "UserProfileInternal.h"
#import "ForkizeMessage.h"
#import "ForkizeDefines.h"

#define URL_LIVE_PATH   [NSString stringWithFormat:@"%@/event/batch",     [ForkizeConfig getInstance].BASE_URL]
#define URL_AUTH_PATH   [NSString stringWithFormat:@"%@/people/identify", [ForkizeConfig getInstance].BASE_URL]
#define URL_ALIAS_PATH  [NSString stringWithFormat:@"%@/people/alias",    [ForkizeConfig getInstance].BASE_URL]
#define URL_UPDATE_PATH [NSString stringWithFormat:@"%@/profile/change",  [ForkizeConfig getInstance].BASE_URL]

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
    FZLog(@"Hashable string: %@ \n hash: %@", hashableString, hash);
    return hash;
}

-(NSDictionary*) getReponseForRequestByURL:(NSString *) urlStr andBodyDict:(NSDictionary *) dict{
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:[ForkizeConfig getInstance].REQUEST_TIMEOUT];
    
    [request setHTTPMethod:@"POST"];
    
    // [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:@"application/json" forHTTPHeaderField: @"Accept"];
    [request setValue:@"close" forHTTPHeaderField: @"Connection"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSMutableString *reqData = [NSMutableString stringWithString:jsonString];

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
        FZLog(@"getAccessToken resonse %@", jsonDict);
        accessToken = [jsonDict objectForKey:@"access_token"];
        
        if (accessToken == nil) {
            FZLog(@"Forkize SDK ERROR !!!!!!!! accessToken is nil");
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
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:api_dataDict options:0 error:&error];
        
        NSMutableDictionary *mutDict = [self getCommonDict:jsonData];
        [mutDict setObject:userId forKey:@"user_id"];
        [mutDict setObject:accessToken forKey:@"access_token"];
        
        NSDictionary* jsonDict = [self getReponseForRequestByURL:URL_ALIAS_PATH andBodyDict:mutDict];
        FZLog(@"alias jsonDict : %@", jsonDict);
        return jsonDict;
    }
    
    @catch (NSException *exception) {
        
    }

    return nil;
}

-(NSDictionary *) updateUserProfile:(NSString *) accessToken{
    @try {
        
        NSString *jsonString = [[UserProfileInternal getInstance] getChangeLogJSON];
        NSData *jsonData =[jsonString dataUsingEncoding:NSUTF8StringEncoding];

        NSMutableDictionary *mutDict = [self getCommonDict:jsonData];
        [mutDict setObject:accessToken forKey:@"access_token"];

        NSDictionary* jsonDict = [self getReponseForRequestByURL:URL_UPDATE_PATH andBodyDict:mutDict];
        FZLog(@"update user profile jsonDict : %@", jsonDict);
        
        return jsonDict;
      }
    @catch (NSException *exception) {
        
    }
}

-(NSDictionary *) postWithBody:(NSArray *) arrayData andAccessToken:(NSString *) accessToken{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrayData options:0 error:&error];
    
    NSMutableDictionary *mutDict = [self getCommonDict:jsonData];
  
    [mutDict setObject:accessToken forKey:@"access_token"];
 
    NSDictionary* jsonDict = [self getReponseForRequestByURL:URL_LIVE_PATH andBodyDict:mutDict];
    
    return jsonDict;
}


@end
