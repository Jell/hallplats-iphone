/**
 View representation for an AugmentedPoi
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


@interface AugmentedPoiViewController : UIViewController <UIScrollViewDelegate>{
	IBOutlet UILabel *infoLabel;				/**<Title view */
	IBOutlet UILabel *subtitleLabel;			/**<Subtitle view */
	IBOutlet UIScrollView *tramScroll;			/**<Scrolling view for tram line display*/
	IBOutlet UIImageView *arrowImage;			/**<Pin arrow image */
	IBOutlet UIButton *infoButton;				/**<Button that triggers info display */
	int tramLinesNumber;						/**<Number of tram lines for the POI*/
	NSMutableArray *lineViews;					/**<List of tram number Views */
}

/** Set the title and subtitle of the view */
-(void)setTitle:(NSString *)title subtitle:(NSString *)subtitle;

/** clear all the tram lines from the view */
-(void)clearTramLines;

/** add a tram line to the View */
-(void)addTramLine:(NSString *)name backgroundColor:(UIColor *)backgroundColor foregroundColor:(UIColor *)foregroundColor;

/** Set the length of the pin arrow @deprecated*/
-(void)setArrowLength:(float) length;

@end
