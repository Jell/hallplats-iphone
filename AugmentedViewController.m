//
//  AugmentedViewController.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AugmentedViewController.h"
#import "AugmentedView.h"

@implementation AugmentedViewController
@synthesize currentLocation;
@synthesize annotationList;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return NO;
}

- (void)locationManager: (CLLocationManager *)manager
	didUpdateToLocation: (CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
	float teta =  -3.14 * newHeading.trueHeading / 180.0;
	
	if(cos(teta)>0){
		arrowView.layer.transform = CATransform3DMakeTranslation(160.0 * sin(teta) / sin(37.5 * 3.14 / 180), 0, 0);
	}else{
		arrowView.layer.transform = CATransform3DMakeTranslation(200, 0, 0);
	}
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

-(void)setAnnotationList:(NSArray *)newList{
	[annotationList release];
	annotationList = [newList copy];
}

-(void)setCurrentLocation:(CLLocation *)location{
	[currentLocation release];
	currentLocation = [location copy];
}


- (void)viewDidUnload {
	[currentLocation release];
	[annotationList release];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[currentLocation release];
	[annotationList release];
    [super dealloc];
}


@end
