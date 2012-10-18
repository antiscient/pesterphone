//
//  PesterUserViewController.m
//  Pesterchum
//
//  Created by Antiscient on 10/8/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import "PesterUserViewController.h"
#import "PesterphoneAppDelegate.h"

@implementation PesterUserViewController
@synthesize textEntry;

- (IBAction)pester:(id)sender
{
    if( [textEntry.text length] < 2 )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Chumhandle Too Short" message:@"Try adding a real chumhandle." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if( [[IRCConnection getInitials:textEntry.text] length] != 2 )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not a Chumhandle" message:@"Make sure you use a real chumhandle, with exactly one capital letter and no spaces,\nlikeThis" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //
    // Open new chat here...
    //
    NSString *chum = textEntry.text;
    Chat *newChat;
    
    for( NSString* key in [appDelegate.chatList allKeys] )
    {
        if( [[((Chat *)[appDelegate.chatList valueForKey:key]).name lowercaseString] isEqualToString:[chum lowercaseString]]  )
        {
            newChat = [appDelegate.chatList valueForKey:key];
            chum = ((Chat*)[appDelegate.chatList valueForKey:key]).name;
            break;
        }
    }
    
    if( !newChat )
    {
        newChat = [[Chat alloc] initWithName:chum];
        [newChat addChum:chum withMood:0];
    }
    
    appDelegate.activeChat = newChat;
    [appDelegate.chatList setValue:newChat forKey:chum];
    
    [(id)[(UINavigationController*)[self presentingViewController] topViewController] startChat];
}

- (IBAction)addChum:(id)sender
{
    if( [textEntry.text length] < 2 )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Chumhandle Too Short" message:@"Try adding a real chumhandle." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if( [[IRCConnection getInitials:textEntry.text] length] != 2 )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not a Chumhandle" message:@"Make sure you use a real chumhandle, with exactly one capital letter and no spaces,\nlikeThis" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if( ![appDelegate.chumroll addChum:textEntry.text] )
    {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSMutableArray *chums = [[prefs arrayForKey:@"chumlistArray"] mutableCopy];
        NSString *chum = @"NOHANDLE";
        
        for( chum in chums )
        {
            if( [[chum lowercaseString] isEqualToString:[textEntry.text lowercaseString]] )
            {
                break;
            }
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already On Chumroll" message:[NSString stringWithFormat:@"%@ is already your chum.", chum] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self goBack:self];
}

- (IBAction)goBack:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)dismissKeyboard:(id)sender
{
    [textEntry resignFirstResponder];
}

- (void)viewDidUnload
{
    [self setTextEntry:nil];
    [super viewDidUnload];
}
@end
