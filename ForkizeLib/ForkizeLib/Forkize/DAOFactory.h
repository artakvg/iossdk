//
//  DAOFactory.h
//  ForkizeLib
//
//  Created by Forkize on 8/8/13.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FZUserDAO;
@class FZEventsDAO;


@interface DAOFactory : NSObject

+ (DAOFactory *)defaultFactory;

- (FZUserDAO *) userDAO;

- (FZEventsDAO *) eventsDAO;

@end
