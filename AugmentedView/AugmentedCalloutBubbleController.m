//
//  AugmentedPoiViewController.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AugmentedCalloutBubbleController.h"
#define OFFSCREEN_SQUARE_SIZE		520

@implementation AugmentedCalloutBubbleController
@synthesize delegate;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	UIView *myView = [self view];
	//[myView setFrame:CGRectMake(15 -[myView frame].size.width / 2 , 5 -[myView frame].size.height , [myView frame].size.width, [myView frame].size.height)];
	myView.exclusiveTouch = NO;
	myView.center = CGPointMake(260.0, 205.0 - POI_BUTTON_SIZE);
	
	tramLinesNumber = 0;
	lineViews = [[NSMutableArray alloc] init];
	
	//tramScroll.hidden = YES;
	infoButton.hidden = YES;
	[infoButton addTarget:delegate action:@selector(showInfo:) forControlEvents:UIControlEventTouchDown];

}

-(void)setTramLines:(NSArray *)lineList{
	[self clearTramLines];
	
	for (VTLineInfo *aLine in lineList) {
		[self addTramLine:aLine.lineNumber
				   backgroundColor:aLine.backgroundColor
				   foregroundColor:aLine.foregroundColor];
	}
	
}
-(void)clearTramLines{
	for(UIView *aView in lineViews){
		[aView removeFromSuperview];
	}
	[lineViews release];
	infoButton.hidden = YES;
	lineViews = [[NSMutableArray alloc] init];
	tramLinesNumber = 0;
	[tramScroll setContentSize:CGSizeMake(30.0, 30.0)];

}

-(void)addTramLine:(NSString *)name backgroundColor:(UIColor *)backgroundColor foregroundColor:(UIColor *)foregroundColor{
	UILabel *tramNumber = [[UILabel alloc ] initWithFrame:CGRectMake(0.0 + 33*tramLinesNumber, 40.0, 30.0, 30.0)];
	tramNumber.clearsContextBeforeDrawing = NO;
	tramNumber.textAlignment =  UITextAlignmentCenter;
	tramNumber.lineBreakMode = UILineBreakModeClip;
	tramNumber.textColor = foregroundColor;
	tramNumber.backgroundColor = backgroundColor;
	tramNumber.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(12.0)];
	tramNumber.text = name;
	
	[tramScroll addSubview:tramNumber];
	[lineViews addObject:tramNumber];
	[tramScroll setContentSize:CGSizeMake(30.0 + 33.0 * tramLinesNumber, 30.0)];
	tramLinesNumber++;

	[tramNumber release];
	
	infoButton.hidden = NO;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
-(void)setTitle:(NSString *)title subtitle:(NSString *)subtitle{
	[infoLabel setText:title];
	[subtitleLabel setText:subtitle];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

-(void)setCenter:(CGPoint)apoint{
	float padx = apoint.x;
	if(padx > 80){
		padx -= 80;
	}else if(padx < -80){
		padx += 80;
	}else {
		padx = 0;
	}
	
	[self.view setCenter:CGPointMake(OFFSCREEN_SQUARE_SIZE/2 + padx, OFFSCREEN_SQUARE_SIZE/2 + apoint.y - 55 - POI_BUTTON_SIZE)];
	[arrowImage setCenter:CGPointMake(apoint.x - padx + 100, arrowImage.center.y)];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[lineViews release];
	[infoLabel release];
    [super dealloc];
}


@end
