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
	
	infoLabelDisplay = [[UIView alloc] initWithFrame:CGRectMake(-75.0, -30.0, 180.0, 40.0)];
	
	infoLabel = [[UILabel alloc ] initWithFrame:CGRectMake(0.0, 0.0, 180.0, 24.0)];
	infoLabel.textAlignment =  UITextAlignmentCenter;
	infoLabel.textColor = [UIColor whiteColor];
	infoLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fancy_title_main.png"]];
	infoLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(12.0)];
	infoLabel.text = @"";
	
	[infoLabelDisplay addSubview:infoLabel];
	
	UIImageView *anImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowdown.png"]];
	CGPoint center = {90.0, 30.0};
	anImage.center = center;
	[infoLabelDisplay addSubview:anImage];
	[anImage release];
	
	UIImageView *leftCornerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fancy_title_left.png"]];
	CGPoint left = {-7.0, 14.0};
	leftCornerImage.center = left;
	leftCornerImage.clipsToBounds = NO;
	[infoLabelDisplay addSubview:leftCornerImage];
	[leftCornerImage release];
	
	UIImageView *rightCornerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fancy_title_right.png"]];
	CGPoint right = {187.0, 14.0};
	rightCornerImage.center = right;
	rightCornerImage.clipsToBounds = NO;
	[infoLabelDisplay addSubview:rightCornerImage];
	[rightCornerImage release];
	
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
	for (AugmentedPOI *aPoi in ar_poiList) {
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
	for (AugmentedPOI *aPoi in ar_poiList) {
		float teta = jitter - [aPoi teta];
		float dist = 70.0 - 70.0*[aPoi distance] / maxDistance;
		[self translateView:[ar_poiViews objectAtIndex:i] withTeta:teta andDistance:dist];
		i++;
	}
}

-(void)translateView:(UIView *)aView withTeta:(float)teta andDistance:(float)distance{
	if(sin(teta)<0){
		aView.layer.transform = CATransform3DMakeTranslation((160.0 + 80 * abs(sin(angleXY))) * cos(teta) / sin(17. * 3.14 / 180), distance, 0);
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
	CGPoint center = {260, 260};
	for(MPNAnnotation *anAnnotation in newList){
		AugmentedPOI *aPoi = [[AugmentedPOI alloc] initWithAnnotation:anAnnotation fromOrigin:origin];
		/*
		UILabel *aLabel = [[UILabel alloc ] initWithFrame:CGRectMake(0.0, 210.0, 60.0, 20.0)];
		aLabel.center = center;
		aLabel.textAlignment =  UITextAlignmentCenter;
		aLabel.textColor = [UIColor whiteColor];
		aLabel.backgroundColor = [UIColor blackColor];
		aLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(12.0)];
		[self.view addSubview:aLabel];
		aLabel.text = [anAnnotation title];
		*/

		/*
		UIImageView *anImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"augmentedpoi.png"]];
		anImage.center = center;
		[self.view addSubview:anImage];
		[ar_poiList addObject:aPoi];
		[aPoi release];
		[ar_poiViews addObject:anImage];
		[anImage release];
		*/
		
		UIButton *aButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		aButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
		[aButton setTitle:@"" forState:UIControlStateNormal];
		aButton.backgroundColor = [UIColor clearColor];
		UIImage *buttonImageNormal = [UIImage imageNamed:@"augmentedpoi.png"];
		[aButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
		UIImage *buttonImagePressed = [UIImage imageNamed:@"augmentedpoiselect.png"];
		[aButton setBackgroundImage:buttonImagePressed forState:UIControlStateHighlighted];
		[aButton addTarget:self action:@selector(poiSelected:) forControlEvents:UIControlEventTouchDown];
		
		aButton.center = center;
		[poiOverlay addSubview:aButton];
		[ar_poiList addObject:aPoi];
		if([aPoi distance] > maxDistance) maxDistance = [aPoi distance];
		[aPoi release];
		[ar_poiViews addObject:aButton];
		[aButton release];
		
	}
}

-(void) poiSelected:(id) poiViewId{
	
	if(selectedPoi >= 0){
		UIButton *previousSelectedButton = [ar_poiViews objectAtIndex:selectedPoi];
		[previousSelectedButton setEnabled:TRUE];
		[infoLabelDisplay removeFromSuperview];
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
		MPNAnnotation *selectedAnnotation = [[ar_poiList objectAtIndex:selectedPoi] annotation];
		[selectedView addSubview:infoLabelDisplay];
		infoLabel.text = [selectedAnnotation title];
		
		//[titleLabel setText:[selectedAnnotation title]];
	}
}

-(void)setCurrentLocation:(CLLocation *)location{
	currentLocation = location;
	for (AugmentedPOI *aPoi in ar_poiList) {
		[aPoi updateFrom:location.coordinate];
	}
}

-(void)setOrientation:(UIInterfaceOrientation)orientation{
}

- (void)viewDidUnload {
	[infoLabel release];
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
	[infoLabel release];
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
