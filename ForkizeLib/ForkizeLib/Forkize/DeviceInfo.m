//
//  DeviceInfo.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "DeviceInfo.h"
#import "ForkizeHelper.h"
#import <UIKit/UIKit.h>

@interface DeviceInfo ()

@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString * country;
@property (nonatomic, strong) NSString * appMajorVersion;
@property (nonatomic, strong) NSString * appMinorVersion;

@property (nonatomic, strong) NSDictionary *deviceParams;

@end

@implementation DeviceInfo

+ (DeviceInfo*) getInstance {
    static DeviceInfo *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DeviceInfo alloc] init];
    });
    return sharedInstance;
}

-(NSDictionary *) getDeviceInfo{
    if (self.deviceParams == nil) {
        [self fetchParams];
    }
    
    return self.deviceParams;
}

-(void) fetchParams{
    @try {
        if ([ForkizeHelper isNilOrEmpty:self.language]) {
            self.language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
            NSLog(@"Forkize SDK Language tag %@",  self.language);
        }
        
        if([ForkizeHelper isNilOrEmpty:self.appMajorVersion]){
            self.appMajorVersion = [ [[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            NSLog(@"Forkize SDK Major Version Name %@",  self.appMajorVersion);
        }
        
        if([ForkizeHelper isNilOrEmpty:self.appMinorVersion]){
            self.appMinorVersion = [ [[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            NSLog(@"Forkize SDK Minor Version Name %@",  self.appMinorVersion);
        }
        
        NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
        [mutDict setObject:@"Apple" forKey:@"device_manufacturer"];
        [mutDict setObject:[[UIDevice currentDevice] model] forKey:@"device_model"];
        [mutDict setObject:[UIDevice currentDevice].systemVersion forKey:@"device_os_name"];
        [mutDict setObject:@"ios" forKey:@"device_os_name"];
        [mutDict setObject:[NSString stringWithFormat:@"%ld", (long)[UIScreen mainScreen].bounds.size.width] forKey:@"device_width"];
        [mutDict setObject:[NSString stringWithFormat:@"%ld", (long)[UIScreen mainScreen].bounds.size.height] forKey:@"device_height"];
        [mutDict setObject:[NSString stringWithFormat:@"%ld", (long)[[UIScreen mainScreen] scale]] forKey:@"density"];
        
        [mutDict setObject:[[NSLocale currentLocale] objectForKey: NSLocaleCountryCode] forKey:@"country"];
        [mutDict setObject:self.language forKey:@"language"];
        [mutDict setObject:self.appMajorVersion forKey:@"app_major_version"];
        [mutDict setObject:self.appMinorVersion forKey:@"app_minor_version"];
        
        self.deviceParams = [NSDictionary dictionaryWithDictionary:mutDict];

    }
    @catch (NSException *exception) {
        NSLog(@"Forkize SDK Exception thrown when device info collecting %@", exception);
    }
  
}

@end
