//
//  NewPostViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"PhotoViewController.h"

@interface NewPostViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextViewDelegate> {
	IBOutlet UITextView		*textView;
	UIImage					*photo;
	UIImagePickerController	*imagePickerController;
	BOOL					hasPhoto;
	
	UIBarButtonItem			*postButton;
	UIBarButtonItem			*cancelButton;
	UIBarButtonItem			*photoButton;
	UIBarButtonItem			*viewPhotoButton;
	UIBarButtonItem			*deletePhotoButton;
	UIBarButtonItem			*backButton;

	PhotoViewController		*photoView;
	UIAlertView				*progressAlert;
	
	BOOL					loaded;
	NSString				*postText;
}

@property (nonatomic, retain) IBOutlet UITextView	*textView;
@property (nonatomic, retain) IBOutlet UIImage		*photo;
@property (nonatomic, retain) UIViewController		*photoView;
//@property (nonatomic, retain) NSString				*postText;


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;

@end
