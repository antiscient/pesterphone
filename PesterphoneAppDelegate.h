//
//  SSTAppDelegate.h
//  Pesterchum
//
//  Created by Antiscient on 9/14/12.
//  Copyright (c) 2012 Systech Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRCConnection.h"
#import "ChumrollViewController.h"
#import "PesterlistViewController.h"
#import "MemoViewController.h"

@interface PesterphoneAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Chat *activeChat;
@property (strong, nonatomic) IRCConnection *connection;
@property (weak, nonatomic) ChumrollViewController *chumroll;
@property (weak, nonatomic) PesterlistViewController *pesterlist;
@property (weak, nonatomic) MemoViewController *memoView;
@property (strong, nonatomic) NSMutableArray *memoList;
@property (strong, nonatomic) NSMutableDictionary *chatList;
@property (strong, nonatomic) NSString *myColor;

@end
