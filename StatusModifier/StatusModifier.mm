#line 1 "/Users/admin/Dropbox/Проекты/StatusModifier/StatusModifier/StatusModifier.xm"












#import <mach/mach.h>
#import <sys/types.h>
#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import <mach/mach_host.h>
#import "LSStatusBarItem.h"
#import "libMobileGestalt.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#define PREFS_FILE @"/var/mobile/Library/Preferences/ru.firemoon777.StatusModifierLoader.plist"
#define GET_BOOL(PARAM) [[settings objectForKey:(PARAM)] boolValue]
#define CHECK_AND_SET(PARAM, VALUE) if(![settings objectForKey:(PARAM)]) [settings setObject:VALUE forKey:PARAM];

@interface SBStatusBarStateAggregator : NSObject

-(void)refreshMemory;
-(void)updateLocalIP;

@end

unsigned SMFreeMemory;
NSMutableDictionary *settings;
NSArray *localIP;





#include <logos/logos.h>
#include <substrate.h>
@class SBCCSettingsSectionController; @class SBStatusBarStateAggregator; @class SBMediaController; 
static id (*_logos_orig$_ungrouped$SBStatusBarStateAggregator$init)(SBStatusBarStateAggregator*, SEL); static id _logos_method$_ungrouped$SBStatusBarStateAggregator$init(SBStatusBarStateAggregator*, SEL); static void (*_logos_orig$_ungrouped$SBStatusBarStateAggregator$_updateTimeItems)(SBStatusBarStateAggregator*, SEL); static void _logos_method$_ungrouped$SBStatusBarStateAggregator$_updateTimeItems(SBStatusBarStateAggregator*, SEL); static void (*_logos_orig$_ungrouped$SBStatusBarStateAggregator$_restartTimeItemTimer)(SBStatusBarStateAggregator*, SEL); static void _logos_method$_ungrouped$SBStatusBarStateAggregator$_restartTimeItemTimer(SBStatusBarStateAggregator*, SEL); static BOOL (*_logos_orig$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$)(SBStatusBarStateAggregator*, SEL, int, BOOL); static BOOL _logos_method$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$(SBStatusBarStateAggregator*, SEL, int, BOOL); static void _logos_method$_ungrouped$SBStatusBarStateAggregator$refreshMemory(SBStatusBarStateAggregator*, SEL); static void _logos_method$_ungrouped$SBStatusBarStateAggregator$updateLocalIP(SBStatusBarStateAggregator*, SEL); static id (*_logos_orig$_ungrouped$SBMediaController$init)(SBMediaController*, SEL); static id _logos_method$_ungrouped$SBMediaController$init(SBMediaController*, SEL); static void (*_logos_orig$_ungrouped$SBCCSettingsSectionController$_setMuted$)(SBCCSettingsSectionController*, SEL, _Bool); static void _logos_method$_ungrouped$SBCCSettingsSectionController$_setMuted$(SBCCSettingsSectionController*, SEL, _Bool); 

#line 42 "/Users/admin/Dropbox/Проекты/StatusModifier/StatusModifier/StatusModifier.xm"









static id _logos_method$_ungrouped$SBStatusBarStateAggregator$init(SBStatusBarStateAggregator* self, SEL _cmd) {
    id result = _logos_orig$_ungrouped$SBStatusBarStateAggregator$init(self, _cmd);
    
    if(result)
    {
        
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
        CHECK_AND_SET(@"SMDoNotDisturb", @YES)
        CHECK_AND_SET(@"SMLocalIP", @NO)
            
        if([[settings objectForKey:@"SMTime"] isEqualToString:@""])
            [settings setObject:@"HH:mm" forKey:@"SMTime"];
            
        [settings writeToFile:PREFS_FILE atomically:YES];
        
        
        if(GET_BOOL(@"SMRAM"))
        {
            [NSTimer scheduledTimerWithTimeInterval:[[settings objectForKey:@"SMRAMRefresh"] floatValue]
                                             target:self
                                           selector:@selector(refreshMemory)
                                           userInfo:nil
                                            repeats:YES];
        }
        if(GET_BOOL(@"SMLocalIP"))
        {
            [self updateLocalIP];
            [NSTimer scheduledTimerWithTimeInterval:10*60 target:self selector:@selector(updateLocalIP) userInfo:nil repeats:YES];
        }
    }
    
    return result;
}





static void _logos_method$_ungrouped$SBStatusBarStateAggregator$_updateTimeItems(SBStatusBarStateAggregator* self, SEL _cmd) {
    
    NSDateFormatter* timeItemDateFormatter = MSHookIvar<NSDateFormatter*>(self, "_timeItemDateFormatter");
    
    
    NSString *showTime = [settings objectForKey:@"SMTime"];
    
    
    if(GET_BOOL(@"SMLocalIP"))
        showTime = [showTime stringByAppendingString:[NSString stringWithFormat:@" '%@'", [settings objectForKey:@"LocalIP"]]];
    
    
    if(GET_BOOL(@"SMRAM"))
        showTime = [showTime stringByAppendingString:[NSString stringWithFormat:@" '%iMB'", SMFreeMemory]];
    
    [timeItemDateFormatter setDateFormat:showTime];
    
    _logos_orig$_ungrouped$SBStatusBarStateAggregator$_updateTimeItems(self, _cmd);
}





static void _logos_method$_ungrouped$SBStatusBarStateAggregator$_restartTimeItemTimer(SBStatusBarStateAggregator* self, SEL _cmd) {
    _logos_orig$_ungrouped$SBStatusBarStateAggregator$_restartTimeItemTimer(self, _cmd);
    
    NSTimer *timeItemTimer = MSHookIvar<NSTimer*>(self, "_timeItemTimer");
    [timeItemTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}

































static BOOL _logos_method$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$(SBStatusBarStateAggregator* self, SEL _cmd, int item, BOOL enabled) {
    if(item == 7 && GET_BOOL(@"SMShowBatteryOnCharge"))
    {
        CFPropertyListRef value = MGCopyAnswer(kMGBatteryIsCharging);
        if([[NSString stringWithFormat:@"%@",value] isEqualToString:@"1"])
        {
            CFRelease(value);
            return _logos_orig$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$(self, _cmd, item, YES);
        }
    }
    if (item == 0  && !GET_BOOL(@"SMTimeItem"))     return _logos_orig$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$(self, _cmd, item, NO);
    if (item == 1  && !GET_BOOL(@"SMDoNotDisturb")) return _logos_orig$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$(self, _cmd, item, NO);
    if (item == 2  && !GET_BOOL(@"SMAirPlane"))     return _logos_orig$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$(self, _cmd, item, NO);
    if (item == 3  && !GET_BOOL(@"SMSignalBar"))    return _logos_orig$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$(self, _cmd, item, NO);
    if (item == 4  && !GET_BOOL(@"SMCarrier"))      return _logos_orig$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$(self, _cmd, item, NO);
    if (item == 5  && !GET_BOOL(@"SMData"))         return _logos_orig$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$(self, _cmd, item, NO);
    if (item == 7  && !GET_BOOL(@"SMBattery"))      return _logos_orig$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$(self, _cmd, item, NO);
    if (item == 8  &&  GET_BOOL(@"SMiPod5"))        return _logos_orig$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$(self, _cmd, item, YES);
    if (item == 13 && !GET_BOOL(@"SMAlarm"))        return _logos_orig$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$(self, _cmd, item, NO);
    if (item == 16 && !GET_BOOL(@"SMGeoItem"))      return _logos_orig$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$(self, _cmd, item, NO);
    if (item == 17 && !GET_BOOL(@"SMRotation"))     return _logos_orig$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$(self, _cmd, item, NO);
    if (item == 23 && !GET_BOOL(@"SMDataSpinner"))  return _logos_orig$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$(self, _cmd, item, NO);
    return _logos_orig$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$(self, _cmd, item, enabled);
    
}





 static void _logos_method$_ungrouped$SBStatusBarStateAggregator$refreshMemory(SBStatusBarStateAggregator* self, SEL _cmd) {
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
        NSLog(@"Failed to fetch vm statistics");
        
    
        natural_t mem_free = natural_t(vm_stat.free_count * pagesize);
        struct utsname systemInfo;
    uname(&systemInfo);
    NSString *pl = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    
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


 static void _logos_method$_ungrouped$SBStatusBarStateAggregator$updateLocalIP(SBStatusBarStateAggregator* self, SEL _cmd) {
    [settings setObject:[[[NSHost currentHost] addresses] objectAtIndex:1] forKey:@"LocalIP"];
}






BOOL SBMute;
LSStatusBarItem *mute;












static id _logos_method$_ungrouped$SBMediaController$init(SBMediaController* self, SEL _cmd) {
    id result = _logos_orig$_ungrouped$SBMediaController$init(self, _cmd);
    if(result)
    {
        NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:PREFS_FILE];
        SBMute = [[data objectForKey:@"SMMute"] boolValue];
        mute = [[LSStatusBarItem alloc] initWithIdentifier: @"statusmodifier.mute" alignment: StatusBarAlignmentRight];
        mute.imageName = @"mute";
        bool ringerSwitchState = MSHookIvar<bool>(self, "_ringerMuted");
        mute.visible = (SBMute && !ringerSwitchState);
        [data release];
    }
    return result;
}




static void _logos_method$_ungrouped$SBCCSettingsSectionController$_setMuted$(SBCCSettingsSectionController* self, SEL _cmd, _Bool arg1) {
    mute.visible = arg1;
}

static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBStatusBarStateAggregator = objc_getClass("SBStatusBarStateAggregator"); MSHookMessageEx(_logos_class$_ungrouped$SBStatusBarStateAggregator, @selector(init), (IMP)&_logos_method$_ungrouped$SBStatusBarStateAggregator$init, (IMP*)&_logos_orig$_ungrouped$SBStatusBarStateAggregator$init);MSHookMessageEx(_logos_class$_ungrouped$SBStatusBarStateAggregator, @selector(_updateTimeItems), (IMP)&_logos_method$_ungrouped$SBStatusBarStateAggregator$_updateTimeItems, (IMP*)&_logos_orig$_ungrouped$SBStatusBarStateAggregator$_updateTimeItems);MSHookMessageEx(_logos_class$_ungrouped$SBStatusBarStateAggregator, @selector(_restartTimeItemTimer), (IMP)&_logos_method$_ungrouped$SBStatusBarStateAggregator$_restartTimeItemTimer, (IMP*)&_logos_orig$_ungrouped$SBStatusBarStateAggregator$_restartTimeItemTimer);MSHookMessageEx(_logos_class$_ungrouped$SBStatusBarStateAggregator, @selector(_setItem:enabled:), (IMP)&_logos_method$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$, (IMP*)&_logos_orig$_ungrouped$SBStatusBarStateAggregator$_setItem$enabled$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBStatusBarStateAggregator, @selector(refreshMemory), (IMP)&_logos_method$_ungrouped$SBStatusBarStateAggregator$refreshMemory, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBStatusBarStateAggregator, @selector(updateLocalIP), (IMP)&_logos_method$_ungrouped$SBStatusBarStateAggregator$updateLocalIP, _typeEncoding); }Class _logos_class$_ungrouped$SBMediaController = objc_getClass("SBMediaController"); MSHookMessageEx(_logos_class$_ungrouped$SBMediaController, @selector(init), (IMP)&_logos_method$_ungrouped$SBMediaController$init, (IMP*)&_logos_orig$_ungrouped$SBMediaController$init);Class _logos_class$_ungrouped$SBCCSettingsSectionController = objc_getClass("SBCCSettingsSectionController"); MSHookMessageEx(_logos_class$_ungrouped$SBCCSettingsSectionController, @selector(_setMuted:), (IMP)&_logos_method$_ungrouped$SBCCSettingsSectionController$_setMuted$, (IMP*)&_logos_orig$_ungrouped$SBCCSettingsSectionController$_setMuted$);} }
#line 278 "/Users/admin/Dropbox/Проекты/StatusModifier/StatusModifier/StatusModifier.xm"
