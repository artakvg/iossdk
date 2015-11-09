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
#import "ForkizeInstance.h"

#import "Request.h"
#import "SessionInstance.h"
#import "UserProfile.h"
#import "FZEvent.h"
#import "FZUser.h"

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
        
        if ([RestClient getInstance].accessToken == nil) {
            [RestClient getInstance].accessToken = [self.request getAccessToken];
        }
        
        if (![[[UserProfile getInstance] getChangeLog] isEqualToString:@"{}"]) {
            if ([self.request  updateUserProfile:[RestClient getInstance].accessToken]){
                [[UserProfile getInstance] dropChangeLog];
            }
        }
        
        //aliasedLevel
        // 0 - unknown
        //1 - exist
        // 2 - not exist
        
        if ([UserProfile getInstance].aliasedLevel == 0) {
            FZUser * user = [self.localStorage getAliasedUser:[[UserProfile getInstance] getUserId]];
            if ([ForkizeHelper isNilOrEmpty:user.aliasedName]) {
                [UserProfile getInstance].aliasedLevel = 2;
            } else {
                [UserProfile getInstance].aliasedLevel = 1;
            }
        }
        
        if ([UserProfile getInstance].aliasedLevel == 1) {
            FZUser *newUser = [self.localStorage getAliasedUser:[[UserProfile getInstance] getUserId]];
            if ([self.request postAlias:newUser andAccessToken:[RestClient getInstance]. accessToken]) {
                [self.localStorage flushToDatabase];
                [self.localStorage exchangeIds:[[UserProfile getInstance] getUserId]];
                
                [UserProfile getInstance].aliasedLevel = 2;
            }
        }
        
        NSArray *eventArray = [self.localStorage getEvents:[ForkizeConfig getInstance].MAX_EVENTS_PER_FLUSH];
        NSInteger lastEventsCount = [eventArray count];
        
        if (lastEventsCount == 0) {
            return;
        }
        
        NSMutableArray *arrayData = [NSMutableArray array];
        
        for (FZEvent *event in eventArray) {
            NSError *parseError = nil;
           
            NSData *data = [event.eventValue dataUsingEncoding:NSUTF8StringEncoding];
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
            
            [arrayData addObject:jsonObject];
        }
        
        NSInteger responseCode = [self.request postWithBody:arrayData andAccessToken:[RestClient getInstance].accessToken];
        if (responseCode == 1) {
            [self.localStorage removeEvents:eventArray];
        } else if (responseCode == 2){
            [RestClient getInstance].accessToken = nil;
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
            NSLog(@"Forkize SDK Trying to schedule a rest client execution while shutdown");
        } else {
            [self.queue addOperation:[[FzRestOperation alloc] init]];
        }
    } @catch (NSException *exception) {
        NSLog(@"Forkize SDK Error while scheduling a rest client execution %@", exception);
    }
}

-(void) dropAccessToken{
    self.accessToken = nil;
}

@end
