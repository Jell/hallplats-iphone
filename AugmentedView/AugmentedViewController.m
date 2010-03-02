//
//  AugmentedViewController.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AugmentedViewController.h"
#import "AugmentedView.h"
#define GRID_HEIGHT				400.0
#define GRID_SQUARE_WIDTH		120.0
#define MIN_SCREEN_WIDTH		320.0
#define MAX_SCREEN_WIDTH		480.0
#define OFFSCREEN_SQUARE_SIZE	520.0
#define CAMERA_ANGLE_X			17.0
#define CAMERA_ANGLE_Y			28.0
#define POI_BUTTON_SIZE			40.0

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
	[poiOverlay sendSubviewToBack:gridView];
	[poiOverlay bringSubviewToFront:infoLabelDisplay.view];
	
	ar_poiList = [[NSMutableArray alloc] init];
	ar_poiViews = [[NSMutableArray alloc] init];
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
	
	float headinAngle = M_PI * newHeading.trueHeading / 180.0;
	float jitter = angleXY - headinAngle;
	int i = 0;
	[self translateView:infoLabelDisplay.view withTeta:M_PI andDistance:0 withScale:NO];
	for (AugmentedPoi *aPoi in ar_poiList) {
		float teta = jitter - [aPoi azimuth];
		float dist = GRID_HEIGHT * ([aPoi distance] - minDistance)/ (maxDistance - minDistance);
		[self translateView:[ar_poiViews objectAtIndex:i] withTeta:teta andDistance:dist withScale:YES];
		
		if(i == selectedPoi){
			[self translateView:infoLabelDisplay.view withTeta:teta andDistance:dist withScale:NO];
		}
		i++;
	}
	
	[self translateGridWithTeta:jitter];
}

-(void)translateGridWithTeta:(float)teta{
	float tetaBis = teta + 2*M_PI;
	float tetaModulo = round((tetaBis + M_PI/2.0) / (M_PI/2.0));
	tetaBis = tetaBis - tetaModulo * M_PI/2.0;
	
	float translation = [self translationFromAngle:tetaBis];
	//float modulo = round(translation / GRID_SQUARE_WIDTH);
	//translation -= modulo * GRID_SQUARE_WIDTH;
	
	CATransform3D rotationAndPerspectiveTransform = CATransform3DMakeTranslation(translation, 100.0 + 40, 0.0);
	rotationAndPerspectiveTransform.m34 = 1.0 / -500;
	rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 90.0f * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
	gridView.layer.transform = rotationAndPerspectiveTransform;
}

-(void)translateView:(UIView *)aView withTeta:(float)teta andDistance:(float)distance withScale:(BOOL)scaleEnabled{
	if(sin(teta)<0){
		CATransform3D transfomMatrix = [self make3dTransformWithTranslation:[self translationFromAngle:teta]
																andDistance:distance];
		
		if(!scaleEnabled){
			transfomMatrix = CATransform3DScale(transfomMatrix, transfomMatrix.m44, transfomMatrix.m44, 1.0);
		}

		aView.layer.transform = transfomMatrix;
	}else{
		aView.layer.transform = CATransform3DMakeTranslation(400, 0, 0);
	}
}

-(float)translationFromAngle:(float)teta{
	return ((MIN_SCREEN_WIDTH/2.0) + ((MIN_SCREEN_WIDTH - MAX_SCREEN_WIDTH)/2.0) * abs(sin(angleXY))) * cos(teta) / sin(CAMERA_ANGLE_X * M_PI / 180);
}

-(CATransform3D)make3dTransformWithTranslation:(float)translation andDistance:(float)distance{
	CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
	rotationAndPerspectiveTransform.m34 = 1.0 / -500;
	return CATransform3DTranslate(rotationAndPerspectiveTransform, translation, 100.0, -distance);
}
-(void)accelerationChangedX:(float)x y:(float)y z:(float)z
{
	// Get the current device angle
	float phi = atan2(sqrt(y*y+x*x), z);
	angleXY = atan2(-x, y);

	poiOverlay.layer.transform = CATransform3DMakeRotation(M_PI-angleXY, 0.0, 0.0, 1.0);	
	poiOverlay.layer.transform = CATransform3DTranslate(poiOverlay.layer.transform,0.0, (MAX_SCREEN_WIDTH/2.0) * sin(phi + (M_PI / 2.0))/ sin(CAMERA_ANGLE_Y * M_PI / 180), 0.0);
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
	minDistance = 999999.0;

	for(VTAnnotation *anAnnotation in newList){
		AugmentedPoi *aPoi = [[AugmentedPoi alloc] initWithAnnotation:anAnnotation fromOrigin:origin];
		[ar_poiList addObject:aPoi];
		if([aPoi distance] > maxDistance) maxDistance = [aPoi distance];
		if([aPoi distance] < minDistance) minDistance = [aPoi distance];
		[aPoi release];
		[self addPoiView];
	}
}

-(void)addPoiView{
	CGPoint center = {OFFSCREEN_SQUARE_SIZE/2.0, OFFSCREEN_SQUARE_SIZE/2.0};
	
	UIButton *aButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	aButton.exclusiveTouch = NO;
	aButton.frame = CGRectMake(0.0, 0.0, POI_BUTTON_SIZE, POI_BUTTON_SIZE);
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
		[infoLabelDisplay setTitle:[selectedAnnotation title] subtitle:[selectedAnnotation subtitle]];
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

    [super dealloc];
}


@end
