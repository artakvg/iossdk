//
//  ViewController.m
//  testLibForkize
//
//  Created by Artak Vardanyan on 12/12/15.
//  Copyright © 2015 Artak Vardanyan. All rights reserved.
//

#import "ViewController.h"
#import "Forkize.h"
#import "UserProfile.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)alias:(id)sender {
    Forkize *forkize = [Forkize getInstance];
    [forkize alias:self.nameTextField.text];
}

- (IBAction)setAction:(id)sender {
    Forkize *forkize = [Forkize getInstance];
    [[forkize getProfile] setValue:self.valueTextField.text forKey:self.keyTextField.text];

}
- (IBAction)setOnceAction:(id)sender {
    Forkize *forkize = [Forkize getInstance];
    [[forkize getProfile] setOnceValue:self.valueTextField.text forKey:self.keyTextField.text];

}
- (IBAction)incrementAction:(id)sender {
    Forkize *forkize = [Forkize getInstance];
    [[forkize getProfile] incrementValue:[NSNumber numberWithFloat:[self.valueTextField.text floatValue]] forKey:self.keyTextField.text];

}
- (IBAction)unsetAction:(id)sender {
    Forkize *forkize = [Forkize getInstance];
    [[forkize getProfile] unsetForKey:self.keyTextField.text];
}
- (IBAction)generateEvent:(id)sender {
    Forkize *forkize = [Forkize getInstance];
    [forkize trackEvent:self.nameTextField.text withParams:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//c25e58888417515c6371ee4a=3E4D0420-A132-4F74-B51C-C167BAEEFD89=ios=1.0=e84dfc6676fab30b4d764d84={"unset":[],"set":{"retro":"17"},"increment":{},"set_once":{},"append":{},"prepend":{}}
//c25e58888417515c6371ee4a=3E4D0420-A132-4F74-B51C-C167BAEEFD89=ios=1.0=e84dfc6676fab30b4d764d84={"unset":[],"prepend":{},"increment":{},"set":{"retro":"17"},"append":{},"set_once":{}} 
@end
