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

-(NSMutableDictionary *) getCommonDict{
    NSString *userId = [[UserProfile getInstance] getUserId];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:@"ios" forKey:@"sdk"];
    [dict setObject:[ForkizeConfig getInstance].SDK_VERSION forKey:@"version"];
    [dict setObject:[ForkizeConfig getInstance].appId forKey:@"app_id"];
    [dict setObject:userId forKey:@"user_id"];
    
    return dict;
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
        
        NSString *userId = [[UserProfile getInstance] getUserId];
        
        NSString *hashableString = [NSString stringWithFormat:@"%@=%@=%@=%@=%@",
                                    [ForkizeConfig getInstance].appId,
                                    userId,
                                    @"ios",
                                    [ForkizeConfig getInstance].SDK_VERSION,
                                    [ForkizeConfig getInstance].appKey];
        
        NSString *hash = [ForkizeHelper md5:hashableString];
        
        NSMutableDictionary *mutDict = [self getCommonDict];
        
        [mutDict setObject:hash forKey:@"hash"];

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
        
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&parseError];

        NSMutableString *apiDataString = [[NSMutableString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [apiDataString replaceOccurrencesOfString:@"\n" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0,[apiDataString length] - 1)];
        [apiDataString replaceOccurrencesOfString:@" " withString:@"" options:NSBackwardsSearch range:NSMakeRange(0,[apiDataString length] - 1)];
        
        
        NSString *hashabelString = [NSString stringWithFormat:@"%@=%@=%@=%@=%@=%@",
                                    [ForkizeConfig getInstance].appId,
                                    [[UserProfile getInstance] getUserId],
                                    @"ios",
                                    [ForkizeConfig getInstance].SDK_VERSION,
                                    [ForkizeConfig getInstance].appKey,
                                    apiDataString];
        
        NSString *hash = [ForkizeHelper md5:hashabelString];
        
        NSMutableDictionary *mutDict = [self getCommonDict];
        [mutDict setObject:userId forKey:@"user_id"];
        [mutDict setObject:accessToken forKey:@"access_token"];
        [mutDict setObject:hash forKeyedSubscript:@"hash"];
        [mutDict setObject:aliasedUserId forKey:@"alias_id"];
        [mutDict setObject:jsonObject forKeyedSubscript:@"api_data"];
        
        NSDictionary* jsonDict = [self getReponseForRequestByURL:URL_ALIAS_PATH andBodyDict:mutDict];
        NSLog(@"alias jsonDict : %@", jsonDict);
        return jsonDict;
    }
    
    @catch (NSException *exception) {
        
    }

    return nil;
}

-(BOOL) updateUserProfile:(NSString *) accessToken{
    @try {
        
        NSString *jsonString = [[UserProfile getInstance] getChangeLogJSON];
        NSData *jsonData =[jsonString dataUsingEncoding:NSUTF8StringEncoding];

        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&parseError];

        NSMutableString *apiDataString = [NSMutableString stringWithString:jsonString];

        
        [apiDataString replaceOccurrencesOfString:@"\n" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0,[apiDataString length] - 1)];
        [apiDataString replaceOccurrencesOfString:@" " withString:@"" options:NSBackwardsSearch range:NSMakeRange(0,[apiDataString length] - 1)];
        
        
        NSString *hashabelString = [NSString stringWithFormat:@"%@=%@=%@=%@=%@=%@",
                                    [ForkizeConfig getInstance].appId,
                                    [[UserProfile getInstance] getUserId],
                                    @"ios",
                                    [ForkizeConfig getInstance].SDK_VERSION,
                                    [ForkizeConfig getInstance].appKey,
                                    apiDataString
                                    ];

        NSString *hash = [ForkizeHelper md5:hashabelString];
        
        NSMutableDictionary *mutDict = [self getCommonDict];
        [mutDict setObject:jsonObject forKeyedSubscript:@"api_data"];
        [mutDict setObject:accessToken forKey:@"access_token"];
        [mutDict setObject:hash forKeyedSubscript:@"hash"];

        NSDictionary* jsonDict = [self getReponseForRequestByURL:URL_UPDATE_PATH andBodyDict:mutDict];
        
        NSInteger statusCode = [[jsonDict objectForKey:@"status"] integerValue];
        NSLog(@"update user profile jsonDict : %@", jsonDict);
        return (statusCode == 1);
    }
    @catch (NSException *exception) {
        
    }
    
    return NO;
}

-(NSDictionary *) postWithBody:(NSArray *) arrayData andAccessToken:(NSString *) accessToken{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrayData options:NSJSONWritingPrettyPrinted error:&error];
    
    NSMutableString *jsonString = [[NSMutableString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [jsonString replaceOccurrencesOfString:@"\n" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0,[jsonString length] - 1)];
    [jsonString replaceOccurrencesOfString:@" " withString:@"" options:NSBackwardsSearch range:NSMakeRange(0,[jsonString length] - 1)];
    
    NSString *hashableString = [NSString stringWithFormat:@"%@=%@=%@=%@=%@=%@",
                                [ForkizeConfig getInstance].appId,
                                [[UserProfile getInstance] getUserId],
                                @"ios",
                                [ForkizeConfig getInstance].SDK_VERSION,
                                [ForkizeConfig getInstance].appKey,
                                jsonString];
    
    NSString *hash = [ForkizeHelper md5:hashableString];
    
    NSLog(@"Hashable string: %@ \n hash: %@", hashableString, hash);
    
    NSMutableDictionary *mutDict = [self getCommonDict];
  
    [mutDict setObject:arrayData forKey:@"api_data"];
    [mutDict setObject:accessToken forKey:@"access_token"];
    [mutDict setObject:hash forKey:@"hash"];
 
    NSDictionary* jsonDict = [self getReponseForRequestByURL:URL_LIVE_PATH andBodyDict:mutDict];
    
    return jsonDict;
}


@end
