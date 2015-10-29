//
//  Request.m
//  ForkizeLib
//
//  Created by Artak on 9/16/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "Request.h"
#import "FZUser.h"
#import "ForkizeHelper.h"
#import "ForkizeConfig.h"
#import "ForkizeInstance.h"
#import "UserProfile.h"
#import "ForkizeMessage.h"

NSString *const URL_BASE_PATH = @"http://fzgate.cloudapp.net:8080";

#define URL_LIVE_PATH [NSString stringWithFormat:@"%@/%@/event/batch", URL_BASE_PATH, [ForkizeConfig getInstance].sdkVersion]
#define  URL_AUTH_PATH [NSString stringWithFormat:@"%@/%@/people/identify", URL_BASE_PATH, [ForkizeConfig getInstance].sdkVersion] 
#define URL_ALIAS_PATH  [NSString stringWithFormat:@"%@/%@/people/alias", URL_BASE_PATH, [ForkizeConfig getInstance].sdkVersion]

#define URL_AUPDATE_PATH  [NSString stringWithFormat:@"%@/%@/profile/update", URL_BASE_PATH, [ForkizeConfig getInstance].sdkVersion]

@implementation Request


+ (Request*) getInstance {
    static Request *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Request alloc] init];
    });
    return sharedInstance;
}

-(NSString *) getAccessToken{
    NSString *accessToken = nil;
    @try {
        
        NSString *hashableString = [NSString stringWithFormat:@"%@=%@=%@=%@=%@",
                                    [ForkizeConfig getInstance].appId,
                                    [[UserProfile getInstance] getUserId],
                                    @"ios",
                                    [ForkizeConfig getInstance].sdkVersion,
                                    [ForkizeConfig getInstance].appKey];
        
        NSString *hash = [ForkizeHelper md5:hashableString];
        
        NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
        [mutDict setObject:hash forKey:@"hash"];
        [mutDict setObject:@"ios" forKey:@"sdk"];
        [mutDict setObject:[ForkizeConfig getInstance].sdkVersion forKey:@"version"];
        [mutDict setObject:[ForkizeConfig getInstance].appId forKey:@"app_id"];
        [mutDict setObject:[[UserProfile getInstance] getUserId] forKey:@"user_id"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutDict options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSURL *url = [NSURL URLWithString:URL_AUTH_PATH];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:5.0];
        
        [request setHTTPMethod:@"POST"];
        
        NSData *strDictData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:strDictData];
        
        // [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [request setValue:@"application/json" forHTTPHeaderField: @"Accept"];
        [request setValue:@"close" forHTTPHeaderField: @"Connection"];
        
        
        //Send the Request
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil];
        
        //Get the Result of Request
        NSString *response = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];
        NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"getAccessToken resonse %@", jsonDict);
        accessToken = [jsonDict objectForKey:@"access_token"];
        
        if (accessToken == nil) {
            NSLog(@"Forkize SDK accessToken is nil");
        }
        
        NSDictionary * message = [jsonDict objectForKey:@"message"];
        if (message != nil) {
            [[ForkizeMessage getInstance] showMessage:message];
             //ForkizeMessage.getInstance(null).showMessage(message); // TODO Artak
        }
        
    }
    @catch (NSException *exception) {
        
    }
    return accessToken;
}


-(BOOL) postAlias:(FZUser *)user andAccessToken:(NSString *)accessToken{
    NSString *userName = user.userName;
    NSString *aliasedName = user.aliasedName;
    
    if ([ForkizeHelper isNilOrEmpty:aliasedName]) {
        return FALSE;
    }
    
    @try {
        NSDictionary *api_dataDict = [NSDictionary dictionaryWithObject:aliasedName forKey:@"alias_id"];
        
        
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
                                    [ForkizeConfig getInstance].sdkVersion,
                                    [ForkizeConfig getInstance].appKey,
                                    apiDataString
                                    ];
        
        NSString *hash = [ForkizeHelper md5:hashabelString];
        
        NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
        [mutDict setObject:jsonObject forKeyedSubscript:@"api_data"];
        [mutDict setObject:[ForkizeConfig getInstance].appId forKey:@"app_id"];
        [mutDict setObject:userName forKey:@"user_id"];
        [mutDict setObject:@"ios" forKey:@"sdk"];
        [mutDict setObject:[ForkizeConfig getInstance].sdkVersion forKey:@"version"];
        [mutDict setObject:accessToken forKey:@"access_token"];
        [mutDict setObject:hash forKeyedSubscript:@"hash"];
        [mutDict setObject:aliasedName forKey:@"alias_id"];
        
       
        NSData *reqJsonData = [NSJSONSerialization dataWithJSONObject:mutDict options:NSJSONWritingPrettyPrinted error:&error];
        NSString *reqJsonString = [[NSString alloc] initWithData:reqJsonData encoding:NSUTF8StringEncoding];
        
        NSURL *url = [NSURL URLWithString:URL_ALIAS_PATH];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:5.0];
        
        [request setHTTPMethod:@"POST"];
        
        NSData *strDictData = [reqJsonString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:strDictData];
        
        //[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [request setValue:@"application/json" forHTTPHeaderField: @"Accept"];
        [request setValue:@"close" forHTTPHeaderField: @"Connection"];
        
        
        //Send the Request
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil];
        
        //Get the Result of Request
        NSString *response = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];
        NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  
        NSInteger statusCode = [[jsonDict objectForKey:@"status"] integerValue];
        NSLog(@"alias jsonDict : %@", jsonDict);
        return (statusCode == 1);
    }
    
    @catch (NSException *exception) {
        
    }

    return FALSE;
}

-(BOOL) updateUserProfile:(NSString *) accessToken{
    @try {
        
        NSString *jsonString = [[UserProfile getInstance] getChangeLogJSON];
        NSData *jsonData =[jsonString dataUsingEncoding:NSUTF8StringEncoding];

        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&parseError];
//
        NSMutableString *apiDataString = [NSMutableString stringWithString:jsonString];

        
        [apiDataString replaceOccurrencesOfString:@"\n" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0,[apiDataString length] - 1)];
        [apiDataString replaceOccurrencesOfString:@" " withString:@"" options:NSBackwardsSearch range:NSMakeRange(0,[apiDataString length] - 1)];
        
        
        NSString *hashabelString = [NSString stringWithFormat:@"%@=%@=%@=%@=%@=%@",
                                    [ForkizeConfig getInstance].appId,
                                    [[UserProfile getInstance] getUserId],
                                    @"ios",
                                    [ForkizeConfig getInstance].sdkVersion,
                                    [ForkizeConfig getInstance].appKey,
                                    apiDataString
                                    ];

        NSString *hash = [ForkizeHelper md5:hashabelString];

        NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
        [mutDict setObject:jsonObject forKeyedSubscript:@"api_data"];
        [mutDict setObject:[ForkizeConfig getInstance].appId forKey:@"app_id"];
        [mutDict setObject:[[UserProfile getInstance] getUserId]  forKey:@"user_id"];
        [mutDict setObject:@"ios" forKey:@"sdk"];
        [mutDict setObject:[ForkizeConfig getInstance].sdkVersion forKey:@"version"];
        [mutDict setObject:accessToken forKey:@"access_token"];
        [mutDict setObject:hash forKeyedSubscript:@"hash"];

        
        NSError *error;
        NSData *reqJsonData = [NSJSONSerialization dataWithJSONObject:mutDict options:NSJSONWritingPrettyPrinted error:&error];
        NSString *reqJsonString = [[NSString alloc] initWithData:reqJsonData encoding:NSUTF8StringEncoding];
        
        NSURL *url = [NSURL URLWithString:URL_ALIAS_PATH];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:5.0];
        
        [request setHTTPMethod:@"POST"];
        
        NSData *strDictData = [reqJsonString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:strDictData];
        
        //[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [request setValue:@"application/json" forHTTPHeaderField: @"Accept"];
        [request setValue:@"close" forHTTPHeaderField: @"Connection"];
        
        
        //Send the Request
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil];
        
        //Get the Result of Request
        NSString *response = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];
        NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSInteger statusCode = [[jsonDict objectForKey:@"status"] integerValue];
        NSLog(@"update user profile jsonDict : %@", jsonDict);
        return (statusCode == 1);
    }
    @catch (NSException *exception) {
        
    }
    
    return FALSE;
}

-(NSInteger) postWithBody:(NSArray *) arrayData andAccessToken:(NSString *) accessToken{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrayData options:NSJSONWritingPrettyPrinted error:&error];
    
    NSMutableString *jsonString = [[NSMutableString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [jsonString replaceOccurrencesOfString:@"\n" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0,[jsonString length] - 1)];
    [jsonString replaceOccurrencesOfString:@" " withString:@"" options:NSBackwardsSearch range:NSMakeRange(0,[jsonString length] - 1)];
    
    NSString *hashableString = [NSString stringWithFormat:@"%@=%@=%@=%@=%@=%@",
                                [ForkizeConfig getInstance].appId,
                                [[UserProfile getInstance] getUserId],
                                @"ios",
                                [ForkizeConfig getInstance].sdkVersion,
                                [ForkizeConfig getInstance].appKey,
                                jsonString];
    
    NSString *hash = [ForkizeHelper md5:hashableString];
    
    NSLog(@"Hashable string: %@ \n hash: %@", hashableString, hash);
    
    NSMutableDictionary *batchDict = [NSMutableDictionary dictionary];
    [batchDict setObject:arrayData forKey:@"api_data"];
    [batchDict setValue:[ForkizeConfig getInstance].appId forKey:@"app_id"];
    [batchDict setValue:[[UserProfile getInstance] getUserId] forKey:@"user_id"];
    [batchDict setObject:@"ios" forKey:@"sdk"];
    [batchDict setObject:[[ForkizeConfig getInstance] sdkVersion] forKey:@"version"];
    [batchDict setObject:accessToken forKey:@"access_token"];
    [batchDict setObject:hash forKey:@"hash"];
    // [batchDict setObject:[NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]] forKey:@"stamp"];
    
    
    NSData *jsonBatchData = [NSJSONSerialization dataWithJSONObject:batchDict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *batchStringJSon = [[NSString alloc] initWithData:jsonBatchData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Forkize SDK accessToken %@", accessToken);
    
    NSMutableString *reqData = [NSMutableString stringWithString:batchStringJSon];
    [reqData replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [reqData length])];
    [reqData replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [reqData length])];
    

    
    NSURL *url = [NSURL URLWithString:URL_LIVE_PATH];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:5.0];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *strDictData = [reqData dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:strDictData];
   // [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField: @"Accept"];
    [request setValue:@"close" forHTTPHeaderField: @"Connection"];
    
    
    //Send the Request
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil];
    
    //Get the Result of Request
    NSString *response = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];
    NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSLog(@"postWIthBody %@ \nresult %@", reqData, jsonDict);
    
    NSInteger statusCode = [[jsonDict objectForKey:@"status"] integerValue];
    NSLog(@"postWithBody jsonDict : %@", jsonDict);

    if (statusCode == 1) {
        return 1;
    } else if (statusCode == 2){
         NSLog(@"Forkize SDK Invalid access token response");
        return 2;
    }
    
    return 0;
}


@end
