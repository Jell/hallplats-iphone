/**
 Callout bubble view for an AugmentedPoi
 @see AugmentedPoi
 */

//
//  AugmentedPoiViewController.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTLineInfo.h"

#define POI_BUTTON_SIZE			22.0

@interface AugmentedCalloutBubbleController : UIViewController <UIScrollViewDelegate>{
	IBOutlet UILabel *infoLabel;				/**<Title view */
	IBOutlet UILabel *subtitleLabel;			/**<Subtitle view */
	IBOutlet UIScrollView *tramScroll;			/**<Scrolling view for tram line display*/
	IBOutlet UIImageView *arrowImage;			/**<Pin arrow image */
	IBOutlet UIButton *infoButton;				/**<Button that triggers info display */
	int tramLinesNumber;						/**<Number of tram lines for the POI*/
	NSMutableArray *lineViews;					/**<List of tram number Views */
	id delegate;
}

@property(assign) id delegate;

/** Set the title and subtitle of the view */
-(void)setTitle:(NSString *)title subtitle:(NSString *)subtitle;

/** Set the tram line list */
-(void)setTramLines:(NSArray *)lineList;

/** clear all the tram lines from the view */
-(void)clearTramLines;

/** add a tram line to the View */
-(void)addTramLine:(NSString *)name backgroundColor:(UIColor *)backgroundColor foregroundColor:(UIColor *)foregroundColor;

/** Set the length of the pin arrow @deprecated*/
-(void)setArrowLength:(float) length;

@end
