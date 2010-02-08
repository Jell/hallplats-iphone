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
@synthesize ar_poiList;

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
	/*
	location.latitude = 57.7119;
	location.longitude = 11.9683;
	*/
	ar_poiList = [[NSMutableArray alloc] init];
	CLLocationCoordinate2D origin = {57.7119, 11.9683};
	CLLocationCoordinate2D location = {57.7119, 15.0};
	MPNAnnotation *anAnnotation = [[MPNAnnotation alloc] initWithCoordinate:location];
	[anAnnotation setTitle:@"North" subtitle:@"Direction"];
	AugmentedPOI *aPoi = [[AugmentedPOI alloc] initWithAnnotation:anAnnotation fromOrigin:origin];
	[anAnnotation release];
	[ar_poiList addObject:aPoi];
	[aPoi release];
	
	location.latitude = 57.7119;
	location.longitude = 5.0;
	anAnnotation = [[MPNAnnotation alloc] initWithCoordinate:location];
	[anAnnotation setTitle:@"South" subtitle:@"Direction"];
	aPoi = [[AugmentedPOI alloc] initWithAnnotation:anAnnotation fromOrigin:origin];
	[anAnnotation release];
	[ar_poiList addObject:aPoi];
	[aPoi release];
	
	location.latitude = 70.0;
	location.longitude = 11.9683;
	anAnnotation = [[MPNAnnotation alloc] initWithCoordinate:location];
	[anAnnotation setTitle:@"East" subtitle:@"Direction"];
	aPoi = [[AugmentedPOI alloc] initWithAnnotation:anAnnotation fromOrigin:origin];
	[anAnnotation release];
	[ar_poiList addObject:aPoi];
	[aPoi release];
	
	location.latitude = 40.0;
	location.longitude = 11.9683;
	anAnnotation = [[MPNAnnotation alloc] initWithCoordinate:location];
	[anAnnotation setTitle:@"West" subtitle:@"Direction"];
	aPoi = [[AugmentedPOI alloc] initWithAnnotation:anAnnotation fromOrigin:origin];
	[anAnnotation release];
	[ar_poiList addObject:aPoi];
	[aPoi release];
	
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
	float jitter = 3.14 + angleXY - 3.14 * newHeading.trueHeading / 180.0;
	float teta;
	if(ar_poiList){
		teta = [(AugmentedPOI *)[ar_poiList objectAtIndex:0] teta] + jitter;
		[self translateView:northLabel withTeta:teta];
		
		teta = [(AugmentedPOI *)[ar_poiList objectAtIndex:1] teta] + jitter;
		[self translateView:southLabel withTeta:teta];
		
		teta = [(AugmentedPOI *)[ar_poiList objectAtIndex:2] teta] + jitter;
		[self translateView:eastLabel withTeta:teta];
				
		teta = [(AugmentedPOI *)[ar_poiList objectAtIndex:3] teta] + jitter;
		[self translateView:westLabel withTeta:teta];
	}
}

-(void)translateView:(UIView *)aView withTeta:(float)teta{
	if(cos(teta)>0){
		aView.layer.transform = CATransform3DMakeTranslation((160.0 + 80 * abs(sin(angleXY))) * sin(teta) / sin(17. * 3.14 / 180), 0, 0);
	}else{
		aView.layer.transform = CATransform3DMakeTranslation(300, 0, 0);
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

-(void)setOrientation:(UIInterfaceOrientation)orientation{
}

- (void)viewDidUnload {
	[ar_poiList release];
	[currentLocation release];
	[annotationList release];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[ar_poiList release];
	[currentLocation release];
	[annotationList release];
    [super dealloc];
}


@end
