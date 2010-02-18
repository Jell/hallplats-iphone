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
	IBOutlet UIScrollView *tramScroll;
	IBOutlet UIImageView *arrowImage;
	int tramLinesNumber;
	NSMutableArray *lineViews;
}

-(void)setText:(NSString *) text;
-(void)setArrowLength:(float) length;
-(void)clearTramLines;
-(void)addTramLine:(NSString *)name color:(UIColor *)color;
@end
