//
//  AppDelegate.m
//  CrowdCrunch
//
//  Created by HackReactor on 11/10/14.
//  Copyright (c) 2014 HackReactor. All rights reserved.
//

#import "AppDelegate.h"
#import <IOKit/ps/IOPowerSources.h>
#import "SettingsViewController.h"


@interface AppDelegate (){
    NSString *path;
    NSMutableDictionary *data;
    SettingsViewController *settingsVC;
    
    int batteryThreshold;
    bool run_vm_on_battery;
    bool run_only_during_hours;
    bool run_only_during_days;
    
    int run_start_hour;
    int run_end_hour;
    
    int run_start_minutes;
    int run_end_minutes;
    
    NSString *run_start_AMPM;
    NSString *run_end_AMPM;
    
    NSDictionary *run_only_on_these_days;
    
    NSTask *startVM;
    NSTask *stopVM;
}

@end

@implementation AppDelegate

-(void)startVM{
    startVM = [[NSTask alloc] init];
    [startVM setLaunchPath:@"/bin/bash"];
    [startVM setArguments:[NSArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"startVM" ofType:@"sh"], nil]];
    [startVM launch];
}

-(void)stopVM{
    stopVM = [[NSTask alloc] init];
    [stopVM setLaunchPath:@"/bin/bash"];
    [stopVM setArguments:[NSArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"stopVM" ofType:@"sh"], nil]];
    [stopVM launch];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self getSettingsPlist];
    
    //run a bash script call startDocker in the Resources folder (wherever that is)
//    NSTask *task = [[NSTask alloc] init];
//    [task setLaunchPath:@"/bin/bash"];
//    [task setArguments:[NSArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"startDocker" ofType:@"sh"], nil]];
//    [task launch];
//    [self initializePowerSourceChanges];
    
    //Load scripts that start and stop the vm
    startVM = [[NSTask alloc] init];
    [startVM setLaunchPath:@"/bin/bash"];
    [startVM setArguments:[NSArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"startVM" ofType:@"sh"], nil]];
    
    stopVM = [[NSTask alloc] init];
    [stopVM setLaunchPath:@"/bin/bash"];
    [stopVM setArguments:[NSArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"stopVM" ofType:@"sh"], nil]];
    
    //Set initial settings
    [self initializePowerSourceChanges];
    
    if(!batteryThreshold){
        batteryThreshold = [[data objectForKey:@"stop when battery reaches"] intValue];
    }
    
    if(!run_vm_on_battery){
        run_vm_on_battery = [[data objectForKey:@"run on battery power"] boolValue];
    }
    
    if(!run_only_during_days){
        run_only_during_days = [[data objectForKey:@"run only on days"] boolValue];
    }
    
    [self setBatteryVariables];
}

-(NSArray*)getCurrentTimeInHourMinuteDayOfWeek{
    //Get the current time in hours and minutes (24 hour scale)
    NSString *currentTime = [self getCurrentLocalTime];
    NSRange colonLocation = [currentTime rangeOfString:@":"];
    
    int hour = [[currentTime substringToIndex:colonLocation.location] intValue];
    int minutes = [[currentTime substringFromIndex:colonLocation.location+1] intValue];
    
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:hour], [NSNumber numberWithInt:minutes], [self getDayOfWeek], nil];
}

-(NSString*)getCurrentLocalTime{
    NSDateFormatter *timeOfDayInt = [[NSDateFormatter alloc] init];
    [timeOfDayInt setDateFormat:@"HH:mm"];
    return [timeOfDayInt stringFromDate:[NSDate date]];
}

-(NSString*)getDayOfWeek{
    NSDateFormatter *dayOfWeek = [[NSDateFormatter alloc] init];
    [dayOfWeek setDateFormat:@"EEEE"];
    return [dayOfWeek stringFromDate:[NSDate date]];
}

-(void)setActiveSettingsView:(SettingsViewController *)settingsViewController{
    settingsVC = settingsViewController;
}
-(void)setBatteryThreshold:(int)batteryPercentage{
    batteryThreshold = batteryPercentage;
}
-(void)setRunOnBattery:(bool)runOnBattery{
    run_vm_on_battery = runOnBattery;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [data writeToFile: path atomically:YES];
}

//Set Setting
-(void)setSetting:(NSString *)key :(id)val{
    [data setObject:val forKey:key];
}

//Get Setting
-(id)getSetting:(NSString *)key{
    return [data objectForKey:key];
}

//Get Settings.plist
-(void)getSettingsPlist{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    path = [documentsDirectory stringByAppendingPathComponent:@"settings.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]){
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
        [fileManager copyItemAtPath:bundle toPath: path error:&error];
    } else {
//        [fileManager removeItemAtPath:path error:nil];
    }
    
    data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
}

//Battery Status
-(int)getBatteryPercentage{
//    NSLog(@ "POWER SOURCES: %@", IOPSCopyPowerSourcesInfo());
    return 0;
}

-(void)setRunOnlyDuringHours:(bool)runOnlyDuringHours{
    run_only_during_hours = runOnlyDuringHours;
}

-(void)setRunOnlyDuringDays:(bool)runDuringDays{
    run_only_during_days = runDuringDays;
}

-(void)setRunDuringStartHours:(int)hour Minutes:(int)min{
    if(hour && hour > -1){
        run_start_hour = hour;
    }
    if(min && min > -1){
        run_start_minutes = min;
    }
}

-(void)setRunDuringEndHours:(int)hour Minutes:(int)min{
    if(hour && hour > -1){
        run_end_hour = hour;
    }
    if(min  && min > -1){
        run_end_minutes = min;
    }
}

-(void)setBatteryVariables{
    CFTypeRef source = IOPSCopyPowerSourcesInfo();
    CFArrayRef sources = IOPSCopyPowerSourcesList(source);
    
    NSDictionary *batteryDetails = CFBridgingRelease(IOPSGetPowerSourceDescription(source, sources));
    NSString *powerSource = [[batteryDetails valueForKey:@"Power Source State"] objectAtIndex:0];
    int batteryPercentageRemaining = [[[batteryDetails valueForKey:@"Current Capacity"] objectAtIndex:0] intValue];
    
    //battery checks
    bool runVM_battery = NO;
    if(run_vm_on_battery){
        //RUN VM
        runVM_battery = YES;
    } else if([powerSource isEqual: @"AC Power"]){
        //RUN VM
        runVM_battery = YES;
    }
    
    if(batteryPercentageRemaining <= batteryThreshold){
        //STOP VM
        runVM_battery = NO;
    }
    
    //Hours checks
    bool run_vm_hours = NO;
    NSArray *hourMinDayOfWeek = [self getCurrentTimeInHourMinuteDayOfWeek];
    int hour = [[hourMinDayOfWeek objectAtIndex:0] intValue];
    int minutes = [[hourMinDayOfWeek objectAtIndex:1] intValue];
    
    if(! run_only_during_hours){
        run_vm_hours = YES;
    } else if(hour > run_start_hour && hour < run_end_hour){
        run_vm_hours = YES;
    } else if(hour == run_start_hour && minutes > run_start_minutes){
        run_vm_hours = YES;
    } else if(hour == run_end_hour && minutes < run_end_minutes){
        run_vm_hours = YES;
    }
    
    
    //Date checks
    bool run_vm_date = NO;
    NSString *dayOfWeek = [self getDayOfWeek];
    
    if(! run_only_during_days){
        run_only_during_days ? NSLog(@"RUN ONLY DURING DAYS: YES") : NSLog(@"RUN ONLY DURING DAYS: NO");
        run_vm_date = YES;
    } else if([[self getSetting:@"run on days"][dayOfWeek] boolValue]){
        NSLog(@"%@ is %@", dayOfWeek, [self getSetting:@"run on days"][dayOfWeek]);
        run_vm_date = YES;
    }

    
    //Start VM if all of the above pass
    if(runVM_battery && run_vm_hours && run_vm_date){
        //start VM
        NSLog(@"RUNNING VM");
        [self startVM];
    } else {
        //stop VM
        NSLog(@"STOPPING VM");
        [self stopVM];
        
        //why not?
        if(!runVM_battery){
            NSLog(@"BATTERY IS NO GO");
        }
        if(!run_vm_hours){
            NSLog(@"HOURS IS NO GO");
        }
        if(!run_vm_date){
            NSLog(@"DATE IS NO GO");
        }
    }
}

void PowerSourcesHaveChanged(void *context){
    NSLog(@"battery status changed");
    
    //    [self doThisPlease]; // <- self undeclared
    //update battery percentage and status (plugged in or not)
    id callbackObject = (__bridge id) context;
    [callbackObject setBatteryVariables];
}

/* initializePowerSourceChanges
 *
 * Registers a handler that gets called on power source (battery or UPS)
 changes
 */
-(void)initializePowerSourceChanges
{
    CFRunLoopSourceRef         CFrls;
    
    // Create and add RunLoopSource
    CFrls =
    IOPSNotificationCreateRunLoopSource(PowerSourcesHaveChanged, (__bridge void *)self);
    if(CFrls) {
        CFRunLoopAddSource(CFRunLoopGetCurrent(), CFrls,
                           kCFRunLoopDefaultMode);
        CFRelease(CFrls);
    }
    
}

@end
