//
//  IRCConnection.h
//  Pesterchum
//
//  Created by Michael Colvin on 9/15/12.
//  Copyright (c) 2012 Systech Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRCConnection : NSObject <NSStreamDelegate>
{
    NSInputStream * inputStream;
    NSOutputStream * outputStream;
    
    Boolean loggedIn;
    Boolean loggingIn;
    
    NSString *myHandle;
    NSString *myInitials;
}
@property (weak, nonatomic) UITextView *chatBox;

- (void) startWithURL:(NSString*) urlStr;
- (void) sendMsg:(NSString*)msg to:(NSString*)target;
- (void) printToChat:(NSString*)msg;
- (void) setHandle:(NSString*)name;
- (NSString*) initials;

+ (NSString*) getInitials:(NSString*)name;

@end
