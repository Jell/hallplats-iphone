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
	
	float teta = 3.14 + angleXY - 3.14 * newHeading.trueHeading / 180.0;
	if(cos(teta)>0){
		northLabel.layer.transform = CATransform3DMakeTranslation((160.0 + 80 * abs(sin(3.14-angleXY))) * sin(teta) / sin(17. * 3.14 / 180), 0, 0);
	}else{
		northLabel.layer.transform = CATransform3DMakeTranslation(300, 0, 0);
	}
	
	teta =  3.14 + angleXY -3.14 * (newHeading.trueHeading + 180.0) / 180.0;
	if(cos(teta)>0){
		southLabel.layer.transform = CATransform3DMakeTranslation((160.0 + 80 * abs(sin(3.14-angleXY))) * sin(teta) / sin(17. * 3.14 / 180), 0, 0);
	}else{
		southLabel.layer.transform = CATransform3DMakeTranslation(300, 0, 0);
	}
	
	teta = 3.14 + angleXY  -3.14 * (newHeading.trueHeading + 270.0) / 180.0;
	if(cos(teta)>0){
		eastLabel.layer.transform = CATransform3DMakeTranslation((160.0 + 80 * abs(sin(3.14-angleXY))) * sin(teta) / sin(17. * 3.14 / 180), 0, 0);
	}else{
		eastLabel.layer.transform = CATransform3DMakeTranslation(300, 0, 0);
	}
	
	teta = 3.14 + angleXY  -3.14 * (newHeading.trueHeading + 90.0) / 180.0;
	if(cos(teta)>-0.5){
		westLabel.layer.transform = CATransform3DMakeTranslation((160.0 + 80 * abs(sin(3.14-angleXY))) * sin(teta) / sin(17. * 3.14 / 180), 0, 0);
	}else{
		westLabel.layer.transform = CATransform3DMakeTranslation(300, 0, 0);
	}
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	// Get the current device angle
	float xx = -[acceleration x];
	float yy = [acceleration y];
	float zz = [acceleration z];
	float phi = atan2(sqrt(yy*yy+xx*xx), zz);
	angleXY = atan2(xx, yy);

	self.view.layer.transform = CATransform3DMakeRotation(3.14-angleXY, 0.0, 0.0, 1.0);
	
	self.view.layer.transform = CATransform3DTranslate(self.view.layer.transform,0.0, 240.0 * sin(phi + (3.14 / 2.0))/ sin(28 * 3.14 / 180), 0.0);
	//self.view.layer.transform = CATransform3DRotate(self.view.layer.transform, 3.14-angleXY, 0.0, 0.0, 1.0);
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
