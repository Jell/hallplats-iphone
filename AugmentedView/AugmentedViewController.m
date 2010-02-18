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
@synthesize ar_poiList;
@synthesize ar_poiViews;
@synthesize selectedPoi;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	currentLocation = nil;
	selectedPoi = -1;
	
	infoLabelDisplay = [[AugmentedPoiViewController alloc] initWithNibName:@"AugmentedPoiView" bundle:nil];

	[poiOverlay addSubview:infoLabelDisplay.view];
	
	ar_poiList = [[NSMutableArray alloc] init];
	ar_poiViews = [[NSMutableArray alloc] init];
	
	headingBufferIndex = 0;
	for(int i = 0; i < HEADING_BUFFER_SIZE; i++){
		headingBuffer[i] = 0;
	}
} 

- (void)locationManager: (CLLocationManager *)manager
	didUpdateToLocation: (CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	currentLocation = newLocation;
	for (AugmentedPoi *aPoi in ar_poiList) {
		[aPoi updateFrom:newLocation.coordinate];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
	
	headingBuffer[headingBufferIndex] = 3.14 * newHeading.trueHeading / 180.0;	
	float headinAngle = 0.0;
	
	for(int i = 0; i<HEADING_BUFFER_SIZE; i++){
		headinAngle += headingBuffer[i];
	}
	
	headinAngle /=  (float) HEADING_BUFFER_SIZE;
	
	headingBufferIndex++;
	headingBufferIndex %= HEADING_BUFFER_SIZE;
	
	float jitter = angleXY - headinAngle;
	int i = 0;
	[self translateView:infoLabelDisplay.view withTeta:3.14 andDistance:0];
	for (AugmentedPoi *aPoi in ar_poiList) {
		float teta = jitter - [aPoi teta];
		float dist = 70.0 - 70.0*[aPoi distance] / maxDistance;
		[self translateView:[ar_poiViews objectAtIndex:i] withTeta:teta andDistance:dist];
		
		if(i == selectedPoi){
			[self translateView:infoLabelDisplay.view withTeta:teta andDistance:-1];
			[infoLabelDisplay setArrowLength:dist];
		}
		i++;
	}
}

-(void)translateView:(UIView *)aView withTeta:(float)teta andDistance:(float)distance{
	if(sin(teta)<0){
		if(distance>=0){
			aView.layer.transform = CATransform3DScale(CATransform3DMakeTranslation((160.0 + 80 * abs(sin(angleXY))) * cos(teta) / sin(17. * 3.14 / 180), distance, distance),
												   0.5+(distance/140.0),
												   0.5+(distance/140.0),
												   1.0);
		}else{
			aView.layer.transform = CATransform3DMakeTranslation((160.0 + 80 * abs(sin(angleXY))) * cos(teta) / sin(17. * 3.14 / 180), distance, distance);
		}
	}else{
		aView.layer.transform = CATransform3DMakeTranslation(400, 0, 0);
	}
}

-(void)accelerationChangedX:(float)x y:(float)y z:(float)z
{
	// Get the current device angle
	float phi = atan2(sqrt(y*y+x*x), z);
	angleXY = atan2(-x, y);

	poiOverlay.layer.transform = CATransform3DMakeRotation(3.14-angleXY, 0.0, 0.0, 1.0);
	
	poiOverlay.layer.transform = CATransform3DTranslate(poiOverlay.layer.transform,0.0, 240.0 * sin(phi + (3.14 / 2.0))/ sin(28 * 3.14 / 180), 0.0);
	//self.view.layer.transform = CATransform3DRotate(self.view.layer.transform, 3.14-angleXY, 0.0, 0.0, 1.0);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

-(void)setAnnotationList:(NSArray *)newList{
	
	for(UIView *aView in ar_poiViews){
		[aView removeFromSuperview];
	}
	
	[ar_poiViews release];
	[ar_poiList release];
	
	ar_poiList = [[NSMutableArray alloc] init];
	ar_poiViews = [[NSMutableArray alloc] init];
	
	CLLocationCoordinate2D origin = {0,0};
	if(currentLocation){
		origin = currentLocation.coordinate;
	}
	maxDistance = 0.0;

	for(VTAnnotation *anAnnotation in newList){
		AugmentedPoi *aPoi = [[AugmentedPoi alloc] initWithAnnotation:anAnnotation fromOrigin:origin];
		[ar_poiList addObject:aPoi];
		if([aPoi distance] > maxDistance) maxDistance = [aPoi distance];
		[aPoi release];
		[self addPoiView];
	}
}

-(void)addPoiView{
	CGPoint center = {260, 260};
	
	UIButton *aButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	aButton.exclusiveTouch = NO;
	aButton.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
	aButton.backgroundColor = [UIColor clearColor];
	UIImage *buttonImageNormal = [UIImage imageNamed:@"augmentedpoi.png"];
	[aButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
	UIImage *buttonImagePressed = [UIImage imageNamed:@"augmentedpoiselect.png"];
	[aButton setBackgroundImage:buttonImagePressed forState:UIControlStateHighlighted];
	[aButton addTarget:self action:@selector(poiSelected:) forControlEvents:UIControlEventTouchDown];
	
	aButton.center = center;
	[poiOverlay addSubview:aButton];
	[ar_poiViews addObject:aButton];
	[aButton release];
	
}
-(void) poiSelected:(id) poiViewId{
	
	if(selectedPoi >= 0){
		UIButton *previousSelectedButton = [ar_poiViews objectAtIndex:selectedPoi];
		[previousSelectedButton setEnabled:TRUE];
		[poiOverlay sendSubviewToBack:previousSelectedButton];
		[poiOverlay sendSubviewToBack:gridView];
	}
	
	[self setSelectedPoi:[ar_poiViews indexOfObject:poiViewId]];
}

-(void) setSelectedPoi:(int)value{
	selectedPoi = value;
	if(selectedPoi >=0){
		UIButton *selectedView = [ar_poiViews objectAtIndex:selectedPoi];
		[selectedView setEnabled:FALSE];
		[poiOverlay bringSubviewToFront:selectedView];
		[poiOverlay bringSubviewToFront:infoLabelDisplay.view];
		VTAnnotation *selectedAnnotation = [[ar_poiList objectAtIndex:selectedPoi] annotation];
		[infoLabelDisplay setText:[selectedAnnotation title]];
		[infoLabelDisplay clearTramLines];
		
		NSArray *lineList = [selectedAnnotation getLineList];
		for (VTLineInfo *aLine in lineList) {
			[infoLabelDisplay addTramLine:aLine.lineNumber
						  backgroundColor:aLine.backgroundColor
						  foregroundColor:aLine.foregroundColor];
		}
		
	}
}

-(void)setCurrentLocation:(CLLocation *)location{
	currentLocation = location;
	for (AugmentedPoi *aPoi in ar_poiList) {
		[aPoi updateFrom:location.coordinate];
	}
}

-(void)setOrientation:(UIInterfaceOrientation)orientation{
}

- (void)viewDidUnload {
	[infoLabelDisplay release];
	[ar_poiList release];
	for(UIView *aView in ar_poiViews){
		[aView removeFromSuperview];
	}
	[ar_poiViews release];
	
	free(headingBuffer);
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[infoLabelDisplay release];
	[ar_poiList release];
	for(UIView *aView in ar_poiViews){
		[aView removeFromSuperview];
	}
	[ar_poiViews release];
	
	free(headingBuffer);
    [super dealloc];
}


@end
