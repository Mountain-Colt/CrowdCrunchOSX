//
//  ViewController.h
//  CrowdCrunch
//
//  Created by HackReactor on 11/10/14.
//  Copyright (c) 2014 HackReactor. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController {
    NSMutableArray *projects;
    IBOutlet NSCollectionView *collectionView;
    IBOutlet NSImageView *logo;
}

@property (readwrite, strong, nonatomic) NSMutableArray *projects;


@end

