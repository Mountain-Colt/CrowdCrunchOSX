//
//  ProjectItem.m
//  CrowdCrunch
//
//  Created by HackReactor on 11/20/14.
//  Copyright (c) 2014 HackReactor. All rights reserved.
//

#import "ProjectItem.h"
#import <QuartzCore/QuartzCore.h>

@interface ProjectItem ()

@end;

@implementation ProjectItem

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"LOADED PROJECT ITEM");
    
    [[cardBackground cell] setBackgroundColor:[NSColor redColor]];
    
    [projectImage setWantsLayer: YES];
    projectImage.layer.borderWidth = 1.0;
    projectImage.layer.cornerRadius = 8.0;
    projectImage.layer.masksToBounds = YES;
    
    NSLog(@"PROJECT IMAGE: %@", projectImage);
}

@end
