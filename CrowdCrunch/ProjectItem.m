//
//  ProjectItem.m
//  CrowdCrunch
//
//  Created by HackReactor on 11/20/14.
//  Copyright (c) 2014 HackReactor. All rights reserved.
//

#import "ProjectItem.h"
#import <QuartzCore/QuartzCore.h>

@interface ProjectItem (){
    
}

@end;

@implementation NSBezierPath (BezierPathQuartzUtilities)
// This method works only in OS X v10.2 and later.
- (CGPathRef)quartzPath
{
    int i, numElements;
    
    // Need to begin a path here.
    CGPathRef           immutablePath = NULL;
    
    // Then draw the path elements.
    numElements = (int)[self elementCount];
    if (numElements > 0)
    {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
        BOOL                didClosePath = YES;
        
        for (i = 0; i < numElements; i++)
        {
            switch ([self elementAtIndex:i associatedPoints:points])
            {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
                    
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    didClosePath = NO;
                    break;
                    
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                          points[1].x, points[1].y,
                                          points[2].x, points[2].y);
                    didClosePath = NO;
                    break;
                    
                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    didClosePath = YES;
                    break;
            }
        }
        
        // Be sure the path is closed or Quartz may not do valid hit detection.
        if (!didClosePath)
            CGPathCloseSubpath(path);
        
        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
    
    return immutablePath;
}
@end

@implementation ProjectItem

-(void)awakeFromNib {
    NSLog(@"LOADED FROM STORYBOARD");
    NSLog(@"HALP! %@",[self representedObject]);
    
}

-(id)copyWithZone:(NSZone *)zone
{
    id result = [super copyWithZone:zone];
    
//    [NSBundle loadNibNamed:@"projectItemView" owner:result];
    [self.storyboard instantiateControllerWithIdentifier:@"projectItemView"];
    
    return result;
}


- (IBAction)donatePowerClicked:(id)sender{
//    NSLog(@"CLICKED %@", [_titleTextField stringValue]);
    
    NSLog(@"CLICKED %@", sender);
    NSLog(@"CLICKED: %@",[sender alternateTitle]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"LOADED PROJECT ITEM");
    
    [[_cardBackground cell] setBackgroundColor:[NSColor redColor]];
    
    [_projectImage setWantsLayer: YES];
    _projectImage.layer.borderWidth = 1.0;
    _projectImage.layer.cornerRadius = 8.0;
    _projectImage.layer.masksToBounds = YES;
    
    //shadow
    CALayer *layer = _cardBackground.layer;
    layer.shadowOffset = CGSizeMake(1, 1);
    layer.shadowColor = [[NSColor blackColor] CGColor];
    layer.shadowRadius = 4.0f;
    layer.shadowOpacity = 0.80f;
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:layer.bounds];
    layer.shadowPath = [path quartzPath];
    
    NSLog(@"PROJECT IMAGE: %@", _projectImage);
}

@end
