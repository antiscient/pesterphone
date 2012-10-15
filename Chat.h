//
//  Chat.h
//  Pesterchum
//
//  Created by Hanzilla on 10/7/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChatViewController;
@interface Chat : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableString *HTMLlog;
@property (strong, nonatomic) NSMutableDictionary *chatMoodList;
@property (strong, nonatomic) NSString *chatColor;
@property Boolean isOpen;
@property Boolean isMemo;
@property (weak, nonatomic) ChatViewController *controller;

- (id)initWithName:(NSString*)newName;
- (void)addChum:(NSString*)chum withMood:(NSString*)mood;
- (void)printToChat:(NSString *)msg;

@end
