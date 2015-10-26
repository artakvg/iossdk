//
//  ViewController.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "ViewController.h"
#import "ForkizeHelper.h"
#import "DAOFactory.h"
#import "ForkizeInstance.h"
#import "UserProfile.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
          
    UIButton *generateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    generateButton.frame = CGRectMake(100, 50, 120, 40);
    [generateButton addTarget:self action:@selector(generateAction:) forControlEvents:UIControlEventTouchUpInside];
    [generateButton setTitle:@"Generate" forState:UIControlStateNormal];
    [self.view addSubview:generateButton];
    
    userTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(50, 100, 220, 50)];
    userTextField_.backgroundColor = [UIColor greenColor];
    userTextField_.delegate = self;
    userTextField_.placeholder = @"User Name";
    [self.view addSubview:userTextField_];
    
    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    changeButton.frame = CGRectMake(100, 150, 120, 40);
    [changeButton addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventTouchUpInside];
    [changeButton setTitle:@"Change User" forState:UIControlStateNormal];
    [self.view addSubview:changeButton];
    
    keyTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(50, 200, 130, 50)];
    keyTextField_.backgroundColor = [UIColor greenColor];
    keyTextField_.delegate = self;
    keyTextField_.placeholder = @"Key";
    [self.view addSubview:keyTextField_];
    
    valueTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(190, 200, 100, 50)];
    valueTextField_.backgroundColor = [UIColor greenColor];
    valueTextField_.delegate = self;
    valueTextField_.placeholder = @"Value";
    [self.view addSubview:valueTextField_];
    
    UIButton *incementButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    incementButton.frame = CGRectMake(50, 250, 120, 40);
    [incementButton addTarget:self action:@selector(incrementAction:) forControlEvents:UIControlEventTouchUpInside];
    [incementButton setTitle:@"Increment" forState:UIControlStateNormal];
    [self.view addSubview:incementButton];
    
    UIButton *setButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    setButton.frame = CGRectMake(190, 250, 120, 40);
    [setButton addTarget:self action:@selector(setAction:) forControlEvents:UIControlEventTouchUpInside];
    [setButton setTitle:@"Set" forState:UIControlStateNormal];
    [self.view addSubview:setButton];
    
    
}

-(void) generateAction:(UIButton *) button{
    ForkizeInstance *instance = [ForkizeInstance getInstance];
    [instance trackEvent:@"gnum" withValue:12 andParams:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]] forKey:@"stamp"]];
}

-(void) changeAction:(UIButton *) button{
    [[UserProfile getInstance] aliasWithOldUserId:[[UserProfile getInstance] getUserId] andNewUserId:userTextField_.text];
}

-(void) incrementAction:(UIButton *) button{
    [[UserProfile getInstance] incrementValueForKey:valueTextField_.text byValue:keyTextField_.text];
}

-(void) setAction:(UIButton *) button{
    [[UserProfile getInstance] setValue:valueTextField_.text forKey:keyTextField_.text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
