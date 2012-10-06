//
//  SSTAppDelegate.h
//  Pesterchum
//
//  Created by Michael Colvin on 9/14/12.
//  Copyright (c) 2012 Systech Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRCConnection.h"
#import "ChumrollViewController.h"
#import "PesterlistViewController.h"

@interface PesterphoneAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *activeChat;
@property (strong, nonatomic) IRCConnection *connection;
@property (strong, nonatomic) ChumrollViewController *chumroll;
@property (strong, nonatomic) PesterlistViewController *pesterlist;

@end