//
//  StatusModifierLoaderController.m
//  StatusModifierLoader
//
//  Created by admin on 10.07.14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "StatusModifierLoaderController.h"
#import <Preferences/PSSpecifier.h>


#define kUrl_FollowOnTwitter @"https://twitter.com/Firemoon777"
#define kUrl_MakeDonation @"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=VFJFK2YFSYYW6"

#define kPrefs_Path @"/var/mobile/Library/Preferences"
#define kPrefs_KeyName_Key @"key"
#define kPrefs_KeyName_Defaults @"defaults"

@implementation StatusModifierLoaderController

- (id)getValueForSpecifier:(PSSpecifier*)specifier
{
	id value = nil;
    
	NSDictionary *specifierProperties = [specifier properties];
	NSString *specifierKey = [specifierProperties objectForKey:kPrefs_KeyName_Key];
    
	// get 'value' from 'defaults' plist (if 'defaults' key and file exists)
    NSMutableString *plistPath = [[NSMutableString alloc] initWithString:[specifierProperties objectForKey:kPrefs_KeyName_Defaults]];
    #if ! __has_feature(objc_arc)
    plistPath = [plistPath autorelease];
    #endif
    if (plistPath)
    {
        NSDictionary *dict = (NSDictionary*)[self initDictionaryWithFile:&plistPath asMutable:NO];
			
        id objectValue = [dict objectForKey:specifierKey];
			
        if (objectValue)
        {
            value = [NSString stringWithFormat:@"%@", objectValue];
            NSLog(@"read key '%@' with value '%@' from plist '%@'", specifierKey, value, plistPath);
        }
        else
        {
            NSLog(@"key '%@' not found in plist '%@'", specifierKey, plistPath);
        }
			
        #if ! __has_feature(objc_arc)
        [dict release];
        #endif
	}
	
	return value;
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier*)specifier;
{
	NSDictionary *specifierProperties = [specifier properties];
	NSString *specifierKey = [specifierProperties objectForKey:kPrefs_KeyName_Key];

    // save 'value' to 'defaults' plist (if 'defaults' key exists)
    NSMutableString *plistPath = [[NSMutableString alloc] initWithString:[specifierProperties objectForKey:kPrefs_KeyName_Defaults]];
    #if ! __has_feature(objc_arc)
    plistPath = [plistPath autorelease];
    #endif
    if (plistPath)
    {
        NSMutableDictionary *dict = (NSMutableDictionary*)[self initDictionaryWithFile:&plistPath asMutable:YES];
        [dict setObject:value forKey:specifierKey];
        [dict writeToFile:plistPath atomically:YES];
        #if ! __has_feature(objc_arc)
        [dict release];
        #endif

        NSLog(@"saved key '%@' with value '%@' to plist '%@'", specifierKey, value, plistPath);
    }
    if([specifierKey isEqualToString:@"SMTime"])
        [self reloadSpecifiers];
}

- (id)initDictionaryWithFile:(NSMutableString**)plistPath asMutable:(BOOL)asMutable
{
	if ([*plistPath hasPrefix:@"/"])
		*plistPath = [NSString stringWithFormat:@"%@.plist", *plistPath];
	else
		*plistPath = [NSString stringWithFormat:@"%@/%@.plist", kPrefs_Path, *plistPath];
	
	Class class;
	if (asMutable)
		class = [NSMutableDictionary class];
	else
		class = [NSDictionary class];
	
	id dict;	
	if ([[NSFileManager defaultManager] fileExistsAtPath:*plistPath])
		dict = [[class alloc] initWithContentsOfFile:*plistPath];	
	else
		dict = [[class alloc] init];
	
	return dict;
}

- (void)followOnTwitter:(PSSpecifier*)specifier
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_FollowOnTwitter]];
}

- (void)donate:(PSSpecifier *)specifier
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_MakeDonation]];
}
- (void)info:(PSSpecifier *)spec
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.unicode.org/reports/tr35/tr35-25.html#Date_Format_Patterns"]];
}

- (void)openGitHub:(PSSpecifier*)specifier
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/Firemoon777/StatusModifier"]];
}

- (void)writeMessage:(PSSpecifier *)specifier
{
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"firemoon@icloud.com"];
    
    MFMessageComposeViewController *mc = [[MFMessageComposeViewController alloc] init];
    mc.messageComposeDelegate = self;
    [mc setRecipients:toRecipents];
    [mc setBody:@"Thanks for StatusModifier, Firemoon!\n"];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)respring:(PSSpecifier*)specifier
{
    [[super view] endEditing:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saved!"
                                                    message:@"Would you like to respring?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert setTag:666];
    [alert show];
    [alert release];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    UIBarButtonItem *hideKBBtn = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Save" style:UIBarButtonItemStyleBordered
                                  target:self action:@selector(respring:)];
	((UINavigationItem *)[super navigationItem]).rightBarButtonItem = hideKBBtn;
	[hideKBBtn release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 666 && alertView.cancelButtonIndex != buttonIndex)
    {
        system("killall SpringBoard");
    }
}

- (id)specifiers
{
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"StatusModifierLoader" target:self];
		#if ! __has_feature(objc_arc)
		[_specifiers retain];
		#endif
	}
	
	return _specifiers;
}

- (id)init
{
	if ((self = [super init]))
	{
	}
	
	return self;
}

#if ! __has_feature(objc_arc)
- (void)dealloc
{
	[super dealloc];
}
#endif

@end