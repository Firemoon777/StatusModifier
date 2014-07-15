
// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos

/*
 * Name: StatusModifier
 * Author: Vladimir Turov (Firemoon777)
 * Version: 3.0
 * Dependency: iOS7+, libstatusbar, preferenceloader, mobilesubstrate
 * Summary: Tweak replaces time in status bar with custom info.
 */

#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <sys/utsname.h>
#import <sys/types.h>
#import "libMobileGestalt.h"
#import "LSStatusBarItem.h"

#define PREFS_FILE @"/var/mobile/Library/Preferences/ru.firemoon777.StatusModifierLoader.plist"
#define GET_BOOL(PARAM) [[settings objectForKey:(PARAM)] boolValue]
#define CHECK_AND_SET(PARAM, VALUE) if(![settings objectForKey:(PARAM)]) [settings setObject:VALUE forKey:PARAM];

@interface SBStatusBarStateAggregator : NSObject

-(void)refreshMemory;

@end

unsigned SMFreeMemory;
NSMutableDictionary *settings;

// ======================================== //
// =============== Statusbar ============== //
// ======================================== //

%hook SBStatusBarStateAggregator

/*
 * Init method
 *
 * Summary: Init settings and etc.
 *
 */
-(id)init
{
    id result = %orig;
    
    if(result)
    {
        // Check and load settings file
        settings = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFS_FILE];
        if(!settings) settings = [[NSMutableDictionary alloc] init];
            
        CHECK_AND_SET(@"SMRAM", @NO)
        CHECK_AND_SET(@"SMRAMRefresh", @1.f)
        CHECK_AND_SET(@"SMTimeItem", @YES)
        CHECK_AND_SET(@"SMAirPlane", @YES)
        CHECK_AND_SET(@"SMSignalBar", @YES)
        CHECK_AND_SET(@"SMCarrier", @YES)
        CHECK_AND_SET(@"SMData", @YES)
        CHECK_AND_SET(@"SMBattery", @YES)
        CHECK_AND_SET(@"SMiPod5", @NO)
        CHECK_AND_SET(@"SMAlarm", @YES)
        CHECK_AND_SET(@"SMGeoItem", @YES)
        CHECK_AND_SET(@"SMShowBatteryOnCharge", @NO)
        CHECK_AND_SET(@"SMRotation", @YES)
        CHECK_AND_SET(@"SMMute", @YES)
        CHECK_AND_SET(@"SMDataSpinner", @YES)
        CHECK_AND_SET(@"SMDoNotDisturb", @YES);
        if([[settings objectForKey:@"SMTime"] isEqualToString:@""])
            [settings setObject:@"HH:mm" forKey:@"SMTime"];
            
        [settings writeToFile:PREFS_FILE atomically:YES];
        
        // Set timer for refreshing RAM info
        if(GET_BOOL(@"SMRAM"))
        {
            [NSTimer scheduledTimerWithTimeInterval:[[settings objectForKey:@"SMRAMRefresh"] floatValue]
                                             target:self
                                           selector:@selector(refreshMemory)
                                           userInfo:nil
                                            repeats:YES];
        }
    }
    
    return result;
}

/*
 * Refreshing time item in statusbar
 */
-(void)_updateTimeItems
{
    // Hook and change current dateFormatter
    NSDateFormatter* timeItemDateFormatter = MSHookIvar<NSDateFormatter*>(self, "_timeItemDateFormatter");
    
    // Setup custom date
    NSString *showTime = [settings objectForKey:@"SMTime"];
    
    // Add RAM info if necessary
    if(GET_BOOL(@"SMRAM"))
        showTime = [showTime stringByAppendingString:[NSString stringWithFormat:@" '%iMB'", SMFreeMemory]];
    [timeItemDateFormatter setDateFormat:showTime];
    
    %orig;
}

/*
 * Replace refresh rate.
 */
-(void)_restartTimeItemTimer
{
    %orig;
    
    NSTimer *timeItemTimer = MSHookIvar<NSTimer*>(self, "_timeItemTimer");
    [timeItemTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}

/*
 * Enable/disable items in statusbar
 *
 * iOS 7.1.2 iPad3,6
 * 00 - Time
 * 01 - Do not disturb
 * 02 - Airplane mode
 * 03 - Signal bar
 * 04 - Carrier
 * 05 - Wifi/LTE/3G
 * 06 - ???
 * 07 - Battery
 * 08 - Battery percentage
 * 09 - Battery percentage (???)
 * 10 - Headset battery
 * 11 - Bluetooth
 * 12 - TTY
 * 13 - Alarm
 * 14 - ???
 * 15 - ???
 * 16 - Geolocation Item
 * 17 - Rotation item
 * 18 - ???
 * 19 - AirPlay
 * 20 - Siri (???)
 * 21 - VPN
 * 22 - InCall
 * 23 - DataSpinner
 * 24 - Black item (???)
 *
 */
-(BOOL)_setItem:(int)item enabled:(BOOL)enabled
{
    if(item == 7 && GET_BOOL(@"SMShowBatteryOnCharge"))
    {
        CFPropertyListRef value = MGCopyAnswer(kMGBatteryIsCharging);
        if([[NSString stringWithFormat:@"%@",value] isEqualToString:@"1"])
        {
            CFRelease(value);
            return %orig(item, YES);
        }
    }
    if (item == 0  && !GET_BOOL(@"SMTimeItem"))     return %orig(item, NO);
    if (item == 1  && !GET_BOOL(@"SMDoNotDisturb")) return %orig(item, NO);
    if (item == 2  && !GET_BOOL(@"SMAirPlane"))     return %orig(item, NO);
    if (item == 3  && !GET_BOOL(@"SMSignalBar"))    return %orig(item, NO);
    if (item == 4  && !GET_BOOL(@"SMCarrier"))      return %orig(item, NO);
    if (item == 5  && !GET_BOOL(@"SMData"))         return %orig(item, NO);
    if (item == 7  && !GET_BOOL(@"SMBattery"))      return %orig(item, NO);
    if (item == 8  &&  GET_BOOL(@"SMiPod5"))        return %orig(item, YES);
    if (item == 13 && !GET_BOOL(@"SMAlarm"))        return %orig(item, NO);
    if (item == 16 && !GET_BOOL(@"SMGeoItem"))      return %orig(item, NO);
    if (item == 17 && !GET_BOOL(@"SMRotation"))     return %orig(item, NO);
    if (item == 23 && !GET_BOOL(@"SMDataSpinner"))  return %orig(item, NO);
    return %orig;
    
}

/*
 * Gets free RAM
 */
%new -(void)refreshMemory
{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
        NSLog(@"Failed to fetch vm statistics");
        
    /* Stats in bytes */
        natural_t mem_free = natural_t(vm_stat.free_count * pagesize);
        struct utsname systemInfo;
    uname(&systemInfo);
    NSString *pl = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    // Fix for arm64 devices
    if ([pl isEqualToString:@"iPhone6,1"] ||
        [pl isEqualToString:@"iPhone6,2"] ||
        [pl isEqualToString:@"iPad4,1"]   ||
        [pl isEqualToString:@"iPad4,2"]   ||
        [pl isEqualToString:@"iPad4,4"]   ||
        [pl isEqualToString:@"iPad4,5"])
    {
        mem_free = mem_free / 4;
    }
    SMFreeMemory = mem_free / 1024 / 1024;
}

%end

// ======================================== //
// ============== SpringBoard ============= //
// ======================================== //

%hook SpringBoard

BOOL SBMute;
LSStatusBarItem *mute;

-(void)_updateRingerState:(int)state withVisuals:(BOOL)visuals updatePreferenceRegister:(BOOL)aRegister
{
    %orig;
    if(SBMute) mute.visible = !state;
}

-(void)applicationDidFinishLaunching:(id)application
{
    %orig;
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:PREFS_FILE];
    SBMute = [[data objectForKey:@"SMMute"] boolValue];
    mute = [[LSStatusBarItem alloc] initWithIdentifier: @"statusmodifier.mute" alignment: StatusBarAlignmentRight];
    mute.imageName = @"mute";
    int ringerSwitchState = MSHookIvar<int>(self, "_ringerSwitchState");
    mute.visible = (SBMute && !ringerSwitchState);
    [data release];
}
%end