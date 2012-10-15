//
//  ChatViewController.m
//  Pesterchum
//
//  Created by Antiscient on 9/14/12.
//  Copyright (c) 2012 Systech Studios. All rights reserved.
//

#import "ChatViewController.h"
#import "IRCConnection.h"
#import "PesterphoneAppDelegate.h"

@interface ChatViewController ()

@end

@implementation ChatViewController
@synthesize menuContainer;
@synthesize chatBarField;
@synthesize chatTextView;
@synthesize borderLabel;
@synthesize chatBorderLabel;
@synthesize backgroundLabel;
@synthesize connection;
@synthesize chat;
@synthesize menuController;

- (IBAction)dismissKeyboard:(id)sender
{
    [chatBarField resignFirstResponder];
}

- (IBAction)sendMsg:(id)sender
{
    if( chatBarField.text.length > 0 )
    {
        [connection sendMsg:chatBarField.text to:chat.name];
        chatBarField.text = @"";
    }
    [self dismissKeyboard:sender];
}

-(BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    [self dismissKeyboard:self];
    return NO;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    // NSLog(@"Typing has begun!");
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect bkgndRect = self.navigationController.topViewController.view.frame;
    bkgndRect.size.height -= kbSize.height;
    
    CGRect chatBarRect = chatBarField.frame;
    chatBarRect.origin.y -= kbSize.height;
    chatBarRect.size.width = 290;
    
    CGRect chatViewRect = chatTextView.frame;
    chatViewRect.size.height -= kbSize.height;
    
    CGRect borderRect = borderLabel.frame;
    borderRect.size.height -= kbSize.height;
    
    CGRect chatBorderRect = chatBorderLabel.frame;
    chatBorderRect.origin.y -= kbSize.height;
    chatBorderRect.size.width = 293;
    
    CGRect bgRect = backgroundLabel.frame;
    bgRect.size.height -= kbSize.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.02f ];
    [chatBarField setFrame:chatBarRect];
    [chatBorderLabel setFrame:chatBorderRect];
    [borderLabel setFrame:borderRect];
    [chatTextView setFrame:chatViewRect];
    [backgroundLabel setFrame:bgRect];
    [UIView setAnimationDuration: 0.15f ];
    [self.navigationController.topViewController.view setFrame:bkgndRect];
    [UIView commitAnimations];
    
    NSInteger height = [[chatTextView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
    NSString* javascript = [NSString stringWithFormat:@"window.scrollBy(0, %d);", height];
    [chatTextView stringByEvaluatingJavaScriptFromString:javascript];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    // NSLog(@"Typing has ended.");
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect bkgndRect = self.navigationController.topViewController.view.frame;
    bkgndRect.size.height += kbSize.height;
    
    CGRect chatBarRect = chatBarField.frame;
    chatBarRect.origin.y += kbSize.height;
    chatBarRect.size.width = 200;
    
    CGRect chatViewRect = chatTextView.frame;
    chatViewRect.size.height += kbSize.height;
    
    CGRect borderRect = borderLabel.frame;
    borderRect.size.height += kbSize.height;
    
    CGRect chatBorderRect = chatBorderLabel.frame;
    chatBorderRect.origin.y += kbSize.height;
    chatBorderRect.size.width = 203;
    
    CGRect bgRect = backgroundLabel.frame;
    bgRect.size.height += kbSize.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.2f ];
    [self.navigationController.topViewController.view setFrame:bkgndRect];
    [chatTextView setFrame:chatViewRect];
    [chatBarField setFrame:chatBarRect];
    [borderLabel setFrame:borderRect];
    [chatBorderLabel setFrame:chatBorderRect];
    [backgroundLabel setFrame:bgRect];
    [UIView commitAnimations];
    
    NSInteger height = [[chatTextView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
    NSString* javascript = [NSString stringWithFormat:@"window.scrollBy(0, %d);", height];
    [chatTextView stringByEvaluatingJavaScriptFromString:javascript];
}

- (void) navBarTap
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You tapped the bar!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
	// Do any additional setup after loading the view.
    [chatTextView setDelegate:self];
    
    if ([[chatTextView subviews] count] > 0) {
        // hide the shadows
        for (UIView* shadowView in [[[chatTextView subviews] objectAtIndex:0] subviews]) {
            [shadowView setHidden:YES];
        }
        // show the content
        [[[[[chatTextView subviews] objectAtIndex:0] subviews] lastObject] setHidden:NO];
    }
    chatTextView.backgroundColor = [UIColor whiteColor];
    
    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    connection = appDelegate.connection;
    chat = appDelegate.activeChat;
    chat.controller = self;
    
    // get current date/time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *beginPesterString = @"";
    NSString *startText = appDelegate.activeChat.HTMLlog;
    
    if( !chat.isOpen )
    {
        NSString *verb = @"began pestering";
        NSString *chatInitials = @" ";
        NSString *chatName = chat.name;
        if( chat.isMemo )
        {
            [connection dataSending:[NSString stringWithFormat:@"JOIN %@\n", chat.name]];
            [connection sendMsg:@"PESTERCHUM:TIME>i" to:chat.name];
            verb = @"opened memo on board";
            chatName = [[[chatName substringFromIndex:1] stringByReplacingOccurrencesOfString:@"_" withString:@" "] uppercaseString];
        }
        else
        {
            [connection sendMsg:@"PESTERCHUM:BEGIN" to:chat.name];
            [connection sendMsg:[NSString stringWithFormat:@"COLOR >%@", appDelegate.myColor] to:chat.name];
            chatInitials = [NSString stringWithFormat:@" [%@]", [IRCConnection getInitials:chat.name]];
        }
        
        chat.isOpen = true;
        NSLog( @"Chat is now open." );
        beginPesterString = [NSString stringWithFormat:@"<span style=\"color:rgb(100,100,100)\">-- %@ <span style=\"color:rgb(%@)\">[%@]</span> %@ %@<span style=\"color:rgb(%@)\">%@</span> at %@ --</span><br/>",
                             [connection handle], appDelegate.myColor, [connection initials], verb, chatName, chat.chatColor, chatInitials, currentTime];
        startText = [startText stringByReplacingOccurrencesOfString:@"</body>" withString:[NSString stringWithFormat:@"%@</body>", beginPesterString] ];
    }
    
    appDelegate.activeChat.HTMLlog = [startText mutableCopy];
    
    [chatTextView loadHTMLString:startText baseURL:nil];
    
    
    self.menuController = (ChatMenuViewController*)[self.childViewControllers lastObject];
    menuController.parent = self;
    
    self.navigationItem.title = chat.name;
    
    /*UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navBarTap)];
    tap.numberOfTapsRequired = 1;*/
    
    [[self.navigationController.navigationBar.subviews objectAtIndex:1] setUserInteractionEnabled:YES];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewDidUnload
{
    [self setChatBarField:nil];
    [self setChatTextView:nil];
    [self setBorderLabel:nil];
    [self setBorderLabel:nil];
    [self setBackgroundLabel:nil];
    [self setChatBorderLabel:nil];
    [self setMenuContainer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
