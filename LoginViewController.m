//
//  LoginViewController.m
//  Pesterchum
//
//  Created by Michael Colvin on 9/14/12.
//  Copyright (c) 2012 Systech Studios. All rights reserved.
//

#import "LoginViewController.h"
#import "ChatViewController.h"
#import "IRCConnection.h"
#import "PesterphoneAppDelegate.h"
#import "ChumrollViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation LoginViewController
@synthesize chumhandleText;
@synthesize username;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"LoginSegue"])
	{
		ChumrollViewController *newController = segue.destinationViewController;
        
        IRCConnection *ircConn = [[IRCConnection alloc] init];
        PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
        if( chumhandleText.text.length > 0 )
        {
            [ircConn setHandle: chumhandleText.text];
            [newController setHandle:chumhandleText.text];
        }
        else
        {
            NSString *handle = [NSString stringWithFormat:@"pesterClient%d", arc4random_uniform(999)];
            [ircConn setHandle: handle];
            [newController setHandle:handle];
        }
        
        appDelegate.connection = ircConn;
        NSString *urlStr = @"http://irc.mindfang.org";
        [ircConn startWithURL:urlStr];
        
	}
}


- (IBAction)dismissKeyboard:(id)sender
{
    [chumhandleText resignFirstResponder];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // saving an NSString
    [prefs setObject:chumhandleText.text forKey:@"defaultHandle"];
    [prefs synchronize];
    // NSLog(@"Saving \"%@\" as handle...", [prefs stringForKey:@"defaultHandle"]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // getting an NSString
    chumhandleText.text = [prefs stringForKey:@"defaultHandle"];
}

- (void)viewDidUnload
{
    [self setUsername:nil];
    [self setPassword:nil];
    [self setChumhandleText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
