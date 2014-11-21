//
//  AppDelegate.h
//  CrowdCrunch
//
//  Created by HackReactor on 11/10/14.
//  Copyright (c) 2014 HackReactor. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

-(void)setSetting:(NSString *)key :(id)val;
-(id)getSetting:(NSString *)key;

-(void)setBatteryThreshold:(int)batteryPercentage;
-(void)setRunOnBattery:(bool)runOnBattery;
-(void)setBatteryVariables;

-(void)setRunOnlyDuringHours:(bool)runOnlyDuringHours;
-(void)setRunDuringStartHours:(int)hour Minutes:(int)min;
-(void)setRunDuringEndHours:(int)hour Minutes:(int)min;

-(void)setRunOnlyDuringDays:(bool)runDuringDays;

@end

