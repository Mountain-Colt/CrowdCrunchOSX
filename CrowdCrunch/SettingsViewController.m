//
//  SettingsViewController.m
//  CrowdCrunch
//
//  Created by HackReactor on 11/10/14.
//  Copyright (c) 2014 HackReactor. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"

@implementation SettingsViewController{
    AppDelegate *appDelegate;
    NSMutableDictionary *days;
}
//@synthesize projects;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Load existing settings
    appDelegate = [[NSApplication sharedApplication] delegate];
    
    int runOnBatteryPower = [[appDelegate getSetting:@"run on battery power"] intValue];
    if(runOnBatteryPower != 0){
        [runOnBattery setSelectedSegment:0];
    } else {
        [runOnBattery setSelectedSegment:1];
    }
    
    int runOnlyDuringHoursValue = [[appDelegate getSetting:@"run only during hours"] intValue];
    if(runOnlyDuringHoursValue != 0){
        [runOnlyDuringHours setSelectedSegment:0];
    } else {
        [runOnlyDuringHours setSelectedSegment:1];
    }
    
    int runOnlyOnDaysSwitch = [[appDelegate getSetting:@"run only on days"] intValue];
    if(runOnlyOnDaysSwitch != 0){
        [runOnlyOnDays setSelectedSegment:0];
    } else {
        [runOnlyOnDays setSelectedSegment:1];
    }
    
    days = [appDelegate getSetting:@"run on days"];
    
    for(id day in days){
        [days objectForKey:day]; // on or off (0 || 1)
        if([day isEqualTo:@"Sunday"]){
            [runDays setSelected:[[days objectForKey:day] boolValue] forSegment:0];
        } else if([day isEqualTo:@"Monday"]){
            [runDays setSelected:[[days objectForKey:day] boolValue] forSegment:1];
        } else if([day isEqualTo:@"Tuesday"]){
            [runDays setSelected:[[days objectForKey:day] boolValue] forSegment:2];
        } else if([day isEqualTo:@"Wednesday"]){
            [runDays setSelected:[[days objectForKey:day] boolValue] forSegment:3];
        } else if([day isEqualTo:@"Thursday"]){
            [runDays setSelected:[[days objectForKey:day] boolValue] forSegment:4];
        } else if([day isEqualTo:@"Friday"]){
            [runDays setSelected:[[days objectForKey:day] boolValue] forSegment:5];
        } else if([day isEqualTo:@"Saturday"]){
            [runDays setSelected:[[days objectForKey:day] boolValue] forSegment:6];
        }
    }
    
    //Set segmented control listeners
    [runOnBattery setAction:@selector(runOnBatteryChanged:)];
    [runOnlyDuringHours setAction:@selector(runOnlyDuringHoursChanged:)];
    [runDays setAction:@selector(runDaysChanged:)];
    [runOnlyOnDays setAction:@selector(runOnlyOnDaysChanged:)];
    [self setInitialSettings];
    
}

- (void)setInitialSettings{
    [stopAtBatteryPercentage setStringValue:[[appDelegate getSetting:@"stop when battery reaches"] stringValue]];
    
    [runHoursStartH setStringValue:[appDelegate getSetting:@"runHoursStartH"]];
    [runHoursStartM setStringValue:[appDelegate getSetting:@"runHoursStartM"]];
    
    if([[appDelegate getSetting:@"runHoursStartAMPM"]  isEqual: @"AM"]){
        [runHoursStartAMPM selectItemAtIndex:0];
    } else {
        [runHoursStartAMPM selectItemAtIndex:1];
    }
    
    [runHoursEndH setStringValue:[appDelegate getSetting:@"runHoursEndH"]];
    [runHoursEndM setStringValue:[appDelegate getSetting:@"runHoursEndM"]];
    
    if([[appDelegate getSetting:@"runHoursEndAMPM"]  isEqual: @"AM"]){
        [runHoursEndAMPM selectItemAtIndex:0];
    } else {
        [runHoursEndAMPM selectItemAtIndex:1];
    }
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
//    NSLog(@"%@: stringValue == %@", [textField identifier],[textField stringValue]);
    
    if([[textField identifier] isEqual: @"batteryPercentage"]){
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *batteryPercentage = [f numberFromString:[textField stringValue]];
        [appDelegate setSetting:@"stop when battery reaches" :[f numberFromString:[textField stringValue]]];
        [appDelegate setBatteryThreshold:[batteryPercentage intValue]];
        
    } else if([[textField identifier] isEqual: @"startH"]){
        NSString *hour = [textField stringValue];
        int hour24 = [hour intValue];
        
        if([runHoursStartAMPM indexOfSelectedItem] == 1){
            hour24 += 12;
        }
        
        [appDelegate setSetting:@"runHoursStartH" :hour];
        [appDelegate setRunDuringStartHours:hour24 Minutes:-1];
        
    } else if([[textField identifier] isEqual: @"startM"]){
        [appDelegate setSetting:@"runHoursStartM" :[textField stringValue]];
        [appDelegate setRunDuringStartHours:-1 Minutes:[[textField stringValue] intValue]];
        
    } else if([[textField identifier] isEqual: @"endH"]){
        NSString *hour = [textField stringValue];
        int hour24 = [hour intValue];
        
        if([runHoursEndAMPM indexOfSelectedItem] == 1){
            hour24 += 12;
        }
        
        [appDelegate setSetting:@"runHoursEndH" :hour];
        [appDelegate setRunDuringEndHours:hour24 Minutes:-1];
        
    } else if([[textField identifier] isEqual: @"endM"]){
        [appDelegate setSetting:@"runHoursEndM" :[textField stringValue]];
        [appDelegate setRunDuringEndHours:-1 Minutes:[[textField stringValue] intValue]];
    }
    
    [appDelegate setBatteryVariables];
}

- (IBAction)runHoursStartAMPMChanged:(id)sender{
    NSPopUpButton *popUp = (NSPopUpButton *)sender;
    NSLog(@"Start AMPM Changed to: %@", [popUp titleOfSelectedItem]);
    [appDelegate setSetting:@"runHoursStartAMPM" :[popUp titleOfSelectedItem]];
    
    int hour24 = [[appDelegate getSetting:@"runHoursStartH"] intValue];
    if([runHoursStartAMPM indexOfSelectedItem] == 1){
        NSLog(@"ARGHAHAHHAH: %@", @"yeppers");
        if(hour24 < 12){
            hour24 += 12;
        } else if(hour24 == 12){
            hour24 = 0;
        }
    } else {
        if(hour24 >= 12){
            hour24 -= 12;
        }
    }
    [appDelegate setRunDuringStartHours:hour24 Minutes:-1];
}

- (IBAction)runHoursEndAMPMChanged:(id)sender{
    NSPopUpButton *popUp = (NSPopUpButton *)sender;
    [appDelegate setSetting:@"runHoursEndAMPM" :[popUp titleOfSelectedItem]];
    
    int hour24 = [[appDelegate getSetting:@"runHoursEndH"] intValue];
    if([runHoursEndAMPM indexOfSelectedItem] == 1){
        if(hour24 < 12){
            hour24 += 12;
        } else if(hour24 == 12){
            hour24 = 0;
        }
    } else {
        if(hour24 >= 12){
            hour24 -= 12;
        }
    }
    [appDelegate setRunDuringEndHours:hour24 Minutes:-1];
}

- (IBAction)runOnBatteryChanged:(id)sender
{
    long clickedSegment = [sender selectedSegment];
    if(clickedSegment == 0){
        [appDelegate setSetting:@"run on battery power" :[NSNumber numberWithBool:YES]];
        [appDelegate setRunOnBattery:YES];
    } else {
        [appDelegate setSetting:@"run on battery power" :[NSNumber numberWithBool:NO]];
        [appDelegate setRunOnBattery:NO];
    }
    [appDelegate setBatteryVariables];
}

- (IBAction)runOnlyDuringHoursChanged:(id)sender
{
    long clickedSegment = [sender selectedSegment];
    if(clickedSegment == 0){
        [appDelegate setSetting:@"run only during hours" :[NSNumber numberWithBool:YES]];
        [appDelegate setRunOnlyDuringHours:YES];
    } else {
        [appDelegate setSetting:@"run only during hours" :[NSNumber numberWithBool:NO]];
        [appDelegate setRunOnlyDuringHours:NO];
    }
    [appDelegate setBatteryVariables];
}

-(IBAction)runOnlyOnDaysChanged:(id)sender{
    long clickedSegment = [sender selectedSegment];
    if(clickedSegment == 0){
        [appDelegate setSetting:@"run only on days" :[NSNumber numberWithBool:YES]];
        [appDelegate setRunOnlyDuringDays:YES];
    } else {
        [appDelegate setSetting:@"run only on days" :[NSNumber numberWithBool:NO]];
        [appDelegate setRunOnlyDuringDays:NO];
    }
    [appDelegate setBatteryVariables];
}

- (IBAction)runDaysChanged:(id)sender
{
    long clickedSegment = [sender selectedSegment];
    BOOL isSelected = [runDays isSelectedForSegment:clickedSegment];
    switch (clickedSegment) {
        case 0:
            NSLog(@"SUNDAY");
            [days setValue:[NSNumber numberWithBool:isSelected] forKey:@"Sunday"];
            break;
        case 1:
            NSLog(@"MONDAY");
            [days setValue:[NSNumber numberWithBool:isSelected] forKey:@"Monday"];
            break;
        case 2:
            NSLog(@"TUESDAY");
            [days setValue:[NSNumber numberWithBool:isSelected] forKey:@"Tuesday"];
            break;
        case 3:
            NSLog(@"WEDNESDAY");
            [days setValue:[NSNumber numberWithBool:isSelected] forKey:@"Wednesday"];
            break;
        case 4:
            NSLog(@"THURSDAY");
            [days setValue:[NSNumber numberWithBool:isSelected] forKey:@"Thursday"];
            break;
        case 5:
            NSLog(@"FRIDAY");
            [days setValue:[NSNumber numberWithBool:isSelected] forKey:@"Friday"];
            break;
        case 6:
            NSLog(@"SATURDAY");
            [days setValue:[NSNumber numberWithBool:isSelected] forKey:@"Saturday"];
            break;
            
        default:
            break;
    }
    [appDelegate setSetting:@"run on days" :days];
    [runDays setSelected:isSelected forSegment:clickedSegment];
    [appDelegate setBatteryVariables];
}


@end

