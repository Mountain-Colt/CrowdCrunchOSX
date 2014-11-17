//
//  AppDelegate.m
//  CrowdCrunch
//
//  Created by HackReactor on 11/10/14.
//  Copyright (c) 2014 HackReactor. All rights reserved.
//

#import "AppDelegate.h"
#import <IOKit/ps/IOPowerSources.h>


@interface AppDelegate (){
    NSString *path;
    NSMutableDictionary *data;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self getSettingsPlist];
    
    //run a bash script call startDocker in the Resources folder (wherever that is)
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:[NSArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"startDocker" ofType:@"sh"], nil]];
    [task launch];
    [self initializePowerSourceChanges];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [data writeToFile: path atomically:YES];
}

-(int)getBatteryPercentage{
    NSLog(@ "POWER SOURCES: %@", IOPSCopyPowerSourcesInfo());
    return 0;
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
    }
    
    data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
}

//Battery Status
void PowerSourcesHaveChanged(void *context){
    NSLog(@"battery status changed");
    
    //    [self doThisPlease]; // <- self undeclared
    //update battery percentage and status (plugged in or not)
    id callbackObject = (__bridge id) context;
    [callbackObject getBatteryPercentage];
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
