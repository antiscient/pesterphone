//
//  ChatViewController.h
//  Pesterchum
//
//  Created by Antiscient on 9/14/12.
//  Copyright (c) 2012 Systech Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRCConnection.h"

@interface ChatViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *chatBarField;
@property (weak, nonatomic) IBOutlet UIWebView *chatTextView;
@property (weak, nonatomic) IBOutlet UILabel *borderLabel;
@property (strong, nonatomic) IRCConnection *connection;
@property (strong, nonatomic) NSString *name;

- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)sendMsg:(id)sender;
- (void)setConnection:(IRCConnection *)connection;

@end
