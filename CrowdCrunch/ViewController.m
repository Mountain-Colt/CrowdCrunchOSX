//
//  ViewController.m
//  CrowdCrunch
//
//  Created by HackReactor on 11/10/14.
//  Copyright (c) 2014 HackReactor. All rights reserved.
//

#import "ViewController.h"
#import "Project.h"
#import "PathTransformer.h"

@implementation ViewController
@synthesize projects;

- (void)viewDidLoad {
    [super viewDidLoad];
    //[logo setWantsLayer:YES];
//    [logo.layer setBackgroundColor:[[NSColor greenColor] CGColor]];
    
    NSCollectionViewItem *proto = [self.storyboard instantiateControllerWithIdentifier:@"projectItemView"];
    [collectionView setItemPrototype:proto];
    
    id transformer = [[PathTransformer alloc] init];
    [NSValueTransformer setValueTransformer:transformer forName:@"PathTransformer"];

    [self getProjects];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

//GET projects from server
- (void) getProjects {
    //make http request
    NSURL *url = [NSURL URLWithString:@"http://mtcolt.herokuapp.com/api/projects/"];
    NSData *data = [self dataWithUrl:url];
    
    
    //parse JSON data
    NSError *e = nil;
    
    NSMutableArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: kNilOptions error: &e];
    NSMutableArray *newProjects = [[NSMutableArray alloc] init];
    
    if (!jsonArray) {
        NSLog(@"Error parsing JSON: %@", e);
    } else {
        for(NSDictionary *item in jsonArray) {
            NSLog(@"Item: %@", item);
            Project * pmTemp = [[Project alloc] init];
            pmTemp.title = [item objectForKey:@"projectname"];
            pmTemp.text = [item objectForKey:@"projectdescription"];
            pmTemp.image = [item objectForKey:@"projectimage"]; //CHANGE LATER
            
            //Fallback Image
            if(!pmTemp.image){
                pmTemp.image = @"fibre-optic.jpg";
            }
            
            pmTemp.subscribed = @"NO";
            [newProjects addObject:pmTemp];
        }
    }
    [self setPersonModelArray:newProjects];
    [collectionView setContent:projects];
}

//HTTP REQUEST
- (NSData *)dataWithUrl:(NSURL *)url
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                             timeoutInterval:30];
    [urlRequest setHTTPMethod:@"GET"];
    
    // Fetch the JSON response
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    // Make synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                    returningResponse:&response
                                                error:&error];
    
    // Construct a String around the Data from the response
    return urlData;
}


//KVO Compliant Functions
-(void)insertObject:(Project *)p
inPersonModelArrayAtIndex:(NSUInteger)index {
    [projects insertObject:p atIndex:index];
}
-(void)removeObjectFromPersonModelArrayAtIndex:(NSUInteger)index {
    [projects removeObjectAtIndex:index];
}
-(void)setPersonModelArray:(NSMutableArray *)a {
    projects = a;
}
-(NSArray*)projects {
    return projects;
}

//Other
- (void)awakeFromNib {
    
}

@end
