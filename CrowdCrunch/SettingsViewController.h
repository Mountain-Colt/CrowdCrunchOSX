//
//  SettingsViewController.h
//  CrowdCrunch
//
//  Created by HackReactor on 11/10/14.
//  Copyright (c) 2014 HackReactor. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SettingsViewController : NSViewController {
    IBOutlet NSSegmentedControl *runOnBattery;
    IBOutlet NSTextField *stopAtBatteryPercentage;
    
    IBOutlet NSSegmentedControl *runOnlyOnDays;
    IBOutlet NSSegmentedControl *runDays;
    
    IBOutlet NSSegmentedControl *runOnlyDuringHours;
    
    IBOutlet NSTextField *runHoursStartH;
    IBOutlet NSTextField *runHoursStartM;
    IBOutlet NSPopUpButton *runHoursStartAMPM;
    
    IBOutlet NSTextField *runHoursEndH;
    IBOutlet NSTextField *runHoursEndM;
    IBOutlet NSPopUpButton *runHoursEndAMPM;
}

//@property (readwrite, strong, nonatomic) NSMutableArray *projects;


@end
