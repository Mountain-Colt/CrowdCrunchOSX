//
//  ProjectItem.h
//  CrowdCrunch
//
//  Created by HackReactor on 11/20/14.
//  Copyright (c) 2014 HackReactor. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ProjectItem : NSCollectionViewItem{
}

@property (strong) IBOutlet NSImageView *projectImage;
@property (strong) IBOutlet NSButton *cardBackground;
@property (strong) IBOutlet NSTextField *titleTextField;

@property (strong) IBOutlet NSArrayController* arrayController;

- (IBAction)donatePowerClicked:(id)sender;

@end
