//
//  ProjectItem.h
//  CrowdCrunch
//
//  Created by HackReactor on 11/20/14.
//  Copyright (c) 2014 HackReactor. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ProjectItem : NSCollectionViewItem{
    IBOutlet NSImageView *projectImage;
    IBOutlet NSButton *cardBackground;
}

@end
