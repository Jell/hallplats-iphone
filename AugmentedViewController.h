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
#import "AugmentedPOI.h"

#define HEADING_BUFFER_SIZE 5
@interface AugmentedViewController : UIViewController <ARViewDelegate>{
	IBOutlet UILabel *titleLabel;
	IBOutlet UIView *poiOverlay;
	int selectedPoi;
	NSMutableArray *ar_poiList;
	NSMutableArray *ar_poiViews;
	CLLocation *currentLocation;
	float angleXY;
	int headingBufferIndex;
	float headingBuffer[HEADING_BUFFER_SIZE];
}

@property (retain) NSMutableArray *ar_poiList;
@property (retain) NSMutableArray *ar_poiViews;
@property (assign)  CLLocation *currentLocation;

-(void)translateView:(UIView *)aView withTeta:(float)teta;
-(void) poiSelected:(id) poiViewId;

@end
