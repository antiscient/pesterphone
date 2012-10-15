//
//  PesterUserViewController.h
//  Pesterchum
//
//  Created by Antiscient on 10/8/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PesterUserViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *textEntry;

- (IBAction)pester:(id)sender;
- (IBAction)addChum:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;
@end
