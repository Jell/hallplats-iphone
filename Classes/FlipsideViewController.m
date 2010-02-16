//
//  FlipsideViewController.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-26.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FlipsideViewController.h"


@implementation FlipsideViewController

@synthesize delegate;
@synthesize annotationDisplayed;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];  
	NSString *text = [annotationDisplayed title];
	titleLabel.text = [NSString stringWithFormat:@"%@", text];
}


- (IBAction)done {
	[self.delegate flipsideViewControllerDidFinish:self];	
}

-(void)setAnnotationDisplayed:(MPNAnnotation *)anAnnotation{
	annotationDisplayed = anAnnotation;

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
    [super dealloc];
}


@end
