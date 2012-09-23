//
//  SSTViewController.m
//  Pesterchum
//
//  Created by Michael Colvin on 9/14/12.
//  Copyright (c) 2012 Systech Studios. All rights reserved.
//

#import "LoginViewController.h"
#import "ChatViewController.h"
#import "IRCConnection.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation LoginViewController
@synthesize chumhandleText;
@synthesize username;
@synthesize password;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"LoginSegue"])
	{
		ChatViewController *chatController = segue.destinationViewController;
        
        IRCConnection *ircConn = [[IRCConnection alloc] init];
        if( chumhandleText.text.length > 0 )
            [ircConn setHandle: chumhandleText.text];
        else
            [ircConn setHandle: [NSString stringWithFormat:@"pesterClient%d", arc4random_uniform(999)]];
        
        //[chatController setConnection: ircConn];
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
