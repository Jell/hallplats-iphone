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
#define PERSPECTIVE_VERTICAL_OFFSET			50
#define PERSPECTIVE_DEPTH_OFFSET			100
#define PERSPECTIVE_INNER_CIRCLE_RADIUS		0
#define PROJECTION_DEPTH					900

@implementation AugmentedViewController
@synthesize mAlpha;
@synthesize mBeta;
@synthesize mTeta;
@synthesize mVerticalOffset;
@synthesize currentLocation;
@synthesize ar_poiList;
@synthesize ar_poiViews;
@synthesize selectedPoi;
@synthesize delegate;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	currentLocation = nil;
	selectedPoi = -1;
	
	calloutBubble = [[AugmentedCalloutBubbleController alloc] initWithNibName:@"AugmentedCalloutBubbleView" bundle:nil];
	calloutBubble.delegate = self.delegate;
	calloutBubble.view.hidden = TRUE;
	
	[poiOverlay addSubview:calloutBubble.view];
	//[poiOverlay addTarget:self action:@selector(blankTouch:) forControlEvents:UIControlEventTouchDown];

	
	ar_poiList = [[NSMutableArray alloc] init];
	ar_poiViews = [[NSMutableArray alloc] init];
	
	CLLocationCoordinate2D location;
	location.latitude = 57.7119;
	location.longitude = 11.9683;
	//starting span (=zoom)
	MKCoordinateSpan span;
	span.latitudeDelta = 0.02;
	span.longitudeDelta = 0.02;
	MKCoordinateRegion region;
	region.center = location;
	region.span = span;
	//Set MapView
	gridView.region = [gridView regionThatFits:region];
	gridView.mapType=MKMapTypeStandard;
	gridView.zoomEnabled=FALSE;
	gridView.scrollEnabled =FALSE;
	gridView.showsUserLocation = FALSE;
	gridView.delegate = self;
	gridView.clipsToBounds = NO;
	[gridView setAlpha:0.6];
	[gridView resignFirstResponder];
	[mapMask removeFromSuperview];
	[gridView addSubview:mapMask];
	mapMask.center = CGPointMake(500, 500);
} 

- (void)locationManager: (CLLocationManager *)manager
	didUpdateToLocation: (CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	currentLocation = newLocation;
	[gridView setCenterCoordinate:newLocation.coordinate animated:YES];

	for (AugmentedPoi *aPoi in ar_poiList) {
		[aPoi updateAngleFrom:newLocation.coordinate];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
	[self setMTeta:M_PI * newHeading.trueHeading / 180.0];
	[self updateProjection];
}

-(void)updateProjection{
	float teta = [self mTeta];
	float alpha = [self mAlpha] - teta;
	float beta = [self mBeta];
	float sinb = sin(beta);
	float cosb = cos(beta);
	float verticalOffset = [self mVerticalOffset];
	int i = 0;
	
	calloutBubble.view.hidden = TRUE;
	calloutBubble.view.layer.transform = CATransform3DMakeTranslation(400, 0, 0);
	for (AugmentedPoi *aPoi in ar_poiList) {
		float teta = alpha - [aPoi azimuth];

		CLLocationCoordinate2D coordinateLocation = [[aPoi annotation] coordinate];
		CGPoint pixelLocation = [gridView convertCoordinate:coordinateLocation toPointToView:gridView];
		
		//float dist = GRID_HEIGHT * ([aPoi distance] - minDistance)/ (maxDistance - minDistance);
		
		float fromcenterX = 500 - pixelLocation.x;
		float fromcenterY = 500 - pixelLocation.y;
		float dist = sqrt(fromcenterX*fromcenterX + fromcenterY*fromcenterY)* 3 * sin(beta);
		
		[self translateView:[ar_poiViews objectAtIndex:i]
				   withTeta:teta
				    cosBeta:cosb
					sinBeta:sinb
			 verticalOffset:verticalOffset
				   distance:dist];
		
		if(i == selectedPoi){
			[self setBubbleMatrixForView:[ar_poiViews objectAtIndex:i]];
		}
		i++;
	}
	[self translateGridWithTeta:M_PI + alpha cosBeta:cosb sinBeta:sinb verticalOffset:verticalOffset];
}

-(void)translateGridWithTeta:(float)teta
					 cosBeta:(float)cosb
					 sinBeta:(float)sinb
			  verticalOffset:(float)verticalOffset
{
	float cost = cos(teta);
	float sint = sin(teta);
	
	CATransform3D transformMatrix = {
		cost * 3 * sinb,	sint * cosb * 3 * sinb,									sint * sinb * 3 * sinb,					-sint * sinb * 3 * sinb/ PROJECTION_DEPTH,
		-sint * 3 * sinb,	cost * cosb * 3 * sinb,									cost * sinb * 3 * sinb,					-cost * sinb / PROJECTION_DEPTH * 3 * sinb,
		0.0,				-sinb,													cosb,									-cosb / PROJECTION_DEPTH,
		0.0,				(PERSPECTIVE_DEPTH_OFFSET) * sinb + verticalOffset,		-(PERSPECTIVE_DEPTH_OFFSET) * cosb,		1.0
	};
	
	gridView.layer.transform = transformMatrix;
}

-(void)translateView:(UIView *)aView
			withTeta:(float)teta
			 cosBeta:(float)cosb
			 sinBeta:(float)sinb
	  verticalOffset:(float)verticalOffset
			distance:(float)distance
{
	float sint = sin(teta);
	float m34 = 1.0 / -PROJECTION_DEPTH;
	float m43 = - (PERSPECTIVE_DEPTH_OFFSET) * cosb + distance * sinb * sint;
	float m44 = 1 + m34 * m43;
	
	CATransform3D transfomMatrix =
	{
		m44,					0,																				0,		0,
		0,						m44,																			0,		0,
		0,						0,																				1,		m34,
		distance * cos(teta),	(PERSPECTIVE_DEPTH_OFFSET) * sinb + distance * cosb * sint + verticalOffset,	m43,	m44
	};

	aView.layer.transform = transfomMatrix;
}

-(void)setBubbleMatrixForView:(UIView *)aview{
	if(aview == nil){
		calloutBubble.view.hidden = TRUE;
		calloutBubble.view.layer.transform = CATransform3DMakeTranslation(200, 0, 0);
	}else {
		CATransform3D transfomMatrix = [[aview layer] transform];
		calloutBubble.view.layer.transform = transfomMatrix;
		calloutBubble.view.hidden = FALSE;
	}
}


-(void)accelerationChangedX:(float)x y:(float)y z:(float)z
{
	// Get the current device angle
	float beta = M_PI - atan2(sqrt(y*y+x*x), z);
	if(beta > M_PI /2){
		beta = M_PI/2 + sqrt(beta - M_PI /2) * sqrt(M_PI) / 10;
	}
	[self setMBeta:beta];

	float alpha;
	if(x*x + y*y > 0.25){
		alpha = atan2(-x, y);
		[self setMAlpha:alpha];
		CABasicAnimation* overlay_animation = [CABasicAnimation animation];
		
		CATransform3D final_transform = CATransform3DMakeRotation(M_PI-alpha, 0.0, 0.0, 1.0);
		//final_transform = CATransform3DTranslate(final_transform,0.0, (MAX_SCREEN_WIDTH/3.0) * cos([self beta])/ sin(CAMERA_ANGLE_Y * M_PI / 180), 0.0);
		
		overlay_animation.keyPath		= @"transform";
		overlay_animation.fromValue		= [NSValue valueWithCATransform3D: poiOverlay.layer.transform];
		overlay_animation.toValue		= [NSValue valueWithCATransform3D: final_transform];
		overlay_animation.duration		= 0.2;
		[[poiOverlay layer] addAnimation: overlay_animation
								  forKey: @"overlay_animation"];
		poiOverlay.layer.transform = final_transform;
		
	}else{
		alpha = [self mAlpha];
	}
	[self setMVerticalOffset: sin(beta)*(MIN_SCREEN_WIDTH / 6.0 + abs((MAX_SCREEN_WIDTH - MIN_SCREEN_WIDTH) * cos(alpha)/3))];

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
	
	NSString *selectedAnnotationTitle = nil;
	
	if(selectedPoi >= 0){
		VTAnnotation *selectedAnnotation = [[ar_poiList objectAtIndex:selectedPoi] annotation];
		selectedAnnotationTitle = [selectedAnnotation title];
	}
	
	[self setSelectedPoi:-1];
	
	[ar_poiViews release];
	[ar_poiList release];
	
	ar_poiList = [[NSMutableArray alloc] init];
	ar_poiViews = [[NSMutableArray alloc] init];
	
	CLLocationCoordinate2D origin = {0,0};
	if(currentLocation){
		origin = currentLocation.coordinate;
	}
	
	int i = 0;
	for(VTAnnotation *anAnnotation in newList){
		AugmentedPoi *aPoi = [[AugmentedPoi alloc] initWithAnnotation:anAnnotation fromOrigin:origin];
		[ar_poiList addObject:aPoi];

		[aPoi release];
		[self addPoiView];

		if([[anAnnotation title] isEqual:selectedAnnotationTitle]){
			[self setSelectedPoi:i];
		}
		i++;
	}
	[self updateProjection];
}

-(void)addPoiView{
	CGPoint center = {OFFSCREEN_SQUARE_SIZE/2.0, OFFSCREEN_SQUARE_SIZE/2.0 - 1.5 * POI_BUTTON_SIZE/2};
	
	UIButton *aButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	aButton.exclusiveTouch = NO;
	aButton.frame = CGRectMake(0.0, 0.0, POI_BUTTON_SIZE, POI_BUTTON_SIZE);
	aButton.backgroundColor = [UIColor clearColor];
	UIImage *buttonImageNormal = [UIImage imageNamed:@"augmentedpoi.png"];
	[aButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
	UIImage *buttonImagePressed = [UIImage imageNamed:@"augmentedpoiselect.png"];
	[aButton setBackgroundImage:buttonImagePressed forState:UIControlStateHighlighted];
	[aButton addTarget:self action:@selector(poiSelected:) forControlEvents:UIControlEventTouchDown];
	[aButton addTarget:self action:@selector(poiSelected:) forControlEvents:UIControlEventTouchDragInside];
	
	aButton.center = center;
	
	UIImageView *needleAndShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"needleandshadow.png"]];
	[needleAndShadow setFrame:CGRectMake(0, 0, POI_BUTTON_SIZE*2.3, POI_BUTTON_SIZE*1.5)];
	[aButton addSubview:needleAndShadow];
	[aButton sendSubviewToBack:needleAndShadow];
	[needleAndShadow release];
	
	[poiOverlay addSubview:aButton];
	[ar_poiViews addObject:aButton];
	[aButton release];
	
}

-(IBAction) blankTouch:(id)view{
	[self setBubbleMatrixForView:nil];
	[self setSelectedPoi:-1];
}

-(void) poiSelected:(id) poiViewId{
	[self setSelectedPoi:[ar_poiViews indexOfObject:poiViewId]];
	[self setBubbleMatrixForView:poiViewId];
}

-(void) setSelectedPoi:(int)value{
	if(selectedPoi >= 0){
		UIButton *previousSelectedButton = [ar_poiViews objectAtIndex:selectedPoi];
		[previousSelectedButton setEnabled:TRUE];
	}
	selectedPoi = value;
	if(selectedPoi >=0){
		UIButton *selectedView = [ar_poiViews objectAtIndex:selectedPoi];
		[selectedView setEnabled:FALSE];
		VTAnnotation *selectedAnnotation = [[ar_poiList objectAtIndex:selectedPoi] annotation];
		
		[calloutBubble setTitle:[selectedAnnotation title] subtitle:[selectedAnnotation subtitle]];
		[calloutBubble setTramLines:[selectedAnnotation getLineList]];
	}
}

-(void)setCurrentLocation:(CLLocation *)location{
	currentLocation = location;
	[gridView setCenterCoordinate:location.coordinate];
	for (AugmentedPoi *aPoi in ar_poiList) {
		[aPoi updateAngleFrom:location.coordinate];
	}
}

-(void)setOrientation:(UIInterfaceOrientation)orientation{
}

-(BOOL)canBecomeFirstResponder {
    return NO;
}

- (void)viewDidUnload {
	[calloutBubble release];
	[ar_poiList release];
	for(UIView *aView in ar_poiViews){
		[aView removeFromSuperview];
	}
	[ar_poiViews release];
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[calloutBubble release];
	[ar_poiList release];
	for(UIView *aView in ar_poiViews){
		[aView removeFromSuperview];
	}
	[ar_poiViews release];

    [super dealloc];
}


@end
