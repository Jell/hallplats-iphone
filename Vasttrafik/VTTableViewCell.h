/**
 View for a VTForecast to be displayed in a Table view.
 */

//
//  VTTableViewCell.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTForecast.h"

@interface VTTableViewCell : UITableViewCell {
	IBOutlet UILabel *tramNumber;
	IBOutlet UILabel *destinationLabel;
	IBOutlet UILabel *nastaLabel;
	IBOutlet UILabel *darefterLabel;
	IBOutlet UIImageView *nastaHandicap;
	IBOutlet UIImageView *nastaLowFloor;
	IBOutlet UIImageView *darefterHandicap;
	IBOutlet UIImageView *darefterLowFloor;
	IBOutlet UILabel *nastaTitleLabel;
	
}

-(void)setForecast:(VTForecast *)forecast;

@end

