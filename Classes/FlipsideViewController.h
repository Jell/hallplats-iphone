/**
 Controller responsible for handling the Flipside View that displays detailed information about one POI.
 */

//
//  FlipsideViewController.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-26.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "VTAnnotation.h"

@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
	id <FlipsideViewControllerDelegate> delegate;	/**< */
	VTAnnotation *annotationDisplayed;				/**< The Annotation being displayed*/
	IBOutlet UINavigationItem *flipsideTitle;
	IBOutlet UITableView *mTableView;				/**< The Table view containing a list of items corresponing to the details of the annotation*/
	IBOutlet UIButton *footerText;
	NSArray *lineList;								/**< List of VTLineInfo*/
	int lineNumber;									/**< Number of lines in the lineList*/
	IBOutlet UITableViewCell *tmpCell;
}

@property (assign) UITableViewCell *tmpCell;
@property (assign) id <FlipsideViewControllerDelegate> delegate;
@property (assign) VTAnnotation *annotationDisplayed;

/** Called when the "Done" button is pressed*/
- (IBAction)done;
- (IBAction)linkToIceHouse;

@end


@protocol FlipsideViewControllerDelegate

/** Called when the view controller did finish*/
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

