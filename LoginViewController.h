//
//  LoginViewController.h
//  Pesterchum
//
//  Created by Michael Colvin on 9/14/12.
//  Copyright (c) 2012 Systech Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *chumhandleText;

- (IBAction)dismissKeyboard:(id)sender;

@end