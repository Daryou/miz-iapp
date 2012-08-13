//
//  MainScrollViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 8/5/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import "MainScrollViewController.h"
#import	"MainViewController.h"
#import	"MainView2Controller.h"

#import	"Mizoon.h"

#define	kNumberOfPages	2

@interface  MainScrollViewController() // private
@end

@implementation MainScrollViewController
@synthesize mainScrollView, pageControl, viewControllers, currentPage;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
		pageControl.numberOfPages = 10;//kNumberOfPages;
		pageControl.currentPage = 1;
		
		NSMutableArray *controllers = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < kNumberOfPages; i++) {
			[controllers addObject:[NSNull null]];
		}
		self.viewControllers = controllers;
		[controllers release];
		
		
		RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];

		// hide the rootview bottom toolbar
		[rvc hideTopBar];
//		[rvc.view viewWithTag:1000].hidden = TRUE;
//		[rvc.view viewWithTag:2000].hidden = TRUE;

    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	
	mainScrollView.delegate = self;
    mainScrollView.frame = CGRectMake(0, 0, 320, 400);

	mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * kNumberOfPages, mainScrollView.frame.size.height);
	mainScrollView.contentOffset = CGPointMake(0, 0);
	mainScrollView.clipsToBounds = YES;
	mainScrollView.pagingEnabled = YES;
	mainScrollView.showsVerticalScrollIndicator = NO;
	mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.scrollEnabled = YES; 	

	
	pageControl.numberOfPages = kNumberOfPages;


	MainViewController * mainViewController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	mainViewController.view.frame = CGRectMake(0, 0, 320, 400);
	[mainScrollView addSubview:mainViewController.view];

	MainView2Controller * mainView2Controller = [[MainView2Controller alloc] initWithNibName:@"MainView2" bundle:nil];
	mainView2Controller.view.frame = CGRectMake(320, 0, 320, 400);
	[mainScrollView	addSubview:mainView2Controller.view];

	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	MizoonLog(@"---------------> didReceiveMemoryWarning: MainScrollView");

    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[mainScrollView release];
	[pageControl	release];
    [super dealloc];
}


#pragma mark UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {

//	NSLog(@"scroooolling - content offset=%f", mainScrollView.contentOffset.x);
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//	NSLog(@"Draggggggg");
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
	int page = 0;	
	CGFloat pageWidth = mainScrollView.frame.size.width;
	
	
    page = floor((mainScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
//	NSLog(@"Decelerating - page = %d, Page width=%f  content offset=%f", page, pageWidth, mainScrollView.contentOffset.x);
}

	
@end
