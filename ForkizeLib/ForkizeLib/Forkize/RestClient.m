//
//  RestClient.m
//  ForkizeLib
//
//  Created by Artak on 9/16/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "RestClient.h"
#import "LocalStorageManager.h"

#import "ForkizeConfig.h"
#import "ForkizeHelper.h"

#import "Request.h"
#import "UserProfileInternal.h"
#import "UserProfile.h"
#import "FZEvent.h"
#import "ForkizeDefines.h"
#import "Reachability.h"

@interface FzRestOperation : NSOperation

@property (nonatomic, strong) LocalStorageManager *localStorage;
@property (nonatomic, strong) Request *request;

@end

@implementation FzRestOperation

-(instancetype) init{
    self = [super init];
    if (self) {
        self.localStorage = [LocalStorageManager getInstance];
        self.request = [Request getInstance];
    }
    
    return self;
}

- (void)main {
    
    @autoreleasepool {
        
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        if (networkStatus == NotReachable) {
            return;
        }
        
        if ([RestClient getInstance].accessToken == nil) {
            [RestClient getInstance].accessToken = [self.request getAccessToken];
        }
        
        if ([RestClient getInstance].accessToken == nil) {
            return;
        }
        
        if (![[UserProfileInternal getInstance] isChangeLogEmpty]) {
            NSDictionary * updateResponseDict = [self.request  updateUserProfile:[RestClient getInstance].accessToken];
            
            NSInteger statusCode = [[updateResponseDict objectForKey:@"status"] integerValue];
            
            if (statusCode == 1){
                [[UserProfileInternal getInstance] syncProfile:updateResponseDict];
                [[UserProfileInternal getInstance] dropChangeLog];
             }
        }
        
        NSString *aliasedName = [[UserProfileInternal getInstance] getAliasedUserId];
        
        if (![ForkizeHelper isNilOrEmpty:aliasedName]) {
            NSString *userId = [[UserProfile getInstance] getUserId];
        
            NSDictionary *aliasResponseDict = [self.request postAliasWithAliasedUserId:aliasedName andUserId:userId andAccessToken:[RestClient getInstance]. accessToken];
            
            NSString * accessToken = [aliasResponseDict objectForKey:@"access_token"];
            
            if (accessToken != nil) {
            
                [RestClient getInstance].accessToken = accessToken;
                [self.localStorage flushToDatabase];
                
                [self.localStorage updateEventsAfterAlias:aliasedName];
                
                [[UserProfileInternal getInstance] applyAlias];
            }
        }
        
        NSArray *eventArray = [self.localStorage getEventsWithCount:[ForkizeConfig getInstance].MAX_EVENTS_PER_FLUSH];
        NSInteger eventCount = [eventArray count];
        if ( eventCount == 0) {
            return;
        }
        
        NSMutableArray *arrayData = [NSMutableArray array];
        
        for (NSString *eventValue in eventArray) {
            NSError *parseError = nil;
           
            NSData *data = [eventValue dataUsingEncoding:NSUTF8StringEncoding];
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
            if (parseError == nil) {
                [arrayData addObject:jsonObject];
            }
        }
        
        NSDictionary *postResponseDict = [self.request postWithBody:arrayData andAccessToken:[RestClient getInstance].accessToken];
        
        NSInteger responseCode = [[postResponseDict objectForKey:@"status"] integerValue];
        FZLog(@"postWithBody jsonDict : %@", postResponseDict);
        
        if (responseCode == 1) {
            [self.localStorage removeEventsWithCount:eventCount];
        } else if (responseCode == 2){
            [[RestClient getInstance] dropAccessToken];
        }
    }
}

@end

@interface RestClient()


@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation RestClient


-(instancetype) init{
    self = [super init];
    if (self) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.name = @"Forkize Lib Rest Queue";
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

+ (RestClient*) getInstance{
    static RestClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RestClient alloc] init];
    });
    return sharedInstance;
}

-(void) close{
    [self.queue cancelAllOperations];
    self.queue = nil;
}

-(void) flush{
    @try {
        if (self.queue == nil) {
            @throw [NSException  exceptionWithName:@"Forkize" reason:@"Forkize SDK Trying to schedule a rest client execution while shutdown" userInfo:nil];
        } else {
            [self.queue addOperation:[[FzRestOperation alloc] init]];
        }
    } @catch (NSException *exception) {
        FZLog(@"Forkize SDK Error while scheduling a rest client execution %@", exception);
    }
}

-(void) dropAccessToken{
    self.accessToken = nil;
}

@end
