//
//  AugmentedPoiViewController.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AugmentedPoiViewController.h"


@implementation AugmentedPoiViewController

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
	[myView setFrame:CGRectMake(0.0, 0.0, [myView frame].size.width, [myView frame].size.height)];
	myView.exclusiveTouch = NO;
	myView.center = CGPointMake(260.0, 220.0);
	
	tramScroll.backgroundColor = [UIColor clearColor];
	tramScroll.scrollEnabled = YES;
	tramScroll.clipsToBounds = YES;
	[tramScroll setDelegate:self];
	
	tramLinesNumber = 0;
	lineViews = [[NSMutableArray alloc] init];
	
	[tramScroll flashScrollIndicators];

}

-(void)clearTramLines{
	for(UIView *aView in lineViews){
		[aView removeFromSuperview];
	}
	[lineViews release];
	lineViews = [[NSMutableArray alloc] init];
	tramLinesNumber = 0;
	[tramScroll setContentSize:CGSizeMake(20.0, 20.0)];

}

-(void)addTramLine:(NSString *)name color:(UIColor *)color{
	UILabel *tramNumber = [[UILabel alloc ] initWithFrame:CGRectMake(0.0 + 25*tramLinesNumber, 0.0, 22.0, 20.0)];
	tramNumber.textAlignment =  UITextAlignmentCenter;
	tramNumber.lineBreakMode = UILineBreakModeClip;
	if(color == [UIColor whiteColor] || color == [UIColor yellowColor]){
		tramNumber.textColor = [UIColor blackColor];
	}else{
		tramNumber.textColor = [UIColor whiteColor];
	}
	tramNumber.backgroundColor = color;
	tramNumber.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(10.0)];
	tramNumber.text = name;
	[tramScroll addSubview:tramNumber];
	[lineViews addObject:tramNumber];
	tramLinesNumber++;
	[tramScroll setContentSize:CGSizeMake(20.0 + 25.0 * tramLinesNumber, 20.0)];
	[tramNumber release];
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	[tramScroll flashScrollIndicators];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
-(void)setText:(NSString *) text{
	[infoLabel setText:text];
}
-(void)setArrowLength:(float) length{
	arrowImage.frame = CGRectMake(92, 42, 16, 20 + length);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
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
