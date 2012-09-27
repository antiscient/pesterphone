//
//  ChatViewController.m
//  Pesterchum
//
//  Created by Michael Colvin on 9/14/12.
//  Copyright (c) 2012 Systech Studios. All rights reserved.
//

#import "ChatViewController.h"
#import "IRCConnection.h"

@interface ChatViewController ()

@end

@implementation ChatViewController
@synthesize chatBarField;
@synthesize chatTextView;
@synthesize connection;

- (IBAction)dismissKeyboard:(id)sender
{
    [chatBarField resignFirstResponder];
}

- (IBAction)sendMsg:(id)sender
{
    if( chatBarField.text.length > 0 )
    {
        [connection sendMsg:[NSString stringWithFormat:@"%@: %@", [connection initials], chatBarField.text] to:@"#General_Chat"];
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
    CGRect bkgndRect = self.view.frame;
    bkgndRect.size.height -= kbSize.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.15f ];
    [self.view setFrame:bkgndRect];
    [UIView commitAnimations];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    // NSLog(@"Typing has ended.");
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect bkgndRect = self.view.frame;
    bkgndRect.origin.y += kbSize.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.2f ];
    [self.view setFrame:bkgndRect];
    [UIView commitAnimations];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
	// Do any additional setup after loading the view.
    [chatTextView setDelegate:self];
    
    connection.chatBox = chatTextView;
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
