//
//  ForkizeMessage.m
//  ForkizeLib
//
//  Created by Artak on 9/30/15.
//  Copyright © 2015 Artak. All rights reserved.
//


#import "ForkizeMessage.h"
#import "ForkizeDefines.h"

static NSString *const  FZ_MESSAGE = @"message";
static NSString *const  FZ_ID = @"id";
static NSString *const  FZ_TYPE = @"template_id";
static NSString *const  FZ_TEMPLATE = @"template";
static NSString *const  FZ_CONTENT = @"content";
static NSString *const  FZ_BODY = @"body";
static NSString *const  FZ_HEADER = @"header";
static NSString *const  FZ_TEXT = @"text";
static NSString *const  FZ_COLOR = @"color";
static NSString *const  FZ_BGCOLOR = @"bgcolor";
static NSString *const  FZ_BORDERCOLOR = @"bordercolor";
static NSString *const  FZ_FONTSIZE = @"fontsize";
static NSString *const  FZ_BUTTON1 = @"button_1";
static NSString *const  FZ_BUTTON2 = @"button_2";
static NSString *const  FZ_NOTIFICATION = @"noty";
static NSString *const  FZ_IMAGE = @"image";

@implementation ForkizeMessage


+ (ForkizeMessage*) getInstance{
    static ForkizeMessage *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ForkizeMessage alloc] init];
    });
    return sharedInstance;
}

-(void) showMessage:(NSDictionary *) messageDict{
    
    NSString *fz_message = [messageDict objectForKey:FZ_MESSAGE];
    NSString *fz_id = [messageDict objectForKey:FZ_ID];
    NSString *fz_type = [messageDict objectForKey:FZ_TYPE];
    NSString *fz_template = [messageDict objectForKey:FZ_TEMPLATE];
    NSString *fz_content = [messageDict objectForKey:FZ_CONTENT];
    NSString *fz_body = [messageDict objectForKey:FZ_BODY];
    NSString *fz_header = [messageDict objectForKey:FZ_HEADER];
    NSString *fz_text = [messageDict objectForKey:FZ_TEXT];
    NSString *fz_color = [messageDict objectForKey:FZ_COLOR];
    NSString *fz_bgcolor = [messageDict objectForKey:FZ_BGCOLOR];
    NSString *fz_bordercolor = [messageDict objectForKey:FZ_BORDERCOLOR];
    NSString *fz_fontsize = [messageDict objectForKey:FZ_FONTSIZE];
    NSString *fz_button_1 = [messageDict objectForKey:FZ_BUTTON1];
    NSString *fz_button_2 = [messageDict objectForKey:FZ_BUTTON2];
    NSString *fz_noty = [messageDict objectForKey:FZ_NOTIFICATION];
    NSString *fz_image = [messageDict objectForKey:FZ_IMAGE];
    
    
    FZLog(@"fz_message: %@\nfz_id: %@\nfz_type: %@\nfz_template: %@", fz_message, fz_id, fz_type, fz_template);

    FZLog(@"fz_content: %@\nfz_body: %@\nfz_header: %@\nfz_text: %@", fz_content, fz_body, fz_header, fz_text);
    
    FZLog(@"fz_color: %@\nfz_bgcolor: %@\nfz_bordercolor: %@\nfz_fontsize: %@", fz_color, fz_bgcolor, fz_bordercolor, fz_fontsize);
    
    FZLog(@"fz_button_1: %@\nfz_button_2: %@\nfz_noty: %@\nfz_image: %@", fz_button_1, fz_button_2, fz_noty, fz_image);
}

@end
