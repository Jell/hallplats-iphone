/**
 Controls the display of an AugmentedView.
 */

//
//  AugmentedViewController.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "ARViewProtocol.h"
#import "AugmentedPoi.h"
#import "AugmentedCalloutBubbleController.h"
#import "VTAnnotation.h"

#define HEADING_BUFFER_SIZE 1
@interface AugmentedViewController : UIViewController <ARViewDelegate, MKMapViewDelegate>{
	IBOutlet UIView *poiOverlay;					/**< View container for Poi display */
	IBOutlet MKMapView *gridView;						/**< Perspective Grid View */
	IBOutlet UIButton *backgroundButton;
	AugmentedCalloutBubbleController *calloutBubble;	/**< Poi call out bubble controller */
	int selectedPoi;								/**< Currently selected POI, -1 if none is selected */
	NSMutableArray *ar_poiList;						/**< List containing the POI */
	NSMutableArray *ar_poiViews;					/**< List containing the POI views */
	CLLocation *currentLocation;					/**< Current location of the user */
	float mAlpha;
	float mBeta;/**< Angle at which the iPhone is held on the XY plane*/
	id delegate;
}

@property float mAlpha;
@property float mBeta;
@property(retain) NSMutableArray *ar_poiList;
@property(retain) NSMutableArray *ar_poiViews;
@property(assign)  CLLocation *currentLocation;
@property(assign) id delegate;

/** Moves the perspective grid according to the given orientation
 @param teta current azimuth of the user from -pi to pi 
 @param beta current pitch of the user from -pi to pi */
-(void)translateGridWithTeta:(float)teta andBeta:(float)beta;

/** Position the given view according to its azimuth and distance to current location
 @param aView the view to position
 @param teta azimuth of the POI represented by the view, valued from -pi to pi
 @param beta current pitch of the user from -pi to pi
 @param distance distance of the POI represented by the view, must be greater than 0
 @param scaleEnabled If set to YES, the view is scaled to perspective*/
-(void)translateView:(UIView *)aView withTeta:(float)teta beta:(float)beta andDistance:(float)distance withScale:(BOOL)scaleEnabled;

-(void)setBubbleMatrixForView:(UIView *)aview;

-(IBAction) blankTouch:(id)view;

/** Performed when a POI is selected */
-(void) poiSelected:(id) poiViewId;

/** Add a POI view to the Poi overlay */
-(void)addPoiView;

@end
