//
//  PhotosViewController.m
//  Peek-a-Boo
//
//  Created by Iván Mervich on 8/17/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "PhotosViewController.h"
#import "Photo.h"
#import "AppDelegate.h"

@interface PhotosViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation PhotosViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self addPhotosToScrollView];

	self.nameLabel.text = self.user.name;
	self.phoneLabel.text = self.user.phone;
	self.addressLabel.text = self.user.address;
	self.emailLabel.text = self.user.email;
}

- (UIImage *)imageWithFileName:(NSString *)fileName
{
	NSURL *imageURL = [[self appDelegate].applicationDocumentsDirectory URLByAppendingPathComponent:fileName];
	NSData *data = [NSData dataWithContentsOfURL:imageURL];
	return [UIImage imageWithData:data];
}

#pragma mark - IBActions

- (IBAction)onAddPhotoButtonTapped:(UIBarButtonItem *)sender
{
	for (UIView *view in self.scrollView.subviews) {
		[view removeFromSuperview];
	}

	// add photo to user
	UIImagePickerController *imagePicker = [UIImagePickerController new];
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePicker.delegate = self;

	[self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[self dismissViewControllerAnimated:YES completion:nil];

	UIImage *image = info[UIImagePickerControllerOriginalImage];

	// create photos object
	Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:[self managedObjectContext]];
	newPhoto.fileName = [NSString stringWithFormat:@"%@_photo_%d.png", self.user.email, self.user.photos.count + 1];
	NSLog(@"new photo name: %@", newPhoto.fileName);

	// save it on documents dir with name: email + "_photo_1"
	NSURL *imageURL = [[self appDelegate].applicationDocumentsDirectory URLByAppendingPathComponent:newPhoto.fileName];
	NSData *imageData = UIImagePNGRepresentation(image);

	// save it on a background thread
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[imageData writeToURL:imageURL atomically:YES];
		NSLog(@"new image saved");
	});

	// add photo to user
	[self.user addPhotosObject:newPhoto];
	// save context
	[self saveContext];

	[self addPhotosToScrollView];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper methods

- (void)addPhotosToScrollView
{
	CGFloat width = 0.0;

	for (Photo *photo in self.user.photos.allObjects) {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[self imageWithFileName:photo.fileName]];
		[self.scrollView addSubview:imageView];

		imageView.frame = CGRectMake(width, 0, self.view.frame.size.width, self.view.frame.size.height);
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		width += imageView.frame.size.width;
	}

	self.scrollView.contentSize = CGSizeMake(width, self.scrollView.frame.size.height);
}

- (void)saveContext
{
	NSError *saveError;
	[[self managedObjectContext] save:&saveError];

	if (saveError) {
		[self showAlertViewWithTitle:@"Saving dog error" message:saveError.localizedDescription buttonTitle:@"OK"];
		NSLog(@"Saving dog error: %@", saveError.localizedDescription);
	} else {
		NSLog(@"context saved");
	}

}

- (NSManagedObjectContext *)managedObjectContext
{
	return [self appDelegate].managedObjectContext;
}

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
														message:message
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:buttonTitle, nil];
	[alertView show];
}

@end
