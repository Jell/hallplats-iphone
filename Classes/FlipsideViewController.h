//
//  FlipsideViewController.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-26.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MPNAnnotation.h"

@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController {
	id <FlipsideViewControllerDelegate> delegate;
	MPNAnnotation *annotationDisplayed;
	IBOutlet UILabel *titleLabel;
}

@property (assign) id <FlipsideViewControllerDelegate> delegate;
@property (assign) MPNAnnotation *annotationDisplayed;

- (IBAction)done;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

