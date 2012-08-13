//
//  NewPostViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NewPostViewController.h"
#import	"MizoonAppDelegate.h"
#import	"RootViewController.h"
#import "MizProgressHUD.h"



#define	PHOTO_ATTACHED		10
#define	NO_PHOTO_ATTACHED	20


@interface NewPostViewController (private) 
- (void) attachPhoto;
- (void) cancelPost;
- (void) displayAttachedPhoto;
- (void) deletePhoto;
- (void) goToPost;
- (void) uploadPostData;
- (void) setToolbar: (int) option;
- (void) reloadPosts;
@end


@implementation NewPostViewController
@synthesize	textView,photo,photoView;



// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {		
		self.view.frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 460.0);
		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
		//	UITextView	*textField = (UITextView *)[self.view viewWithTag:701];

//		[[Mizoon sharedMizoon] getRootViewController].delegate = self;
    }
    return self;
}




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{

	[super viewDidLoad];

	UIToolbar	*toolbar = (UIToolbar *)[self.view viewWithTag:700];

	textView.frame = CGRectMake(15.0, 15.0, 290.0, 127.0);
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
	
	if (!textView.text || ([textView.text length] < 1)) {
		textView.text = postText;
	} 
	
	[textView becomeFirstResponder];

	
	// image has to be 20X20 with alpha channel
	UIImage		*photoImg = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"camera-icon3" ofType:@"png"]];

	cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelPost)];
	photoButton = [[UIBarButtonItem alloc] initWithImage:photoImg style:UIBarButtonItemStylePlain target:self action:@selector(attachPhoto)];
	viewPhotoButton = [[UIBarButtonItem alloc] initWithTitle:@"View Attachment" style:UIBarButtonItemStyleBordered target:self action:@selector(displayAttachedPhoto)];
	postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleBordered target:self action:@selector(uploadPostData)];

	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

	if (hasPhoto) {
		[toolbar setItems:[NSArray arrayWithObjects:postButton, flexibleSpace, viewPhotoButton, flexibleSpace, cancelButton,nil]];

	} else {
		[toolbar setItems:[NSArray arrayWithObjects: postButton, flexibleSpace, photoButton, flexibleSpace, cancelButton,nil]];
	}
	
	[photoImg release];
	[flexibleSpace release];
	
	[self.view addSubview:toolbar];	
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
	MizoonLog(@"---------------> didReceiveMemoryWarning: NewPostViewController");
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {

}


- (void)dealloc 
{
	[photoButton release];
	[cancelButton release];
	[viewPhotoButton release];
	[deletePhotoButton	release];
	[photo release];
	[photoView	release];
	[imagePickerController	release];
	[textView release];
    [super dealloc];
}





- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	[picker dismissModalViewControllerAnimated:YES];
	[[[Mizoon sharedMizoon] getRootViewController] showTopBar];

	//	photo = [[info objectForKey:@"UIImagePickerControllerOriginalImage"] retain];
	
	
	//	NSEnumerator *enumerator = [info keyEnumerator];
	//	id key;
	//	
	//	while ((key = [enumerator nextObject])) {
	//		/* code that uses the returned key */
	//		NSLog(@"Key=%@", (NSString *) key);
	//	}
	
	
	photo = [[info objectForKey:UIImagePickerControllerOriginalImage] retain];
	
	hasPhoto = TRUE;
	
	//	UIImageView *img = [[UIImageView alloc] initWithImage:photo];
	/*************************************************
	 NSEnumerator *enumerator = [info keyEnumerator];
	 id key;
	 while ((key = [enumerator nextObject]))
	 MizoonLog(@"key=%@ \t value=%@", key,[info valueForKey:key] );
	 *************************************************/
	
	[self setToolbar:PHOTO_ATTACHED];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
	[self dismissModalViewControllerAnimated:YES];

	[[[Mizoon sharedMizoon] getRootViewController] showTopBar];
	self.view.frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 460.0);
}


#pragma mark actionSheet

/*
- (void) actionSheetCancel:(UIActionSheet *)actionSheet {
	MizoonLog(@"Canceld Photo");
}
*/

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{	
	imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;

	switch (buttonIndex) {
		case 0:
			imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
			break;
		case 1:
			imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			break;

		default:
			return;
	}
	
	[self presentModalViewController:imagePickerController animated:YES];
	
	[[[Mizoon sharedMizoon] getRootViewController] hideTopBar];
	
//	[[[Mizoon sharedMizoon] getRootViewController] pushView:EXTERNAL_VIEW];

	// hide the rootview bottom toolbar
//	[rvc.view viewWithTag:1000].hidden = TRUE;
}


#pragma mark private

- (void) attachPhoto 
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
												delegate:self 
												cancelButtonTitle:@"Cancel" 
												destructiveButtonTitle:nil
												otherButtonTitles:@"Take Photo", @"Choose existing", nil];
	
	[actionSheet showInView:self.view];
	[actionSheet release];	
}



- (void) cancelPost {
	RootViewController *rvc = [[Mizoon sharedMizoon] getRootViewController];
	
	self.view.frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 460.0);

	if ([rvc topPlusOneView] != EXTERNAL_LOCATION_VIEW) {
		[rvc renderView:POSTS_VIEW fromView:NEW_POST_VIEW];
		[rvc showTopBar];
	} else {
		[rvc goBack];
	}


}




- (void) sendPosts 
{
	Mizoon *miz = [Mizoon sharedMizoon];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int	radius=DEFAULT_RADIUS;
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;
	
	MizDataManager *dm = [MizDataManager sharedDataManager];
	
	@try {
		[dm uploadPost: textView.text withPhoto: photo postRadius: radius numberToRet: NUM_POSTS_TO_FETCH];

		[miz postToTwitter:textView.text];
		[miz postFBStatus:textView.text];
		
//		dm.nearbyPosts = nil;
	}
	@catch (NSException * e) {
		MizoonLog(@"nearbyPosts hasn't been retained before!");
	}
	
	[progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    [progressAlert release];

	[self dismissModalViewControllerAnimated:YES];
	[[[Mizoon sharedMizoon] getRootViewController] showTopBar];

	int viewID = [rvc popView];  // pop the NEW_POST_VIEW; return the top view
	if (viewID == POSTS_VIEW) 
		[rvc reloadPostsView];
	else 
		[rvc renderView:viewID fromView:NEW_POST_VIEW];

//	[rvc reloadPostsView];

	[pool release];
}


- (void) uploadPostData 
{		
	progressAlert = [[MizProgressHUD alloc] initWithLabel:@"Loading..."];
	[progressAlert show];
	
	[self performSelector:@selector(sendPosts) withObject:nil afterDelay:1.0];			 
}



- (void) deletePhoto 
{
	photo = nil;
	hasPhoto = NO;
	
	[self setToolbar:NO_PHOTO_ATTACHED];
	[self dismissModalViewControllerAnimated:YES];
	[[[Mizoon sharedMizoon] getRootViewController] showTopBar];
	self.view.frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 460.0);
}


- (void) goToPost {
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;
	
	[self dismissModalViewControllerAnimated:YES];
	self.view.frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 460.0);

	// set to hidden in the attachePhoto message
//	[rvc.view viewWithTag:1000].hidden = YES;
	[rvc showTopBar];
}




- (void) displayAttachedPhoto  
{
	Mizoon *miz = [Mizoon sharedMizoon];
	RootViewController *rvc = [miz getRootViewController];
	
	[rvc hideTopBar];
	
	if (photoView == nil) {
		PhotoViewController	*foto = [[PhotoViewController alloc] initWithNibName:@"PhotoView" bundle:nil];
		self.view.frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 460.0);

		self.photoView = foto;
		UIToolbar	*toolbar = (UIToolbar *)[photoView.view viewWithTag:704]; 
		UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		deletePhotoButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(deletePhoto)];
		backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(goToPost)];

		[toolbar setItems:[NSArray arrayWithObjects: backButton, flexibleSpace, deletePhotoButton,nil]];

		[photoView.view bringSubviewToFront:toolbar];
		[flexibleSpace release];
		[foto release];
	}
	
	UIImageView *imageView = (UIImageView *) [photoView.view viewWithTag:700];
	imageView.image = photo;
//	[imageView initWithImage:photo];
//	UIImageView *test = [[UIImageView alloc] initWithImage:photo];
	
	
	[self presentModalViewController:photoView animated:YES];
	[[[Mizoon sharedMizoon] getRootViewController] hideTopBar];
}



- (void) setToolbar: (int) option 
{	
	UIToolbar	*toolbar = (UIToolbar *)[self.view viewWithTag:700];
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	switch (option) {
		case PHOTO_ATTACHED:
			self.view.frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 460.0);

			[toolbar setItems:[NSArray arrayWithObjects:postButton, flexibleSpace, viewPhotoButton, flexibleSpace, cancelButton,nil]];
			toolbar.frame = CGRectMake(0.0, 160, 320.0, 44.0);

			break;
			
		case NO_PHOTO_ATTACHED:
			[toolbar setItems:[NSArray arrayWithObjects: postButton, flexibleSpace, photoButton, flexibleSpace, cancelButton,nil]];
			break;

		default:
			break;
	}

	
	
	[flexibleSpace release];

}

//#pragma mark MizoonRootControllerDelegate
//
//- (void) willRemoveView:(int)newViewID 
//{
//	NSLog(@"willRemoveView------------------------");
//	[self dismissModalViewControllerAnimated:YES];
//}


#pragma mark UITextViewDelegate
//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
//	return TRUE;
//}
//
//
//- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//	NSLog(@"shouldChangeTextInRange - %@", txtView.text );
//
//	return TRUE;
//}
//
//- (void)textViewDidChange:(UITextView *)txtView  {
//	NSLog(@"textViewDidChange - %@", txtView.text );
//}
//
//
//
//
//- (BOOL)textViewShouldEndEditing:(UITextView *)txtView  {
//	NSLog(@"textViewShouldEndEditing - %@", txtView.text );
//
//	return YES;
//}
//



- (void)textViewDidEndEditing:(UITextView *)txtView {
	MizoonLog(@"textViewDidEndEditing - %@", txtView.text );

	if (postText) {
		[postText release];
	}
	
	postText = [[NSString alloc] initWithString: txtView.text];
}






@end
