//
//  IForkize.h
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

@class UserProfile;

@protocol IForkize <NSObject>


-(void) authorize:(NSString *)appId andAppKey:(NSString *)appKey;

-(void) trackEvent:(NSString*) eventName  withValue:(NSInteger)eventValue  andParams:(NSDictionary*) parameters;

-(void) purchaseWithProductId:(NSString* ) productId  andCurrency:(NSString*) currency andPrice:(double) price andQuantity: (NSInteger) quantity;

-(void) sessionStart;

-(void) sessionEnd;

-(void) eventDurationWithName:(NSString*) eventName;

-(void) setSuperProperties:(NSDictionary *) properties;

-(void) setSuperPropertiesOnce:(NSDictionary *) properties;

-(id<IForkize>) onCreate;

-(void)  onPause;

-(void)  onResume;

-(void)  onDestroy;

-(void)  onLowMemory;

-(void) onTerminate;

@end
