//
//  AugmentedPoiViewController.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AugmentedPoiViewController : UIViewController <UIScrollViewDelegate>{
	IBOutlet UILabel *infoLabel;
	IBOutlet UILabel *subtitleLabel;
	IBOutlet UIScrollView *tramScroll;
	IBOutlet UIImageView *arrowImage;
	IBOutlet UIButton *infoButton;
	int tramLinesNumber;
	NSMutableArray *lineViews;
}

-(void)setTitle:(NSString *)title subtitle:(NSString *)subtitle;
-(void)setArrowLength:(float) length;
-(void)clearTramLines;
-(void)addTramLine:(NSString *)name backgroundColor:(UIColor *)backgroundColor foregroundColor:(UIColor *)foregroundColor;
@end
