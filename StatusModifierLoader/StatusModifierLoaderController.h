//
//  StatusModifierLoaderController.h
//  StatusModifierLoader
//
//  Created by admin on 10.07.14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>
#import <MessageUI/MessageUI.h>

@interface StatusModifierLoaderController : PSListController <UIAlertViewDelegate, MFMessageComposeViewControllerDelegate>
{
}

- (id)getValueForSpecifier:(PSSpecifier*)specifier;
- (void)setValue:(id)value forSpecifier:(PSSpecifier*)specifier;
- (void)followOnTwitter:(PSSpecifier*)specifier;
- (void)donate:(PSSpecifier*)specifier;
- (void)writeMessage:(PSSpecifier*)specifier;
- (void)openGitHub:(PSSpecifier*)specifier;

@end