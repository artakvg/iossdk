//
//  SQLiteLocalStorage.m
//  ForkizeLib
//
//  Created by Artak on 9/11/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "SQLiteLocalStorage.h"
#import "DAOFactory.h"
#import "FZUserDAO.h"
#import "EventsDAO.h"
#import "FZUser.h"
#import "FZEvent.h"

#import "ForkizeHelper.h"
#import "ForkizeInstance.h"
#import "UserProfile.h"

@interface SQLiteLocalStorage()

@property (nonatomic, strong) EventsDAO *eventDAO;
@property (nonatomic, strong) DAOFactory *daoFactory;
@property (nonatomic, strong) FZUser *currentUser;

@end

@implementation SQLiteLocalStorage

-(instancetype) init{
    self = [super init];
    
    if (self) {
        self.daoFactory = [DAOFactory defaultFactory];
    }
    
    return self;
}

-(NSString *) getUserInfo:(NSString*) userId{
    FZUserDAO *userDAO = [self.daoFactory userDAO];
    
    FZUser *user = [userDAO getUser:userId];

    return user.changeLog;
}

-(void) setUserInfo:(NSString*) userId andChangeLog:(NSString*) userInfo{
    FZUserDAO *userDAO = [self.daoFactory userDAO];
    
    FZUser *user = [userDAO getUser:userId];
    user.changeLog = userInfo;
    
    [userDAO updateUser:user];
}

-(BOOL) write:(FZEvent *) event{
    [self.eventDAO addEvent:event];
    return YES;
}

-(BOOL) writeArray:(NSArray *) arrayData{
    BOOL result = FALSE;
    @try {
        result = [self.eventDAO addEvents:arrayData];
        result = TRUE;
    }
    @catch (NSException *exception) {
        NSLog(@"Forkize SDK Exception thrown writing database %@", exception);
    }
    @finally {
         NSLog(@"Forkize SDK End writing to database");
    }
    
    return result;
}

-(NSArray *) read{
    
    return [self.eventDAO loadEvents];
}

-(NSArray *) readWithQuantity:(NSInteger) quantity{
 
    NSArray *resultArray = [NSArray array];
    
    @try {
        resultArray = [self.eventDAO loadEventsWithQuantity:quantity];
    }
    @catch (NSException *exception) {
        NSLog(@"Forkize SDK Error occurred getting events from SQLiteDatabase %@", exception);
    }

    return resultArray;
}

-(void) flush{
    [self reset];
}

-(BOOL) removeEvents:(NSArray *) events{
    BOOL result = FALSE;
    
    @try {
        result = [self.eventDAO removeEvents:events];
    }
    @catch (NSException *exception) {
        NSLog(@"Forkize SDK Error occurred flushing events from SQLiteDatabase %@", exception);
    }
}

-(void) reset{
    [self.eventDAO removeEvents];
}

-(void) close{
}

-(void) changeUserId{
    FZUser *newUser = [[FZUser alloc] init];
    newUser.userName = [[UserProfile getInstance] getUserId];
    
    self.currentUser = newUser;
    
    FZUserDAO *userDAO = [self.daoFactory userDAO];
    NSArray *users = [userDAO loadUsers];
    FZUser *user = nil;
    
    BOOL exist = NO;
    for (FZUser *fzUser in users) {
        if ([self.currentUser.userName isEqualToString:fzUser.userName]) {
            user = fzUser;
            exist = YES;
        }
    }
    if (!exist) {
        user = [userDAO addUser:newUser.userName];
    }
    
    self.eventDAO = [self.daoFactory eventsDAO];
    self.eventDAO.user = user;
}

-(void) aliasWithOldUserId:(NSString*) oldUserName andNewUserId:(NSString*) newUserName{ //  gnum gtnum enq oldUserName-ov tox@ u aliased dashtum grum enq newUserName
    FZUserDAO *usersDAO = [self.daoFactory userDAO];
    FZUser *user = [usersDAO getUser:oldUserName];
    user.aliasedName = newUserName;
    [usersDAO updateUser:user];
}

-(FZUser*)getAliasedUser:(NSString*) userName{ // verdarznum a userName-i hamapatasxan tox@
    FZUserDAO *usersDAO = [self.daoFactory userDAO];
    FZUser *user = [usersDAO getUser:userName];
    return user;
}

-(void) exchangeIds:(NSString*) userName{ ////  gnum gtnum a userName-ov tox@  u aliased dashti gra&@ berum a grum userName u aliased@ jnjum a
 
    FZUserDAO *usersDAO = [self.daoFactory userDAO];
    FZUser *user = [usersDAO getUser:userName];
   
    EventsDAO *eventsDAO = [self.daoFactory eventsDAO];
    NSArray *events = [eventsDAO loadEventForUser:user];
    for (FZEvent *event in events) {
        event.userName = user.aliasedName;
    }
    
    [eventsDAO updateEvents:events];
    
    user.userName = user.aliasedName;
    user.aliasedName = @"";
    [usersDAO updateUser:user];
    
    [[UserProfile getInstance] identify:user.userName];
}

@end